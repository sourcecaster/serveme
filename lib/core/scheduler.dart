part of serveme;

class Task {
	Task(this.time, this.handler, {this.period, this.skip = false});

	late final Scheduler _scheduler;
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
		else _scheduler.discard(this);
		try {
			await handler(time);
		}
		catch (err, stack) {
			_scheduler._logger.error('Scheduled task execution error: $err', stack);
		}
		if (period != null && skip) {
			while (check(DateTime.now().toUtc())) time = time.add(period!);
			busy = false;
		}
	}
}

class Scheduler {
	Scheduler(this._logger) {
		addEventHandler(Event.tick, _process);
	}

	final Logger _logger;
	final List<Task> _tasks = <Task>[];

	void schedule(Task task) {
		task._scheduler = this;
		if (!_tasks.contains(task)) _tasks.add(task);
	}

	void discard(Task task) {
		_tasks.remove(task);
	}

	void _process(dynamic _) {
		final DateTime now = DateTime.now().toUtc();
		for (int i = _tasks.length - 1; i >= 0; i--) {
			if (_tasks[i].check(now) && !_tasks[i].busy) _tasks[i].execute();
		}
	}

	void dispose() {
		removeEventHandler(Event.tick, _process);
	}
}


