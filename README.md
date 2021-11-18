## What is ServeMe
ServeMe is a simple and powerful modular server framework. It allows to easily create backend services for both mobile and web applications. Here are some of the features provided by ServeMe framework:
* modular architecture allows to easily implement separate parts of the server using ServeMe Modular API;
* both WebSockets and TCP sockets are supported (TCP sockets support implemented in v1.1.0);
* MongoDB support out of the box, automatic database integrity validation for easy server deployment;
* events API allows to dispatch and listen to any built-in or custom events in your application;
* scheduler API allows to create different tasks and schedule its' execution time and period;
* logging, debug and error handling tools; 
* console API enables to handle custom server console commands (with autocomplete, command line format validation, command info etc.);
* using build-in or custom configuration files using Config API;
* client connections management, broadcasting messages by criteria, listening to data from clients globally or individually;
* it's integrated with [PackMe](https://pub.dev/packages/packme) binary serialization library for data transfer: it is very fast;
* possibility to implement complex data transfer protocols using JSON (compiled to [PackMe](https://pub.dev/packages/packme) messages .dart files);
* support of different message data types: String, Uint8List or [PackMe](https://pub.dev/packages/packme) messages;
* asynchronously query data using [PackMe](https://pub.dev/packages/packme) messages: SomeResponse response = await client.query(SomeRequest());

## Usage
Here the simplest example code of a server application based on ServeMe:
```dart
import 'package:serveme/serveme.dart';

Future<void> main() async {
    final ServeMe<ServeMeClient> server = ServeMe<ServeMeClient>();
    await server.run();
}
```
You should provide config.yaml (configuration file by default) in order to start the server.
```yaml
port: 8080
debug: true
debug_log: debug.log
error_log: error.log
```
It's ready to run! Though it does nothing at this point. Now we need to implement at least one Module file where something will actually happen. It's recommended to keep your project file structure clean and put all your module files in a separate "modules" directory.
Let's create some module which will listen for String messages from connected clients and echo them back:
```dart
class MyModule extends Module<ServeMeClient> {
    @override
    Future<void> init() async {
        await Future<void>.delayed(const Duration(seconds: 1)); // let's imitate some initialization process i.e. loading some data from Db
        server.log('Module initialized'); // logs message to console and debug.log file
    }
  
    @override
    void run() {
        server.listen<String>((String message, ServeMeClient client) async {
            log('Got a message: $message');
            client.send(message);
        });
    }
  
    @override
    Future<void> dispose() async {
        await Future<void>.delayed(const Duration(seconds: 1)); // doing all necessary cleanup before server shutdown
        server.log('Module disposed');
    }
}
```
Now we have a module but we also need to enable it in our configuration file:
```yaml
modules:
    - mymodule
```
Let's update our main function:
```dart
Future<void> main() async {
    final ServeMe<ServeMeClient> server = ServeMe<ServeMeClient>(
        modules: <String, Module<ServeMeClient>>{
            'mymodule': MyModule(),
        },
    );
    await server.run();
}
```
And it's ready! You can now connect to the server using your browser and test it out:
```javascript
let ws = new WebSocket('ws:// 127.0.0.1:8080');
ws.onmessage = console.log;
ws.send('Something');
```
It's possible to access one module from another via [] operator applied to server object:
```dart
class AnotherModule extends Module<ServeMeClient> {
    MyModule get myModule => server['mymodule']! as MyModule;

    @override
    Future<void> init() async {
        log('Here is our main module: $myModule');
    }
    
    // ...
}
```
And don't forget to enable your newly implemented modules in configuration file. 

## WebSockets and TCP sockets
ServeMe is using WebSockets by default. However it can handle pure TCP sockets as well:
```dart
Future<void> main() async {
    final ServeMe<ServeMeClient> server = ServeMe<ServeMeClient>(
        type: ServeMeType.tcp,
        modules: <String, Module<ServeMeClient>>{
            'mymodule': MyModule(),
        },
    );
    await server.run();
}
```
Keep in mind that String messages you will try to send via TCP sockets will be converted to Uint8List. So in order to receive String via TCP socket you need to use listen<Uint8List>() instead of listen<String>(). 

## Configuration files
By default ServeMe uses config.yaml file and ServeMeConfig class for instantiating config object accessible from any module. However it is possible to implement and use custom configuration class.
```dart
class MyConfig extends Config {
    MyConfig(String filename) : super(filename) {
        optionalNumber = cast<int?>(map['optional'], fallback: null);
        greetingMessage = cast<String>(map['greeting'], 
            errorMessage: 'Failed to load config: greeting message is not set'
        );
    }
  
    late final int? optionalNumber;
    late final String greetingMessage;
}
```
Method cast&lt;T&gt;() allows to easily cast dynamic variable into typed one with specified fallback value or exception error message. Now let's update our configuration file and see hot to use custom configuration class instead of default one.
```yaml
port: 8080
debug: true
debug_log: debug.log
error_log: error.log

optional: 42
greeting: Welcome, friend!

modules:
  - mymodule
```
```dart
Future<void> main() async {
    final ServeMe<ServeMeClient> server = ServeMe<ServeMeClient>(
        configFile: 'config.yaml',
        configFactory: (String filename) => MyConfig(filename),
        modules: <String, Module<ServeMeClient>>{
            'mymodule': MyModule(),
        },
    );
    await server.run();
}
```
Here's how to access custom config from the module:
```dart
class MyModule extends Module<ServeMeClient> {
    // ...
    
    @override
    MyConfig get config => super.config as MyConfig;  
  
    void printConfig() {
        log('optionalNumber: ${config.optionalNumber}, greetingMessage: ${config.greetingMessage}');  
    }
    
    // ...
}
```

## Establishing client connection to a remote server
ServeMe instance allows you to create client connection to a remote WebSocket or TCP server.
```dart
@override
Future<void> init() async {
    // Establish WebSocket connection to localhost
    final ServeMeClient wsConnectionClient = await server.connect(
        'ws://127.0.0.1:8080',
        onConnect: () => log('WebSocket connection established'),
        onDisconnect: () => log('Disconnected from WebSocket server'),
    );
    
    // Establish TCP socket connection to localhost
    final ServeMeClient tcpConnectionClient = await server.connect(
        InternetAddress('127.0.0.1', type: InternetAddressType.IPv4),
        port: 8177,
        onConnect: () => log('TCP connection established'),
        onDisconnect: () => log('Disconnected from TCP server'),
    );
}
```
Since server.connect() method returns an instance of ServeMeClient, all features such as sending/receiving PackMe messages and using asynchronous queries are available.

## Generic client class type
You probably already noticed that both classes ServeMe and Module have generic client class (&lt;ServeMeClient&gt; by default). It's used in some server properties and methods and it is possible to implement custom client class. Here's an example: 
```dart
import 'dart:io';

class MyClient extends ServeMeClient {
    MyClient(ServeMeSocket socket) : super(socket) {
        authToken = socket.httpRequest!.headers.value('x-auth-token');
    }

    late final String? authToken;
}
```
We've added some custom property authToken and in order to use this class instead of default it's necessary to set clientFactory property in ServeMe constructor:
```dart
Future<void> main() async {
    final ServeMe<MyClient> server = ServeMe<MyClient>(
        clientFactory: (_, __) => MyClient(_, __),
        modules: <String, Module<MyClient>>{
           'mymodule': MyModule(),
        },
    );
    await server.run();
}
```
Keep in mind that in this case all modules should be declared with the same generic class type.
```dart
class MyModule extends Module<MyClient> {
    // ...
    
    void echoAuthenticatedClients() {
        server.listen<String>((String message, MyClient client) async {
            if (client.authToken != 'some-valid-token') return;
            clent.send(message);
        });      
    }
    
    // ...
}
```

## Modules

Every module has three mandatory methods: init(), run() and dispose(). 
```dart
Future<void> init();
```
Asynchronous method init() is invoked on server start and usually used to preload all necessary data for module to be ready to run.   
```dart
void run();
```
Method run() is invoked after all modules have been successfully initialized. It's where modules start processing things and do its' job.
```dart
Future<void> dispose();
```
Asynchronous method dispose() is used on server shutdown to finish modules operation properly (when it's necessary). 

## Logs and errors
Every ServeMe module has access to three methods: log(), debug() and error().
```dart
Future<void> log(String message, [String color = _green]);
```
Method log() writes message to console and saves it to debug.log file (specified in configuration file).
```dart
Future<void> debug(String message, [String color = _reset]);
```
If debug is enabled in config then debug() writes message to console and saves it to log file.
```dart
Future<void> error(String message, [StackTrace? stack]);
```
Method error() logs error to console and writes it to error.log file (specified in configuration file).

## Console commands
By default there is a single command you can use in server console: stop - which shuts down the server. However it is possible to implement any other commands using console object accessible from modules:
```dart
@override
void run() {
    console.on('echo', (String line, List<String> args) async => log(line),
        aliases: <String>['say'], // optional
        similar: <String>['repeat', 'tell', 'speak'], // optional
        usage: 'echo <string>\nEchoes specified string (max 20 characters length)', // optional
        validator: RegExp(r'^.{1,20}$'), // optional
    );
}
```
This code will add echo command which allows to echo specified string no longer that 20 characters length.
* String line - command arguments string (without command itself);
* List&lt;String&gt; args - list of arguments
* aliases - use it if you need to assign multiple commands to the same command handler;
* similar - list of commands which won't be recognized as valid but a suggestion of original command will be displayed;
* usage - command format hint and/or short description which will be displayed if command format is invalid or command is used with --help key (or -h, -?, /?);
* validator - regular expression for arguments string validation.

## Events
ServeMe supports some built-in events:
* ReadyEvent - dispatched once all modules are initialized, right before invoking modules run() methods;
* TickEvent - dispatched every second;
* StopEvent - dispatched once server shutdown initiated (either by stop command or POSIX signal);
* LogEvent - dispatched on every message logging event;
* ErrorEvent - dispatched on errors;
* ConnectEvent - dispatched when incoming client connection established;
* DisconnectEvent - dispatched when client connection is closed.

You can subscribe to events using events object accessible from modules:
```dart
@override
void run() {
    events.listen<TickEvent>((TickEvent event) async {
        log('${event.counter} seconds passed since server start');
    });
}
```
It is also possible to implement own events and dispatch them when necessary. It's often very useful for interaction between different modules.
```dart
class AnnouncementEvent extends Event {
  AnnouncementEvent(this.message) : super();

  final String message;
}
```
Now you can dispatch AnnouncementEvent in one module and listen for it in another module.
```dart
// implemented in some module
void makeAnnouncement() {
    events.dispatch(AnnouncementEvent('Cheese for everyone!'));
}

// implemented in some another module
@override
void run() {
    events.listen<AnnouncementEvent>((AnnouncementEvent event) async {
        server.broadcast(event.message); // sends data to all connected clients
    });
}
```

## Scheduler
ServeMe allows to create and schedule tasks. There's a scheduler object accessible from modules:
```dart
class SomeModule extends Module<ServeMeClient> {
    late final Task task;
    
    @override
    Future<void> init() async {
        task = Task(
            DateTime.now()..add(const Duration(minutes: 1)),
                (DateTime time) async {
                log('Current time is $time');
            },
            period: const Duration(seconds: 10), // optional
            skip: false, // optional
        );
    }

    @override
    void run() {
        scheduler.schedule(task);
    }

    @override
    Future<void> dispose() async {
        scheduler.cancel(task);
    }
}
```
This module creates periodic Task which will be started in 1 minute. Note that task is cancelled on dispose.
* skip - if true then periodic task will be skipped till next time if previously returned Future is not resolved yet. Default value: false.

## Connections and data transfer
You can access all of your current client connections via clients object implemented in Module class:
```dart
@override
void run() {
    for (final ServeMeClient in server.clients) {
        // do something, don't use it for broadcasting however, use server.broadcast() instead
    }
}
```
It's always recommended to use [PackMe](https://pub.dev/packages/packme) messages for data exchange since it gives some important benefits such as clear communication protocol described in JSON, asynchronous queries support out of the box and small data packets size.
Here's a simple protocol.json file (located in packme directory) for some hypothetical client-server application (see PackMe JSON manifest format documentation [here](https://pub.dev/packages/packme)):
```json
{
    "get_user": [
        {
            "id": "string"
        },
        {
            "first_name": "string",
            "last_name": "string",
            "age": "uint8"
        }
    ]
}
```
Generate dart files:
```bash
# Usage: dart run packme <json_manifests_dir> <generated_classes_dir>
dart run packme packme generated
```
Before listening for any PackMe message from clients it is necessary to register message factory (which is created automatically and declared in generated dart file).
```dart
@override
void run() {
    // necessary for ServeMe to know how to parse incoming binary data
    server.register(protocolMessageFactory);
    server.listen<GetUserRequest>((GetUserRequest request, ServeMeClient client) {
        // GetUserRequest.$response method returns GetUserResponse associated with current request.
        final GetUserResponse response = request.$response(
            firstName: 'Alyx',
            lastName: 'Vance',
            age: 19,
        );
    });
}
```
This code listens for GetUserRequest message from clients and replies with GetUserResponse message. However sometimes it is useful to be able to add message listeners for some specific clients only, for example, logged in users only:
```dart
bool _isAuthorizedToDoSomething(String codePhrase) {
    return codePhrase == "I am Iron Man.";
}

@override
void run() {
    // Listen for some authorization request from connected clients.
    server.listen<AuthorizeRequest>((AuthorizeRequest request, ServeMeClient client) {
        if (_isAuthorizedToDoSomething(request.codePhrase)) {
            client.listen<GodModeRequest>(_handleGodModeRequest);
            client.listen<AllWeaponsRequest>(_handleAllWeaponsRequest);
            client.listen<KillEveryoneRequest>(_handleKillEveryoneRequest);
            client.send(request.$response(
                allowed: true,
                reason: 'Welcome on board!',
            ));
        }
        else {
            client.send(request.$response(
                allowed: false,
                reason: 'You are not Iron Man.',
            ));
            // Close client connection.
            client.close();
        }
    });
}
```
You could see in previous examples that request.$response() method is used instead of just instantiating corresponding ResponseMessage. It's made for assigning the response to this particular request which allows us to use .query() on client side (or server side, it doesn't matter once implementation is valid on the opposite side):
```dart
// let's for example obtain some data from clients once server is going offline
@override
Future<void> dispose() async {
    int ok = 0, notOk = 0;
    for (final ServeMeClient client in server.clients) {
        // in real life situation you probably want to use asynchronous calls in parallel
        final AreYouOkResponse response = await client.query<AreYouOkResponse>(AreYouOkRequest());
        if (response.ok) ok++;
        else notOk++;
    }
    server.log('$ok clients are OK and $notOk clients are not. Now ready for shutting down.');
}
```
Method broadcast() allows to send a message to all connected clients or to some clients filtered by some criteria:
```dart
// say good bye to all clients on server shut down
@override
Future<void> dispose() async {
    // Send a String message to all connected clients.
    server.broadcast(
        'See you later!', 
        (ServeMeClient client) => true // optional criteria filter
    );
}
```

## MongoDB
ServeMe uses [mongo_dart](https://pub.dev/packages/mongo_dart) package for MongoDB support. In order to use MongoDB in modules it's necessary to specify mongo config section of your configuration file:
```yaml
mongo:
    host: 127.0.0.1
    database: test_db
```
Or in case of using replica set:
```yaml
mongo:
    host: 
        - 192.160.1.101:27017
        - 192.160.1.102:27017
        - 192.160.1.103:27017
    database: test_db
    replica: myReplicaSet
```
There's an object db accessible from modules. This object is actually Future&lt;Db&gt;. Future is used to ensure that connection to database is alive and Db object is valid.
```dart
import 'package:mongo_dart/mongo_dart.dart';
```
```dart
late final List<Map<String, dynamic>> items;

@override
Future<void> init() async {
    // load all items within price range specified in config file
    items = await (await db).collection('users')
        .find(where.gte('price', config.minPrice).lte('price', config.maxPrice))
        .toList();
}
```

## Database integrity validation
Sometimes it's necessary to ensure that server database contains all necessary collections, indexes and data for server to work properly. For this purpose ServeMe provides special integrity descriptor. It allows you to automatically create missing indexes and create mandatory documents in database on server start. Aside from validation it also allows to deploy servers with ease without extra steps for setting up database.
```dart
Future<void> main() async {
    final ServeMe<ServeMeClient> server = ServeMe<ServeMeClient>(
        dbIntegrityDescriptor: <String, CollectionDescriptor>{
            'users': CollectionDescriptor(
                indexes: <String, IndexDescriptor>{
                    'login_unique': IndexDescriptor(key: <String, int>{'login': 1}, unique: true),
                    'email_unique': IndexDescriptor(key: <String, int>{'email': 1}, unique: true),
                    'session': IndexDescriptor(key: <String, int>{'sessions.key': 1}, unique: true),
                }
            ),
            'settings': CollectionDescriptor(
                indexes: <String, IndexDescriptor>{
                    'param_unique': IndexDescriptor(key: <String, int>{'param': 1}, unique: true),
                },
                documents: <Map<String, dynamic>>[
                    <String, dynamic>{
                        'param': 'online_users_limit',
                        'value': 5000,
                    },
                    <String, dynamic>{
                        'param': 'disable_email_login',
                        'value': false,
                    },
                ]
            ),
        },
        modules: <String, Module<ServeMeClient>>{
            'mymodule': MyModule(),
        },
    );
    await server.run();
}
```

## Supported platforms
It's available for Dart only. Currently there are no plans to implement it for any other language. However if developers will find this package useful then it may be implemented for Node.JS and C++ in the future.

## P.S.
I hope you enjoy it ;)