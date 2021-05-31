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

Map<Event, List<Function>> _eventHandlers = <Event, List<Function>>{};

void addEventHandler(Event event, Function(Map<String, dynamic> details) handler) {
	if (_eventHandlers[event] == null) _eventHandlers[event] = <Function>[];
	if (!_eventHandlers[event]!.contains(handler)) _eventHandlers[event]!.add(handler);
}

void removeEventHandler(Event event, Function(Map<String, dynamic> details) handler) {
	_eventHandlers[event]?.remove(handler);
}

Future<void> dispatchEvent(Event event, [Map<String, dynamic> details = const <String, dynamic>{}]) async {
	if (_eventHandlers[event] != null) {
		for (final Function handler in _eventHandlers[event]!) {
			try {
				await handler(details);
			}
			catch (err, stack) {
				error('Event handler execution error: $err', stack);
			}
		}
	}
}