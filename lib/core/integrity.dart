part of serveme;

enum IndexImplementationStatus {
	implemented,
	invalid,
	none,
}

class IndexDescriptor {
	IndexDescriptor({required this.key, this.unique = false, this.sparse = false, this.expireAfterSeconds});

	final Map<String, int> key;
	final bool unique;
	final bool sparse;
	final int? expireAfterSeconds;

	IndexImplementationStatus _implementationStatus(String name, List<Map<String, dynamic>> indexes) {
		for (final Map<String, dynamic> index in indexes) {
			bool equal = key.toString() == index['key'].toString();
			equal &= (unique && index['unique'] == true) || (!unique && index['unique'] != true);
			equal &= (sparse && index['sparse'] == true) || (!sparse && index['sparse'] != true);
			equal &= expireAfterSeconds == index['expireAfterSeconds'];
			if (equal) return IndexImplementationStatus.implemented;
			else if (index['name'] == name) return IndexImplementationStatus.invalid;
		}
		return IndexImplementationStatus.none;
	}
}

class CollectionDescriptor {
	CollectionDescriptor({this.indexes = const <String, IndexDescriptor>{}, this.capped = false, this.cappedSize, this.cappedLength, this.documents = const <Map<String, dynamic>>[]});

	final Map<String, IndexDescriptor> indexes;
	final bool capped;
	final int? cappedSize;
	final int? cappedLength;
	final List<Map<String, dynamic>> documents;

	CreateCollectionOptions get _options {
		final CreateCollectionOptions data = CreateCollectionOptions(
			capped: capped,
			size: cappedSize,
			max: cappedLength,
		);
		return data;
	}
}

Future<void> _checkCollections(ServeMe<ServeMeClient> server, Map<String, CollectionDescriptor> collections) async {
	final List<String?> names = await (await server.db).getCollectionNames();
	for (final String name in collections.keys) {
		if (names.contains(name)) continue;
		server.error('Collection "$name" is missing: fixing...');
		await (await server.db).createCollection(name, createCollectionOptions: collections[name]!._options);
		server.log('Collection "$name" is created');
	}
}

Future<void> _checkIndexes(ServeMe<ServeMeClient> server, Map<String, CollectionDescriptor> collections) async {
	for (final String name in collections.keys) {
		final CollectionDescriptor collection = collections[name]!;
		if (collection.indexes.isEmpty) continue;
		final List<Map<String, dynamic>> actualIndexes = await (await server.db).collection(name).getIndexes();
		for (final String indexName in collection.indexes.keys) {
			final IndexDescriptor index = collection.indexes[indexName]!;
			final IndexImplementationStatus implementation = index._implementationStatus(indexName, actualIndexes);
			if (implementation == IndexImplementationStatus.implemented) continue;
			server.error('Index "$indexName" is missing for collection "$name": fixing...');
			if (implementation == IndexImplementationStatus.invalid) {
				server.error('Name "$indexName" is used by another index: MANUAL FIX REQUIRED');
				continue;
			}
			// creteIndex doesn't support expireAfterSeconds, so we do it long way
			// await (await server.db).collection(name).createIndex(name: indexName, keys: index.key, unique: index.unique, sparse: index.sparse);
			final Db db = await server.db;
			final DbCollection dbCollection = db.collection(name);
			final CreateIndexOptions indexOptions = CreateIndexOptions(dbCollection,
				uniqueIndex: index.unique,
				sparseIndex: index.sparse,
				indexName: indexName
			);
			final Map<String, Object>? rawOptions = index.expireAfterSeconds != null ? <String, Object>{'expireAfterSeconds': index.expireAfterSeconds!} : null;
			final CreateIndexOperation indexOperation = CreateIndexOperation(db, dbCollection, index.key, indexOptions, rawOptions: rawOptions);
			final Map<String, Object?> result = await indexOperation.execute();
			if (result['ok'] == 1.0) server.log('Index "$indexName" is created');
			else server.error('Unable to create index "$indexName": ${result['errmsg']}');
		}
	}
}

Future<void> _checkData(ServeMe<ServeMeClient> server, Map<String, CollectionDescriptor> collections) async {
	for (final String name in collections.keys) {
		final CollectionDescriptor collection = collections[name]!;
		if (collection.documents.isEmpty) continue;
		for (final Map<String, dynamic> document in collection.documents) {
			final Map<String, dynamic>? found = await (await server.db).collection(name).findOne(<String, dynamic>{'_id': document['_id']});
			if (found == null) {
				server.error('Mandatory document is missing in collection "$name": fixing...');
				await (await server.db).collection(name).insertOne(document);
				server.log('Document ID "${document['_id']}" added');
			}
		}
	}
}

Future<void> _checkMongoIntegrity(ServeMe<ServeMeClient> server, Map<String, CollectionDescriptor> collections) async {
	server.log('Checking database integrity...');
	await _checkCollections(server, collections);
	await _checkIndexes(server, collections);
	await _checkData(server, collections);
	server.log('Database integrity OK');
}