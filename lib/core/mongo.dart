part of serveme;

class MongoDbConnection {
	MongoDbConnection._internal(this._db, this._config, this._server);

	final Db _db;
	final MongoConfig _config;
	final ServeMe<ServeMeClient> _server;

	Future<Db> get db async {
		if (!_db.isConnected && _db.state != State.OPENING) {
			_server.error('MongoDB connection is lost, reconnecting...');
			try {
				await _db.close();
				await Future<void>.delayed(const Duration(seconds: 1));
				await _db.open(secure: _config.secure);
				_server.log('MongoDB connection is reestablished');
			}
			catch (err) {
				_server.error('Unable to establish MongoDB connection: $err');
			}
		}
		return _db;
	}

	static Future<MongoDbConnection> connect(MongoConfig config, ServeMe<ServeMeClient> server) async {
		server.log('Connecting to MongoDB...');
		final String connectionString =
			'mongodb://'
			'${config.user != null ? config.user! + ':' + (config.password ?? '') + '@' : ''}'
			'${config.hosts != null ? config.hosts!.join(',') : config.host}'
			'/${config.database}'
			'${config.replica != null ? '?replicaSet=${config.replica}' : ''}';
		final Db db = Db(connectionString);
		await db.open(secure: config.secure);
		server.log('MongoDB connection is established');
		return MongoDbConnection._internal(db, config, server);
	}

	Future<void> close() async {
		if (_db.state == State.OPEN) await _db.close();
	}
}
