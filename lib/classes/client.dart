part of serveme;

class Client {
	Client(this.socket, this.headers) {
		socket.listen((dynamic data) {
			if (data is Uint8List) {
				final PackMeMessage? message = _server._packMe.unpack(data);
				if (message != null) data = message;
			}
			if (_handlers[data.runtimeType] != null) {
				for (final Function handler in _handlers[data.runtimeType]!) _processHandler(handler, data);
			}
		}, onDone: () {
			_server._clients.remove(this);
		});
	}

	late ServeMe _server;
	final Map<Type, List<Function>> _handlers = <Type, List<Function>>{};
	final WebSocket socket;
	final HttpHeaders headers;

	Future<void> _processHandler(Function handler, dynamic data) async {
		try {
			await handler(data);
		}
		catch (err, stack) {
			_server._logger.error('WebSocket message handler execution error: $err', stack);
		}
	}

	void send(dynamic data) {
		if (data is PackMeMessage) data = _server._packMe.pack(data);
		else if (data is! Uint8List && data is! String) {
			_server.error('Unsupported data type for Client.send, only PackMeMessage, Uint8List and String are supported');
			return;
		}
		if (data != null) socket.add(data);
	}

	void listen<T>(Future<void> Function(T) handler) {
		if (_handlers[T] == null) _handlers[T] = <Function>[];
		_handlers[T]!.add(handler);
	}

	void cancel<T>(Future<void> Function(T) handler) {
		_handlers[T]?.remove(handler);
	}
}