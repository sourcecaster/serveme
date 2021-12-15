part of serveme;

abstract class Event {
}

class ReadyEvent extends Event {
	ReadyEvent();
}

class TickEvent extends Event {
	TickEvent(this.counter);
	final int counter;
}

class StopEvent extends Event {
	StopEvent(this.signal, this.code);
	final ProcessSignal signal;
	final int code;
}

class LogEvent extends Event {
	LogEvent(this.message);
	final String message;
}

class ErrorEvent extends Event {
	ErrorEvent(this.message, [this.stack]);
	final String message;
	final StackTrace? stack;
}

class ConnectEvent<C extends ConnectMeClient> extends Event {
	ConnectEvent(this.client);
	final C client;
}

class DisconnectEvent<C extends ConnectMeClient> extends Event {
	DisconnectEvent(this.client);
	final C client;
}

class Events {
	Events(this._server) {
		int counter = 0;
		_timer = Timer.periodic(const Duration(seconds: 1), (_) {
			dispatch(TickEvent(++counter));
		});
	}

	late final Timer _timer;
	final ServeMe<ServeMeClient> _server;
	final Map<Type, List<Function>> _eventHandlers = <Type, List<Function>>{};

	void listen<T extends Event>(Future<void> Function(T) handler) {
		if (_eventHandlers[T] == null) _eventHandlers[T] = <Function>[];
		if (!_eventHandlers[T]!.contains(handler)) _eventHandlers[T]!.add(handler);
	}

	void cancel<T extends Event>(Future<void> Function(T) handler) {
		_eventHandlers[T]?.remove(handler);
	}

	Future<void> _tryExecute(Function handler, Event event) async {
		try {
			await handler(event);
		}
		catch (err, stack) {
			_server._logger.error('Event handler execution error: $err', stack);
		}
	}

	Future<void> dispatch(Event event) async {
		final List<Future<void>> futures = <Future<void>>[];
		if (_eventHandlers[event.runtimeType] != null) {
			for (final Function handler in _eventHandlers[event.runtimeType]!) {
				futures.add(_tryExecute(handler, event));
			}
		}
		await Future.wait(futures);
	}

	void dispose() {
		_timer.cancel();
	}
}