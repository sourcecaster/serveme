part of serveme;

class MongoDbConnection {
	MongoDbConnection._internal(this._db, this._config);

	final Db _db;
	final MongoConfig _config;

	Future<Db> get db async {
		if (!_db.isConnected && _db.state != State.OPENING) {
			error('MongoDB connection is lost, reconnecting...');
			try {
				await _db.close();
				await Future<void>.delayed(const Duration(seconds: 1));
				await _db.open(secure: _config.secure);
				log('MongoDB connection is reestablished');
			}
			catch (err) {
				error('Unable to establish MongoDB connection: $err');
			}
		}
		return _db;
	}

	static Future<MongoDbConnection> connect(MongoConfig config) async {
		log('Connecting to MongoDB...');
		final String connectionString =
			'mongodb://'
			'${config.user != null ? config.user! + ':' + (config.password ?? '') + '@' : ''}'
			'${config.hosts != null ? config.hosts!.join(',') : config.host}'
			'/${config.database}'
			'${config.replica != null ? '?replicaSet=${config.replica}' : ''}';
		final Db db = Db(connectionString);
		await db.open(secure: config.secure);
		log('MongoDB connection is established');
		return MongoDbConnection._internal(db, config);
	}

	Future<void> close() async {
		if (_db.state == State.OPEN) await _db.close();
	}
}
