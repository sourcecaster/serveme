part of serveme;

class Task {
	Task(this.time, this.handler, {this.period, this.skip = false});

	DateTime time;
	final Future<void> Function(DateTime time) handler;
	final Duration? period;
	final bool skip;
	bool busy = false;

	bool check(DateTime now) {
		return now.millisecondsSinceEpoch >= time.millisecondsSinceEpoch;
	}

	Future<void> execute() async {
		if (period != null) {
			time = time.add(period!);
			if (skip) busy = true;
		}
		else unschedule(this);
		try {
			await handler(time);
		}
		catch (err, stack) {
			error('Scheduled task execution error: $err', stack);
		}
		if (period != null && skip) {
			while (check(DateTime.now().toUtc())) time = time.add(period!);
			busy = false;
		}
	}
}

final List<Task> _tasks = <Task>[];

void schedule(DateTime time, Future<void> Function(DateTime time) handler, {Duration? period, bool skip = false}) {
	_tasks.add(Task(time, handler, period: period, skip: skip));
}

void unschedule(Task task) {
	_tasks.remove(task);
}

void _process() {
	final DateTime now = DateTime.now().toUtc();
	for (int i = _tasks.length - 1; i >= 0; i--) {
		if (_tasks[i].check(now) && !_tasks[i].busy) _tasks[i].execute();
	}
}

void initScheduler() {
	addEventHandler(Event.tick, (_) => _process());
}