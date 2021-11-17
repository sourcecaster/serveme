import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:connectme/connectme.dart';
import 'package:serveme/serveme.dart';
import 'package:test/test.dart';
import 'generated/test.generated.dart';
import 'modules/test.dart';

const Utf8Codec _utf8 = Utf8Codec();

void main() {
    late ServeMe<ServeMeClient> server;
    late ConnectMeClient client;
    late Timer timer;
    late TestModule module;

    group('Connection tests', () {
        test('ServeMe.run() and ConnectMe.connect()', () async {
            timer = Timer(const Duration(seconds: 2), () => fail('Operation timed out'));
            server = ServeMe<ServeMeClient>(
                configFile: 'test/config_test.yaml',
                modules: <String, Module<ServeMeClient>>{
                    'test': module = TestModule(),
                },
            );
            await server.run();
            module.events.listen<ConnectEvent<ServeMeClient>>(expectAsync1<Future<void>, dynamic>((dynamic event) async {
                expect(event.client, isA<ServeMeClient>());
            }));
            module.events.listen<DisconnectEvent<ServeMeClient>>(expectAsync1<Future<void>, dynamic>((dynamic event) async {
                expect(event.client, isA<ServeMeClient>());
            }));
            client = await ConnectMe.connect('ws://127.0.0.1:31337',
                onConnect: expectAsync0<void>(() {}),
            );
            await client.close();
            await server.stop();
            timer.cancel();
        });
    });

    group('ServeMe WebSocket data exchange tests', () {
        setUp(() async {
            timer = Timer(const Duration(seconds: 2), () => fail('Operation timed out'));
            server = ServeMe<ServeMeClient>(
                configFile: 'test/config_test.yaml',
                modules: <String, Module<ServeMeClient>>{
                    'test': module = TestModule(),
                },
            );
            await server.run();
            client = await ConnectMe.connect('ws://127.0.0.1:31337');
        });

        tearDown(() async {
            await client.close();
            await server.stop();
            timer.cancel();
        });

        test('Client sends String to server', () async {
            final Completer<String> completer = Completer<String>();
            server.listen<String>((String message, ConnectMeClient client) async {
                completer.complete(message);
            });
            client.send('Test message from client');
            expect(await completer.future, 'Test message from client');
        });

        test('Server broadcasts String to clients', () async {
            final Completer<String> completer = Completer<String>();
            client.listen<String>((String message) {
                completer.complete(message);
            });
            server.broadcast('Test message from server');
            expect(await completer.future, 'Test message from server');
        });

        test('Client sends Uint8List to server', () async {
            final Completer<Uint8List> completer = Completer<Uint8List>();
            server.listen<Uint8List>((Uint8List message, ConnectMeClient client) async {
                completer.complete(message);
            });
            client.send(Uint8List.fromList(<int>[3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]));
            expect(await completer.future, Uint8List.fromList(<int>[3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]));
        });

        test('Server broadcasts Uint8List to clients', () async {
            final Completer<Uint8List> completer = Completer<Uint8List>();
            client.listen<Uint8List>((Uint8List message) {
                completer.complete(message);
            });
            server.broadcast(Uint8List.fromList(<int>[3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]));
            expect(await completer.future, Uint8List.fromList(<int>[3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]));
        });

        test('Client sends TestResponse query to server', () async {
            server.register(testMessageFactory);
            server.listen<TestRequest>((TestRequest request, ConnectMeClient client) async {
                client.send(request.$response(responseParam: request.requestParam));
            });
            client.register(testMessageFactory);
            final TestResponse response = await client.query<TestResponse>(TestRequest(requestParam: 3.1415926535));
            expect(response.responseParam, 3.1415926535);
        });

        test('Server sends TestResponse query to client', () async {
            client.register(testMessageFactory);
            client.listen<TestRequest>((TestRequest request) {
                client.send(request.$response(responseParam: request.requestParam));
            });
            server.register(testMessageFactory);
            final TestResponse response = await server.clients.first.query<TestResponse>(TestRequest(requestParam: 3.1415926535));
            expect(response.responseParam, 3.1415926535);
        });
    });

    group('ServeMe TCP data exchange tests', () {
        setUp(() async {
            timer = Timer(const Duration(seconds: 2), () => fail('Operation timed out'));
            server = ServeMe<ServeMeClient>(
                type: ServeMeType.tcp,
                configFile: 'test/config_test.yaml',
                modules: <String, Module<ServeMeClient>>{
                    'test': module = TestModule(),
                },
            );
            await server.run();
            client = await ConnectMe.connect('127.0.0.1', port: 31337);
        });

        tearDown(() async {
            await client.close();
            await server.stop();
            timer.cancel();
        });

        test('Client sends String to server', () async {
            final Completer<Uint8List> completer = Completer<Uint8List>();
            server.listen<Uint8List>((Uint8List message, ConnectMeClient client) async {
                completer.complete(message);
            });
            client.send('Test message from client');
            final List<int> expected = _utf8.encode('Test message from client');
            expect(await completer.future, expected);
        });

        test('Server broadcasts String to clients', () async {
            final Completer<Uint8List> completer = Completer<Uint8List>();
            client.listen<Uint8List>((Uint8List message) {
                completer.complete(message);
            });
            server.broadcast('Test message from server');
            final List<int> expected = _utf8.encode('Test message from server');
            expect(await completer.future, expected);
        });

        test('Client sends Uint8List to server', () async {
            final Completer<Uint8List> completer = Completer<Uint8List>();
            server.listen<Uint8List>((Uint8List message, ConnectMeClient client) async {
                completer.complete(message);
            });
            client.send(Uint8List.fromList(<int>[3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]));
            expect(await completer.future, Uint8List.fromList(<int>[3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]));
        });

        test('Server broadcasts Uint8List to clients', () async {
            final Completer<Uint8List> completer = Completer<Uint8List>();
            client.listen<Uint8List>((Uint8List message) {
                completer.complete(message);
            });
            server.broadcast(Uint8List.fromList(<int>[3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]));
            expect(await completer.future, Uint8List.fromList(<int>[3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]));
        });

        test('Client sends TestResponse query to server', () async {
            server.register(testMessageFactory);
            server.listen<TestRequest>((TestRequest request, ConnectMeClient client) async {
                client.send(request.$response(responseParam: request.requestParam));
            });
            client.register(testMessageFactory);
            final TestResponse response = await client.query<TestResponse>(TestRequest(requestParam: 3.1415926535));
            expect(response.responseParam, 3.1415926535);
        });

        test('Server sends TestResponse query to client', () async {
            client.register(testMessageFactory);
            client.listen<TestRequest>((TestRequest request) {
                client.send(request.$response(responseParam: request.requestParam));
            });
            server.register(testMessageFactory);
            final TestResponse response = await server.clients.first.query<TestResponse>(TestRequest(requestParam: 3.1415926535));
            expect(response.responseParam, 3.1415926535);
        });
    });

    group('ServeMe API tests', () {
        setUp(() async {
            timer = Timer(const Duration(seconds: 2), () => fail('Operation timed out'));
            server = ServeMe<ServeMeClient>(
                configFile: 'test/config_test.yaml',
                modules: <String, Module<ServeMeClient>>{
                    'test': module = TestModule(),
                },
            );
            await server.run();
        });

        tearDown(() async {
            await server.stop();
            timer.cancel();
        });

        test('TickEvent dispatch and handle', () async {
            module.events.listen<TickEvent>(expectAsync1<Future<void>, dynamic>((dynamic event) async {
                expect(event, isA<TickEvent>());
            }));
        });

        test('Scheduler', () async {
            final Task task = Task(DateTime.now(), expectAsync1<Future<void>, dynamic>((dynamic time) async {
                expect(time, isA<DateTime>());
            }));
            module.scheduler.schedule(task);
        });
    });
}