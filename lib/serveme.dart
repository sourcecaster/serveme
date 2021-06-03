library serveme;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:mongo_dart/mongo_dart.dart' hide Type;
import 'package:yaml/yaml.dart';
part 'classes/client.dart';
part 'classes/module.dart';
part 'core/config.dart';
part 'core/console.dart';
part 'core/events.dart';
part 'core/integrity.dart';
part 'core/logger.dart';
part 'core/mongo.dart';
part 'core/scheduler.dart';
part 'core/utils.dart';

final bool _unixSocketsAvailable = Platform.isLinux || Platform.isAndroid || Platform.isMacOS;

class ServeMe {
	ServeMe({
		String configFile = 'config.yaml',
		Config Function(String filename)? configFactory,
		Client Function(WebSocket)? clientFactory,
		Map<String, Module> modules = const <String, Module>{},
		Map<String, CollectionDescriptor>? dbIntegrityDescriptor,
	}) : _clientFactory = clientFactory, _dbIntegrityDescriptor = dbIntegrityDescriptor {
		config = Config._instantiate(configFile, factory: configFactory);
		console = Console(this);
		_logger = Logger(this);
		_events = Events(this);
		_scheduler = Scheduler(this);
		if (config != null) {
			_modules.addEntries(modules.entries.where((MapEntry<String, Module> entry) {
				if (!config.modules.contains(entry.key)) return false;
				entry.value.server = this;
				return true;
			}));
		}
	}

	bool _running = false;
	final List<StreamSubscription<ProcessSignal>> _processSignalListeners = <StreamSubscription<ProcessSignal>>[];
	late final Config config;
	late final Console console;
	late final Events _events;
	late final Logger _logger;
	late final Scheduler _scheduler;
	MongoDbConnection? _mongo;
	final Map<String, Module> _modules = <String, Module>{};
	final Client Function(WebSocket)? _clientFactory;
	final List<Client> _clients = <Client>[];
	final Map<String, CollectionDescriptor>? _dbIntegrityDescriptor;
	ProcessSignal? _signalReceived;
	Timer? _signalTimer;

	Future<Db> get db {
		if (_mongo == null) throw Exception('MongoDB is not initialized');
		return _mongo!.db;
	}
	Future<void> Function(String, [String]) get log => _logger.log;
	Future<void> Function(String, [String]) get debug => _logger.debug;
	Future<void> Function(String, [StackTrace?]) get error => _logger.error;

	Future<void> _initMongoDB() async {
		if (config._mongo == null) return;
		_mongo = await MongoDbConnection.connect(config._mongo!, this);
		if (_dbIntegrityDescriptor != null) await _checkMongoIntegrity(this, _dbIntegrityDescriptor!);
	}

	Future<void> _initModules() async {
		if (_modules.isEmpty) return;
		log('Initializing modules...');
		for (final String name in _modules.keys) {
			log('Initializing module: $name');
			await _modules[name]!.init();
			_modules[name]!._state = ModuleState.initialized;
		}
		log('Modules initialization complete');
	}

	void _runModules() {
		if (_modules.isEmpty) return;
		log('Running modules...');
		for (final String name in _modules.keys) {
			log('Running module: $name');
			_modules[name]!.run();
			_modules[name]!._state = ModuleState.running;
		}
		log('All modules are running');
	}

	bool _confirm(ProcessSignal signal, String message) {
		if (_signalTimer != null && _signalTimer!.isActive) _signalTimer!.cancel();
		if (signal == _signalReceived) return true;
		else log(message, CYAN);
		_signalReceived = signal;
		_signalTimer = Timer(const Duration(seconds: 2), () {
			_signalReceived = null;
		});
		return false;
	}

	Future<void> _disposeModules() async {
		for (final String name in _modules.keys) {
			if (_modules[name]!._state == ModuleState.none) continue;
			await _modules[name]!.dispose();
			_modules[name]!._state = ModuleState.disposed;
		}
	}

	Future<void> _initWebSocketServer() async {
		HttpServer? httpServer;
		if (_unixSocketsAvailable && config._socket != null) {
			log('Starting WebSocket server using unix named socket...');
			final File socketFile = File(config._socket!);
			if (socketFile.existsSync()) socketFile.deleteSync(recursive: true);
			httpServer = await HttpServer.bind(InternetAddress(config._socket!, type: InternetAddressType.unix), 0);
		}
		else if (config._port != null) {
			log('Starting WebSocket server using local IP address...');
			httpServer = await HttpServer.bind(InternetAddress('127.0.0.1', type: InternetAddressType.IPv4), config._port!);
		}
		if (httpServer != null) {
			httpServer.listen((HttpRequest request) async {
				final WebSocket socket = await WebSocketTransformer.upgrade(request);
				final Client client = _clientFactory != null ? _clientFactory!(socket) : Client(socket);
				_clients.add(client);
				socket.listen((dynamic socket) {
					if (socket is WebSocket) {
						socket.listen(print);
					}
				});
				_events.dispatch(Event.connect, <String, dynamic>{'client': client});
			});
			log('WebSocket server is running on: ${httpServer.address.address} port ${httpServer.port}');
		}
	}

	void broadcast(Uint8List data, {bool Function(Client)? where}) {
		for (final Client client in _clients) {
			if (where != null && !where(client)) continue;
			client.send(data);
		}
	}

	Future<bool> run() async {
		if (_running) return false;
		log('Server start initiated');
		_running = true;
		await runZonedGuarded(
			() async {
				try {
					_processSignalListeners.add(ProcessSignal.sighup.watch().listen((_) => _shutdown(_, 1)));
					_processSignalListeners.add(ProcessSignal.sigint.watch().listen((_) {
						if (_confirm(ProcessSignal.sigint, 'Press ^C again shortly to stop the server')) _shutdown(_, 2);
					}));
					if (!Platform.isWindows) {
						_processSignalListeners.add(ProcessSignal.sigterm.watch().listen((_) => _shutdown(_, 15)));
						_processSignalListeners.add(ProcessSignal.sigusr1.watch().listen((_) => _shutdown(_, 10)));
						_processSignalListeners.add(ProcessSignal.sigusr2.watch().listen((_) => _shutdown(_, 12)));
					}
					console.on('stop', (_, __) => _shutdown(ProcessSignal.sigquit, 0),
						validator: RegExp(r'^$'),
						usage: 'stop',
						similar: <String>['exit', 'quit', 'shutdown'],
					);
					await _initMongoDB();
					await _initModules();
					_runModules();
					await _initWebSocketServer();
				}
				catch (err, stack) {
					await error('Server initialization failed: $err', stack);
					await _shutdown(ProcessSignal.sigabrt, 6);
				}
			},
			// Handle all unhandled exceptions in order to prevent application crash
			(Object err, StackTrace stack) async {
				error('UNHANDLED: $err', stack);
			}
		);
		return _running;
	}

	Future<void> _shutdown(ProcessSignal event, [int code = 100500]) async {
		await log('Server stopped: $event');
		await _events.dispatch(Event.stop, <String, dynamic>{
			'code': code,
		});
		if (_unixSocketsAvailable && config._socket != null) {
			final File socketFile = File(config._socket!);
			if (socketFile.existsSync()) socketFile.deleteSync(recursive: true);
		}
		for (final StreamSubscription<ProcessSignal> listener in _processSignalListeners) {
			listener.cancel();
		}
		_processSignalListeners.clear();
		_scheduler.dispose();
		_events.dispose();
		await _disposeModules();
		if (_mongo != null) await _mongo!.close();
		await console.dispose();
		await _logger.dispose();
		exit(code);
	}
}
