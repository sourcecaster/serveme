part of serveme;

late Console console;

class CommandHandler {
	CommandHandler({required this.function, this.validator, this.usage});

	final Function(String, List<String>) function;
	final RegExp? validator;
	final String? usage;
}

class Console {
	final Map<String, CommandHandler> handlers = <String, CommandHandler>{};
	final Map<String, String> similar = <String, String>{};
	final List<String> history = <String>[''];

	String line = '';
	int pos = 0;
	int row = 0;
	RegExp? search;
	int index = 0;
	final List<String> matches = <String>[];

	void on(String command, Function(String string, List<String> args) handler, {RegExp? validator, String? usage, List<String>? aliases, List<String>? similar}) {
		final CommandHandler commandHandler = CommandHandler(
			function: handler,
			validator: validator,
			usage: usage,
		);
		handlers[command] = commandHandler;
		if (aliases != null) for (final String alias in aliases) handlers[alias] = commandHandler;
		if (similar != null) for (final String str in similar) this.similar[str] = command;
	}

	void process(String line) {
		line = line.trim();
		if (line.isEmpty) return;
		log('> $line', YELLOW);
		final List<String> args = line.split(RegExp('\\s+'));
		final String command = args[0];
		final CommandHandler? handler = handlers[command];
		if (handler != null) {
			args.removeAt(0);
			line = args.join(' ');
			if (args.isNotEmpty && <String>['-h', '--help', '-?', '/?'].contains(args[0])) {
				if (handler.usage != null) log('Usage: ${handler.usage}', CYAN);
				else log('No usage info available for: $command', CYAN);
			}
			else {
				final bool valid = handler.validator == null || handler.validator!.hasMatch(line);
				if (valid) handler.function(line, args);
				else if (handler.usage != null) log('Usage: ${handler.usage}', CYAN);
			}
		}
		else log('Unknown command: $command' + (similar[command] != null ? '. Did you mean "${similar[command]}"?' : ''), CYAN);
	}

	void previous() {
		if (row > 0) {
			line = history[--row];
			pos = line.length;
		}
	}

	void next() {
		if (row < history.length - 1) {
			line = history[++row];
			pos = line.length;
		}
	}

	void reset() {
		history..last = line..add(line = '');
		pos = 0;
		if (history.length > 100) history.removeAt(0);
		row = history.length - 1;
		search = null;
	}

	void key(List<int> input) {
		if (input[0] == 10 || input[0] == 13) {
			final String cmd = line;
			reset();
			update();
			process(cmd);
		}
		else if (input[0] == 9) {
			if (search == null) {
				search = RegExp('^${RegExp.escape(line)}');
				matches.clear();
				for (final String cmd in handlers.keys) {
					if (search!.hasMatch(cmd)) matches.add(cmd);
				}
				matches.sort();
				index = 0;
			}
			if (matches.isNotEmpty) {
				line = matches[index++] + ' ';
				pos = line.length;
				if (index >= matches.length) index = 0;
			}
		}
		else if (input[0] == 5) previous();
		else if (input[0] == 24) next();
		else if (input[0] == 27) {
			if (input[1] == 91) {
				if (input[2] == 68) if (pos > 0) pos--;
				if (input[2] == 67) if (pos < line.length) pos++;
				if (input[2] == 49) pos = 0;
				if (input[2] == 52) pos = line.length;
				if (input[2] == 51) {
					if (pos < line.length) line = line.replaceRange(pos, pos + 1, '');
					search = null;
				}
				if (input[2] == 65) previous();
				if (input[2] == 66) next();
			}
		}
		else if (input[0] == 8 || input[0] == 127) {
			if (pos > 0) {
				line = line.replaceRange(pos - 1, pos, '');
				pos--;
				search = null;
			}
		}
		else if (input[0] >= 32) {
			final String char = String.fromCharCodes(input);
			line = line.replaceRange(pos, pos, char);
			pos += char.length;
			search = null;
		}
		update();
	}

	void update() {
		final int maxLen = stdout.terminalColumns - 3;
		final int offset = min(pos, max(0, line.length - maxLen));
		final String lineCapped = line.substring(offset, min(line.length, offset + maxLen));
		stdout.write('\r> $lineCapped' + ' ' * (maxLen - line.length) + '\r\x1b[${pos - offset + 2}C');
	}
}

Future<void> initConsole() async {
	console = Console();
	stdin.echoMode = false;
	stdin.lineMode = false;
	stdin.listen(console.key);
}