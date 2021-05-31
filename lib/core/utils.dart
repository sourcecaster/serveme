part of serveme;

const String RESET = '\x1b[0m';
const String BLACK = '\x1b[30m';
const String RED = '\x1b[31m';
const String GREEN = '\x1b[32m';
const String YELLOW = '\x1b[33m';
const String BLUE = '\x1b[34m';
const String MAGENTA = '\x1b[35m';
const String CYAN = '\x1b[36m';
const String WHITE = '\x1b[37m';

String dye(dynamic x) => x is String ? '$GREEN$x$RESET'
	: x is int || x is double || x is bool ? '$BLUE$x$RESET'
	: x is ObjectId ? '$MAGENTA${x.toHexString()}$RESET'
	: '$MAGENTA$x$RESET';

T cast<T>(dynamic x, {T? fallback, String? errorMessage}) {
	final T? result = x is T ? x
		: x == null ? null
		: T == double ? (
			x is int ? x.toDouble() as T
			: x is String ? double.tryParse(x) as T?
			: null
		)
		: T == int ? (
			x is double ? x.toInt() as T
			: x is String ? int.tryParse(x) as T?
			: null
		)
		: T == String ? x.toString() as T?
		: null;
	if (result == null && null is! T) {
		if (fallback != null) return fallback;
		else throw Exception(errorMessage ?? 'Unable to cast from ${x.runtimeType} to $T');
	}
	return result as T;
}