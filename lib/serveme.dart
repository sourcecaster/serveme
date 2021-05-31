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
	const Module({this.api, this.init, this.run, this.dispose});
	final Object? api;
	final Future<void> Function()? init;
	final void Function()? run;
	final Future<void> Function()? dispose;
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
		_modules.addEntries(modules.entries.where((entry) {
			if (!config.modules.contains(entry.key)) return false;
			if (entry.value.init == null && entry.value.run == null) {
				error('Unable to register module ${entry.key}: init() or/and run() must be implemented');
				return false;
			}
			return true;
		}));
	}

	late final Config config;
	final Map<String, Module> _modules = <String, Module>{};
	final Client Function(WebSocket)? _clientFactory;
	final List<Client> _clients = <Client>[];
	final Map<String, CollectionDescriptor>? _dbIntegrityDescriptor;

	Future<void> _initModules() async {
		log('Initializing modules...');
		int count = 0;
		for (final String name in _modules.keys) {
			if (_modules[name]!.init == null) continue;
			log('Initializing module: $name');
			await _modules[name]!.init!();
			count++;
		}
		log('$count modules are initialized');
	}

	void _runModules() {
		log('Running modules...');
		int count = 0;
		for (final String name in _modules.keys) {
			if (_modules[name]!.run == null) continue;
			log('Running module: $name');
			_modules[name]!.run!();
			count++;
		}
		log('$count modules are running');
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
		for (Client client in _clients) {
			if (where != null && !where(client)) continue;
			client.send(data);
		}
	}

	Future<bool> run() async {
		bool result = false;
		if (!config._valid) {
			error('Unable to run server due to invalid configuration');
			return false;
		}
		await runZonedGuarded(
			() async {
				try {
					if (config._mongo != null) {
						await initMongo();
						if (_dbIntegrityDescriptor != null) await _checkMongoIntegrity(_dbIntegrityDescriptor!);
					}
					await _initModules();
					_runModules();
					await _initWebSocketServer();
					result = true;
				}
				catch (err, stack) {
					await error('Server initialization failed: $err', stack);
					await log('Server stopped due to initialization errors');
					await dispatchEvent(Event.stop, <String, dynamic>{
						'code': -1,
					});
					// await destroyMongo();
					// await destroyLogger();
					// exit(-1);
				}
			},
			// Handle all unhandled exceptions in order to prevent application crash
			(Object err, StackTrace stack) async {
				error('UNHANDLED: $err', stack);
			}
		);
		return result;
	}
}
