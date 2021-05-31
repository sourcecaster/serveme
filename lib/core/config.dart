part of serveme;

class MongoConfig {
	const MongoConfig({
		this.host,
		this.hosts,
		this.replica,
		required this.database,
		this.user,
		this.password,
	});

	final String? host;
	final List<String>? hosts;
	final String? replica;
	final String database;
	final String? user;
	final String? password;
}

class Config {
	const Config({
		this.socket,
		this.port,
		this.mongo = const MongoConfig(
			host: '127.0.0.1',
			database: 'trading4pro',
		),
		this.debug = false,
		this.debugLog = 'debug.log',
		this.errorLog = 'error.log',
		this.modules = const <String>[],
	});

	final String? socket;
	final int? port;
	final MongoConfig mongo;
	final bool debug;
	final String debugLog;
	final String errorLog;
	final List<String> modules;

	static Config? load(String filename) {
		Config? config;
		try {
			final String yaml = File(filename).readAsStringSync();
			final YamlMap map = loadYaml(yaml) as YamlMap;
			config = Config(
				socket: 		cast<String>(map['socket']) 			?? config.socket,
				port: 			cast<int>(map['port']) 					?? config.port,
				mongo: map['mongo'] is YamlMap ? MongoConfig(
					host: 		cast<String?>(map['mongo']['host']),
					hosts: 		map['mongo']['host'] is YamlList ? (map['mongo']['host'] as YamlList).cast<String>() : null,
					replica: 	cast<String?>(map['mongo']['replica']),
					database: 	cast<String>(map['mongo']['database'])	?? config.mongo.database,
					user: 		cast<String?>(map['mongo']['user']),
					password: 	cast<String?>(map['mongo']['password']),
				) : config.mongo,
				debug: 			cast<bool>(map['debug']) 				?? config.debug,
				debugLog: 		cast<String>(map['debug_log']) 			?? config.debugLog,
				errorLog: 		cast<String>(map['error_log']) 			?? config.errorLog,
				modules: 		map['modules'] is YamlList ? (map['modules'] as YamlList).cast<String>() : config.modules,
			);
		}
		catch (err) {
			error('Unable to load config file "$filename": $err');
		}
		return config;
	}
}
