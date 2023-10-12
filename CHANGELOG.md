## v1.2.1
* PackMe upgraded to v2.0.1: object inheritance implemented, nested arrays support added.
* IMPORTANT: PackMe objects and enumerations from other JSON files are now referenced using filename: "some_user": "@filename:user". No changes required for references within the same file.

## v1.2.0
* Added support for binary type (uses Uint8List). Format: binary12, binary64 etc. - any buffer length in bytes.
* Example file is up to date now. (Message constructors require non-optional parameters).

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