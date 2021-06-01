part of serveme;

enum ModuleState {
	none,
	initialized,
	started,
	disposed,
}

abstract class Module {
	late ServeMe server;

	ModuleState _state = ModuleState.none;

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

