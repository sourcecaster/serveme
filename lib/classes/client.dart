part of serveme;

class Client {
	Client(this.socket, this.headers);

	final WebSocket socket;
	final HttpHeaders headers;

	void send(Uint8List data) {
		socket.add(data);
	}
}