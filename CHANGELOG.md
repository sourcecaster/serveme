## v1.1.3
* Bugfix: concurrent modifications during iteration occurred in some cases while processing events.

## v1.1.2
* Bugfix: expireAfterSeconds option for IndexDescriptor of CollectionDescriptor was ignored.

## v1.1.1
* Maximum data length increased to 2^63 for messages sent over TCP socket.
* Bugfix: data messages sent over TCP socket could stall in some cases.

## v1.1.0
* TCP sockets support implemented (breaking changes).
* ServeMeClient constructor now takes single ServeMeSocket argument.
* Future<ServeMeClient> ServeMe.connect() method added allowing to create WebSocket or TCP client connections (with the same functionality as server client connections).

## v1.0.2
* Bugfix: ESC key press caused ServeMe to crash on Linux.

## v1.0.1
* Small fixes in ReadMe file.

## v1.0.0
* Finally released.