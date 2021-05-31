part of serveme;

class Client {
	Client(this.socket);

	final WebSocket socket;

	void send(Uint8List data) {
		socket.add(data);
	}
}