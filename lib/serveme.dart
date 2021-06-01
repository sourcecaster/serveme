library serveme;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:mongo_dart/mongo_dart.dart' hide Type;
import 'package:yaml/yaml.dart';
part 'classes/client.dart';
part 'core/config.dart';
part 'core/console.dart';
part 'core/events.dart';
part 'core/integrity.dart';
part 'core/logger.dart';
part 'core/mongo.dart';
part 'core/scheduler.dart';
part 'core/utils.dart';

final bool _unixSocketsAvailable = Platform.isLinux || Platform.isAndroid || Platform.isMacOS;

abstract class Module {
	late ServeMe server;

	Config get config => server.config;
	Future<Db> get db {
		if (server._mongo == null) throw Exception('MongoDB is not initialized');
		return server._mongo!.db;
	}
	Future<void> Function(String, [String]) get log => server._logger.log;
	Future<void> Function(String, [String]) get debug => server._logger.debug;
	Future<void> Function(String, [StackTrace?]) get error => server._logger.error;

	Future<void> init();
	void run();
	Future<void> dispose();
}

class ServeMe {
	ServeMe({
		String configFile = 'config.yaml',
		Map<String, Module> modules = const <String, Module>{},
		Client Function(WebSocket)? clientFactory,
		Config Function(String filename)? configFactory,
		Map<String, CollectionDescriptor>? dbIntegrityDescriptor,
	}) : _clientFactory = clientFactory, _dbIntegrityDescriptor = dbIntegrityDescriptor {
		config = Config._instantiate(configFile, factory: configFactory);
		_logger = Logger(config);
		if (config != null) {
			_modules.addEntries(modules.entries.where((MapEntry<String, Module> entry) {
				if (!config.modules.contains(entry.key)) return false;
				entry.value.server = this;
				return true;
			}));
		}
	}

	bool _running = false;
	late final Config config;
	late final Logger _logger;
	late final MongoDbConnection? _mongo;
	final Map<String, Module> _modules = <String, Module>{};
	final Client Function(WebSocket)? _clientFactory;
	final List<Client> _clients = <Client>[];
	final Map<String, CollectionDescriptor>? _dbIntegrityDescriptor;

	Future<Db> get db {
		if (_mongo == null) throw Exception('MongoDB is not initialized');
		return _mongo!.db;
	}
	Future<void> Function(String, [String]) get log => _logger.log;
	Future<void> Function(String, [String]) get debug => _logger.debug;
	Future<void> Function(String, [StackTrace?]) get error => _logger.error;

	Future<void> _initMongoDB() async {
		if (config._mongo != null) {
			_mongo = await MongoDbConnection.connect(config._mongo!);
			if (_dbIntegrityDescriptor != null) await _checkMongoIntegrity(this, _dbIntegrityDescriptor!);
		}
	}

	Future<void> _initModules() async {
		log('Initializing modules...');
		for (final String name in _modules.keys) {
			log('Initializing module: $name');
			await _modules[name]!.init();
		}
		log('Modules initialization complete');
	}

	void _runModules() {
		log('Running modules...');
		for (final String name in _modules.keys) {
			log('Running module: $name');
			_modules[name]!.run();
		}
		log('All modules are running');
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
				dispatchEvent(Event.connect, <String, dynamic>{'client': client});
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
		_running = true;
		await runZonedGuarded(
			() async {
				try {
					await _initMongoDB();
					await _initModules();
					_runModules();
					await _initWebSocketServer();
				}
				catch (err, stack) {
					await error('Server initialization failed: $err', stack);
					await log('Server stopped due to initialization errors');
					await dispatchEvent(Event.stop, <String, dynamic>{
						'code': -1,
					});
					if (_mongo != null) await _mongo!.close();
					_running = false;
					// await destroyLogger();
					// exit(-1);
				}
			},
			// Handle all unhandled exceptions in order to prevent application crash
			(Object err, StackTrace stack) async {
				error('UNHANDLED: $err', stack);
			}
		);
		return _running;
	}
}
