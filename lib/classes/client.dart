part of serveme;

class Client {
	Client(this.socket, this.headers);

	late ServeMe _server;
	final WebSocket socket;
	final HttpHeaders headers;

	void send(dynamic data) {
		if (data is PackMeMessage) {
			final Uint8List? packed = _server._packMe.pack(data);
			if (packed != null) socket.add(packed);
		}
		else if (data is Uint8List) socket.add(data);
		else if (data is String) {
			const Utf8Encoder encoder = Utf8Encoder();
			socket.add(encoder.convert(data));
		}
		else _server.error('Unsupported data type for Client.send, only PackMeMessage, Uint8List and String are supported');
	}
}