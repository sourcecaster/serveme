import 'dart:async';
import 'package:serveme/serveme.dart';

class MehModule extends Module {
	late Task _periodicShout;

	@override
	Future<void> init() async {
		_periodicShout = Task(DateTime.now(), (DateTime _) async {
			log('MehModule is alive!');
		}, period: const Duration(seconds: 2));
		scheduler.schedule(_periodicShout);
	}

	@override
	void run() {
		print('RUN RUN RUN RUN RUN!');
	}

	@override
	Future<void> dispose() async {
		scheduler.discard(_periodicShout);
	}
}

Future<void> main() async {
	final ServeMe server = ServeMe(
		configFile: 'example/example.yaml',
		modules: <String, Module>{
			'meh': MehModule()
		},
	);
	print(await server.run());
}