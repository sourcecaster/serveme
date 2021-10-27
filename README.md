## What is ServeMe
ServeMe is a simple and powerful modular server framework. It allows to easily create backend servers for both mobile and web applications. Here are some of the features provided by ServeMe framework:
* modular architecture allows to easily implement separate parts of the server using ServeMe Modular API;
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
    Future<void> run() async {
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

## Configuration files
By default ServeMe uses config.yaml file and ServeMeConfig class for instantiating config object accessible from any module. However it is possible to implement and use custom configuration class.
```dart
class MyConfig extends Config {
    MyConfig(String filename) : super(filename) {
        optionalNumber = cast<int?>(map['optional'], fallback: null);
        greetingMessage = cast<String>(map['greeting'], errorMessage: 'Failed to load config: greeting message is not set');
    }
  
    late final int? optionalNumber;
    late final String greetingMessage;
}
```

Method cast<T>() allows to easily cast dynamic variable into typed one with specified fallback value or exception error message. Now let's update our configuration file and see hot to use custom configuration class instead of default one.
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
        log('MyConfig parameters: optionalNumber = ${config.optionalNumber}, greetingMessage = ${config.greetingMessage}');  
    }
    
    // ...
}
```

## Modules

## Logs and errors

## Events

## Scheduler

## Connections and data transfer

## MongoDB