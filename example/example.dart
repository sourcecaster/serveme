import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:serveme/serveme.dart';

/// Implementing our own config class since we want to add some custom fields
/// to our configuration and load some custom data from main config file.

class MehConfig extends Config {
	MehConfig(String filename) : super(filename) {
		/// At this point we can access to Map<String, dynamic> map field.
		aliveNotification = map['meh_messages']['alive_notification'] as String;
		spamMessage = map['meh_messages']['spam_message'] as String;
	}

	late String aliveNotification; /// Should be final but we will modify it.
	late final String spamMessage;
}

/// Implementing our own client class since we might want to add some custom
/// functionality such as user authorization etc.

class MehClient extends Client {
	MehClient(WebSocket socket) : super(socket) {
		//if (socket.)
	}

	late final bool userIsLocal;
	bool userEnteredPassword = false;
}

/// Implementing our main example module. Note that in order to make server run
/// this module it must be enabled in configuration file.

class MehModule extends Module {
	late Task _periodicShout;
	late Task _webSocketSpam;

	/// Since we're using custom Config class then we better override it a bit
	/// just to make sure it returns MehConfig, not default Config.

	@override
	MehConfig get config => super.config as MehConfig;

	/// Method init() will be called once after MongoDB initialized. Server will
	/// await each module init() completion.

	@override
	Future<void> init() async {
		/// Declare tasks for scheduler
		_periodicShout = Task(DateTime.now(), (DateTime _) async {
			log(config.aliveNotification);
		}, period: const Duration(seconds: 3));
		_webSocketSpam = Task(DateTime.now(), (DateTime _) async {
			const Utf8Encoder encoder = Utf8Encoder();
			final Uint8List bytes = encoder.convert(config.spamMessage);
			server.broadcast(bytes);
		}, period: const Duration(seconds: 5));

		/// Once scheduled tasks will be processed until completed or discarded.
		scheduler.schedule(_periodicShout);
	}

	/// Method run() will be called once after all modules are initialized.
	/// Server will call run() method for all modules simultaneously.

	@override
	void run() {
		/// For the sake of example let's add some custom console command.
		console.on('setMessage',
			(String line, __) {
				/// Don't. It is a bad practice to modify config like this.
				config.aliveNotification = line;
				log('MehModule message is set to "$line"');
			},
			/// Using this regular expression to verify command line is correct.
			validator: RegExp(r'^.*\S+.*$'), /// At least 1 printable character.
			/// Message to be used to show command help.
			usage: 'setMessage <message>',
			/// These commands will work the same way as setMessage.
			aliases: <String>['setMsg', 'setNotification'],
			/// These commands will not be executed but a hint will be given.
			similar: <String>['set', 'message'],
		);

		log("MehModule is started. Apparently. Now let's spam them.");
		scheduler.schedule(_webSocketSpam);
	}

	/// Method dispose() will be called during server shutdown/restart process.
	/// Please do not forget to cancel your timers or subscriptions and release
	/// other resources in order to avoid memory leaks.

	@override
	Future<void> dispose() async {
		scheduler.discard(_periodicShout);
		scheduler.discard(_webSocketSpam);
	}
}

/// Note that server.run() method returns Future<bool> which might be handy in
/// some cases. It will return true if server initialization was successful and
/// false if initialization failed.

Future<void> main() async {
	final ServeMe server = ServeMe(
		/// Main configuration file extended with our own custom data.
		configFile: 'example/example.yaml',
		/// Tell server to use our own Config class.
		configFactory: (String filename) => MehConfig(filename),
		/// Tell server to use our own Client class.
		clientFactory: (WebSocket socket) => MehClient(socket),
		/// Pass our modules to server (don't forget to enable them in config).
		modules: <String, Module>{
			'meh': MehModule()
		},
	);

	final bool initializationResult = await server.run();
	print('Server initialization status: $initializationResult');
}