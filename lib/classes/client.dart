part of serveme;

class Client {
	Client(this.socket, this.headers) {
		// socket.listen((dynamic event) {
		// });
	}

	late ServeMe _server;
	final Map<Type, List<Function>> _handlers = <Type, List<Function>>{};
	final WebSocket socket;
	final HttpHeaders headers;

	void send(dynamic data) {
		Uint8List? bytes;
		if (data is PackMeMessage) bytes = _server._packMe.pack(data);
		else if (data is Uint8List) bytes = data;
		else if (data is String) bytes = const Utf8Encoder().convert(data);
		else _server.error('Unsupported data type for Client.send, only PackMeMessage, Uint8List and String are supported');
		if (bytes != null) socket.add(bytes);
	}

	void listen<T>(Function(T) handler) {
		if (_handlers[T] == null) _handlers[T] = <Function>[];
		_handlers[T]!.add(handler);
	}
}