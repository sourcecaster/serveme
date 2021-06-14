library serveme;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:connectme/connectme.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Type;
import 'package:packme/packme.dart';
import 'package:yaml/yaml.dart';
part 'classes/module.dart';
part 'classes/config.dart';
part 'core/console.dart';
part 'core/events.dart';
part 'core/integrity.dart';
part 'core/logger.dart';
part 'core/mongo.dart';
part 'core/scheduler.dart';
part 'core/utils.dart';

final bool _unixSocketsAvailable = Platform.isLinux || Platform.isAndroid || Platform.isMacOS;

class ServeMeClient extends ConnectMeClient {
	ServeMeClient(WebSocket socket, HttpHeaders headers) : super(socket, headers);
}

class ServeMe<C extends ServeMeClient> {
	ServeMe({
		String configFile = 'config.yaml',
		Config Function(String filename)? configFactory,
		C Function(WebSocket, HttpHeaders)? clientFactory,
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
		final InternetAddress address = _unixSocketsAvailable && config._socket != null
			? InternetAddress(config._socket!, type: InternetAddressType.unix)
			: InternetAddress('127.0.0.1', type: InternetAddressType.IPv4);
		_cmServer = ConnectMe.server(address,
			port: config._port ?? 0,
			clientFactory: _clientFactory,
			onLog: log,
			onError: error,
			onConnect: (C client) => _events.dispatch(ConnectEvent<C>(client)),
			onDisconnect: (C client) => _events.dispatch(DisconnectEvent<C>(client))
		);
	}

	bool _running = false;
	final List<StreamSubscription<ProcessSignal>> _processSignalListeners = <StreamSubscription<ProcessSignal>>[];
	late final Config config;
	late final Console console;
	late final Events _events;
	late final Logger _logger;
	late final Scheduler _scheduler;
	late final ConnectMeServer<C> _cmServer;
	MongoDbConnection? _mongo;
	final Map<String, Module> _modules = <String, Module>{};
	final C Function(WebSocket, HttpHeaders)? _clientFactory;
	final Map<String, CollectionDescriptor>? _dbIntegrityDescriptor;
	ProcessSignal? _signalReceived;
	Timer? _signalTimer;

	Module? operator [](String module) => _modules[module];
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
			try {
				await _modules[name]!.dispose();
			}
			catch(err, stack) {
				error('An error has occurred while disposing module "$name": $err', stack);
			}
			_modules[name]!._state = ModuleState.disposed;
		}
	}

	void register(Map<int, PackMeMessage Function()> messageFactory) {
		_cmServer.register(messageFactory);
	}

	void broadcast(dynamic data, {bool Function(C)? where}) {
		_cmServer.broadcast(data, where: where);
	}

	void listen<T>(Future<void> Function(T, C) handler) {
		_cmServer.listen<T>(handler);
	}

	void cancel<T>(Future<void> Function(T, C) handler) {
		_cmServer.cancel<T>(handler);
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
					await _cmServer.serve();
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
		await _events.dispatch(StopEvent(event, code));
		if (_unixSocketsAvailable && config._socket != null) {
			final File socketFile = File(config._socket!);
			if (socketFile.existsSync()) socketFile.deleteSync(recursive: true);
		}
		for (final StreamSubscription<ProcessSignal> listener in _processSignalListeners) {
			listener.cancel();
		}
		_processSignalListeners.clear();
		await _cmServer.close();
		await _disposeModules();
		_scheduler.dispose();
		_events.dispose();
		if (_mongo != null) await _mongo!.close();
		await console.dispose();
		await _logger.dispose();
		exit(code);
	}
}
