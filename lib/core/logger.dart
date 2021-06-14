part of serveme;

class Logger {
	Logger(this._server) {
		try {
			_debugFile = File(_server.config._debugLog).openSync(mode: FileMode.writeOnlyAppend);
		}
		catch (err) {
			error('Unable to write debug log file: $err');
		}
		try {
			_errorFile = File(_server.config._errorLog).openSync(mode: FileMode.writeOnlyAppend);
		}
		catch (err) {
			error('Unable to write error log file: $err');
		}
		errorsCountReduceTimer = Timer.periodic(const Duration(minutes: 1), (_) {
			if (errorsCount > 0) errorsCount -= min(errorsCount, 100);
		});
	}

	static const String _reset = '\x1b[0m';
	static const String _red = '\x1b[31m';
	static const String _green = '\x1b[32m';
	static const String _clear = '\x1b[999D\x1b[K';

	final ServeMe<ServeMeClient> _server;
	Future<void> _debugPromise = Future<void>.value(null);
	Future<void> _errorPromise = Future<void>.value(null);
	RandomAccessFile? _debugFile;
	RandomAccessFile? _errorFile;
	late Timer errorsCountReduceTimer;
	int errorsCount = 0;

	Future<void> log(String message, [String color = _green]) async {
		final String time = DateTime.now().toUtc().toString().replaceFirst(RegExp(r'\..*'), '');
		_server._events.dispatch(LogEvent(message));
		stdout.write(_clear);
		print('$color${time.replaceFirst(RegExp('.* '), '')}: $message$_reset');
		_server.console.update();
		if (_debugFile != null) {
			Future<void> func(void _) => _debugFile!.writeString('$time - $message\n');
			_debugPromise = _debugPromise.then(func);
			await _debugPromise;
		}
	}

	Future<void> debug(String message, [String color = _reset]) async {
		if (_server.config._debug) await log(message, color);
	}

	Future<void> error(String message, [StackTrace? stack]) async {
		errorsCount++;
		if (errorsCount >= 1000) {
			if (errorsCount == 1000) {
				message = 'Too many errors, error processing is suspended';
				stack = null;
			}
			else return;
		}
		final String time = DateTime.now().toUtc().toString().replaceFirst(RegExp(r'\..*'), '');
		_server._events.dispatch(ErrorEvent(message, stack));
		stdout.write(_clear);
		print('$_red${time.replaceFirst(RegExp('.* '), '')}: $message$_reset');
		_server.console.update();
		if (_errorFile != null) {
			Future<void> func(void _) => _errorFile!.writeString('$time - $message\n${stack.toString()}\n');
			_errorPromise = _errorPromise.then(func);
			await _errorPromise;
		}
		if (_server.config.debug && _debugFile != null) {
			Future<void> func(void _) => _debugFile!.writeString('$time - $message\n');
			_debugPromise = _debugPromise.then(func);
			await _debugPromise;
		}
	}

	Future<void> dispose() async {
		errorsCountReduceTimer.cancel();
		await Future.wait(<Future<void>>[_debugPromise, _errorPromise]);
		if (_debugFile != null) _debugFile!.closeSync();
		if (_errorFile != null) _errorFile!.closeSync();
	}
}