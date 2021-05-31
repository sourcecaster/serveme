part of serveme;

late Db db;
bool _initialized = false;

Future<void> initMongo() async {
	final String connectionString =
		'mongodb://'
		'${config.mongo.user != null ? config.mongo.user! + ':' + (config.mongo.password ?? '') + '@' : ''}'
		'${config.mongo.hosts != null ? config.mongo.hosts!.join(',') : config.mongo.host}'
		'/${config.mongo.database}'
		'${config.mongo.replica != null ? '?replicaSet=${config.mongo.replica}' : ''}';
	db = Db(connectionString);
	_initialized = true;
	await db.open();
}

Future<void> destroyMongo() async {
	if (_initialized && db.state == State.OPEN) {
		await db.close();
	}
}