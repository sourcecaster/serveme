part of serveme;

enum Event {
	ready,
	tick,
	stop,
	log,
	error,
	connect,
	disconnect,
}

class Events {
	Events(this._server) {
		_timer = Timer.periodic(const Duration(seconds: 1), (_) {
			dispatch(Event.tick);
		});
	}

	late final Timer _timer;
	final ServeMe _server;
	final Map<Event, List<Function>> _eventHandlers = <Event, List<Function>>{};

	void listen(Event event, Function(Map<String, dynamic> details) handler) {
		if (_eventHandlers[event] == null) _eventHandlers[event] = <Function>[];
		if (!_eventHandlers[event]!.contains(handler)) _eventHandlers[event]!.add(handler);
	}

	void cancel(Event event, Function(Map<String, dynamic> details) handler) {
		_eventHandlers[event]?.remove(handler);
	}

	Future<void> dispatch(Event event, [Map<String, dynamic> details = const <String, dynamic>{}]) async {
		if (_eventHandlers[event] != null) {
			for (final Function handler in _eventHandlers[event]!) {
				try {
					await handler(details);
				}
				catch (err, stack) {
					_server._logger.error('Event handler execution error: $err', stack);
				}
			}
		}
	}

	void dispose() {
		_timer.cancel();
	}
}