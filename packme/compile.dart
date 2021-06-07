import 'dart:convert';
import 'dart:io';

const String RED = '\x1b[31m';
const String RESET = '\x1b[0m';

void fatal(String message) {
	print('$RED$message$RESET');
	exit(-1);
}

String validName(String input, {bool firstCapital = false}) {
	RegExp re = firstCapital ? RegExp(r'^[a-z]|[^a-zA-Z][a-z]') : RegExp(r'[^a-zA-Z\?][a-z]');
	String result = input.replaceAllMapped(re, (Match match) => match.group(0)!.toUpperCase());
	re = RegExp(r'[^a-zA-Z0-9]');
	result = result.replaceAll(re, '');
	return result;
}

class MessageField {
	MessageField(this.name, this.type, this.optional, this.array);

	final String name;
	final dynamic type;
	final bool optional;
	final bool array;

	String get _name => '$name${optional ? '!' : ''}';

	String get _type {
		switch (type) {
			case 'int8':
			case 'uint8':
			case 'int16':
			case 'uint16':
			case 'int32':
			case 'uint32':
			case 'int64':
			case 'uint64':
				return 'int';
			case 'float':
			case 'double':
				return 'double';
			case 'datetime':
				return 'DateTime';
			case 'string':
				return 'String';
			default:
				if (type is Message) return (type as Message).name;
				else throw Exception('Unknown data type "$type" for "$name"');
		}
	}

	String get _pack {
		switch (type) {
			case 'int8': return 'packInt8';
			case 'uint8': return 'packUint8';
			case 'int16': return 'packInt16';
			case 'uint16': return 'packUint16';
			case 'int32': return 'packInt32';
			case 'uint32': return 'packUint32';
			case 'int64': return 'packInt64';
			case 'uint64': return 'packUint64';
			case 'float': return 'packFloat';
			case 'double': return 'packDouble';
			case 'datetime': return 'packDateTime';
			case 'string': return 'packString';
			default:
				if (type is Message) return 'packMessage';
				else throw Exception('Unknown data type "$type" for "$name"');
		}
	}

	String get _unpack => 'un$_pack';

	String get declaration {
		if (!array) return '${optional ? '' : 'late '}$_type${optional ? '?' : ''} $name;';
		else return '${optional ? '' : 'late '}List<$_type>${optional ? '?' : ''} $name;';
	}

	List<String> get pack {
		final List<String> code = <String>[];
		if (!array) {
			code.add('		${optional ? 'if ($name != null) ' : ''}$_pack($_name);');
		}
		else {
			if (optional) code.add('		if ($name != null) {');
			code.add('		${optional ? '	' : ''}packUint32($_name.length);');
			code.add('		${optional ? '	' : ''}$_name.forEach($_pack);');
			if (optional) code.add('		}');
		}
		return code;
	}

	List<String> get unpack {
		final List<String> code = <String>[];
		final String ending = type is Message ? '(${type.name}()) as ${type.name}' : '()';
		if (!array) {
			code.add('		$name = $_unpack$ending;');
		}
		else {
			if (optional) code.add('		$name = <$_type>[];');
			code.add('		for (int i = 0; i < unpackUint32(); i++) {');
			code.add('			$_name.add($_unpack$ending);');
			code.add('		}');
		}
		return code;
	}
}

class Message {
	Message(this.name, this.manifest);

	final String name;
	final Map<String, dynamic> manifest;

	final List<String> code = <String>[];
	final List<Message> nested = <Message>[];

	void parse() {
		final Map<String, MessageField> fields = <String, MessageField>{};
		for (final MapEntry<String, dynamic> entry in manifest.entries) {
			final String fieldName = validName(entry.key);
			if (fieldName.isEmpty) throw Exception('Field name declaration "${entry.key}" is invalid for "$name"');
			if (fields[fieldName] != null) throw Exception('Message field name "$fieldName" is duplicated for message "$name".');
			final bool optional = entry.key[0] == '?';
			final bool array = entry.value is List;
			if (array && entry.value.length != 1) throw Exception('Array declarations must contain one single type: "${entry.value}" is invalid for field "$fieldName" of "$name"');
			dynamic value = array ? entry.value[0] : entry.value;
			if (value is Map) {
				String postfix = validName(entry.key, firstCapital: true);
				if (array && postfix[postfix.length - 1] == 's') postfix = postfix.substring(0, postfix.length - 1);
				nested.add(value = Message('$name$postfix', value as Map<String, dynamic>));
			}
			fields[fieldName] = MessageField(fieldName, value, optional, array);
		}
		code.add('class $name extends PackMeMessage {');
		for (final MessageField field in fields.values) code.add('	${field.declaration}');
		code.add('	');
		code.add('	@override');
		code.add('	void pack() {');
		for (final MessageField field in fields.values) code.addAll(field.pack);
		code.add('	}');
		code.add('	');
		code.add('	@override');
		code.add('	void unpack() {');
		for (final MessageField field in fields.values) code.addAll(field.unpack);
		code.add('	}');
		code.add('	');
		code.add('}');
		code.add('');
	}

	List<String> output() {
		final List<String> result = <String>[];
		parse();
		for (final Message message in nested) {
			result.addAll(message.output());
		}
		result.addAll(code);
		return result;
	}
}

final Map<int, Message> messages = <int, Message>{};
late final String outputFilename;

void parseCommands(Map<String, dynamic> node) {
	for (final MapEntry<String, dynamic> entry in node.entries) {
		final String commandName = validName(entry.key, firstCapital: true);
		final String commandNameRequest = '${commandName}Request';
		final String commandNameResponse = '${commandName}Response';
		final int hashRequest = commandNameRequest.hashCode;
		final int hashResponse = commandNameResponse.hashCode;
		if (commandName.isEmpty) {
			throw Exception('Command name must be adequate :) "${entry.key}" is not.');
		}
		if (entry.value is! List || entry.value.length != 2 || entry.value[0] is! Map || entry.value[1] is! Map) {
			throw Exception('Command "$commandName" declaration is invalid. Must be two objects (request and response) in array.');
		}
		if (messages[hashRequest] != null) {
			throw Exception('Message name "$commandNameRequest" is duplicated. Or hash code turned out to be the same as for "${messages[hashRequest]!.name}".');
		}
		if (messages[hashResponse] != null) {
			throw Exception('Message name "$commandNameResponse" is duplicated. Or hash code turned out to be the same as for "${messages[hashResponse]!.name}".');
		}
		messages[hashRequest] = Message(commandNameRequest, entry.value[0] as Map<String, dynamic>);
		messages[hashResponse] = Message(commandNameResponse, entry.value[1] as Map<String, dynamic>);
	}
}

void writeOutput() {
	final List<String> out = <String>[];
	out.add("import 'package:serveme/core/packme.dart';");
	out.add('');
	for (final Message message in messages.values) {
		out.addAll(message.output());
	}
	out.add('final Map<int, PackMeMessage Function()> messageFactory = <int, PackMeMessage Function()>{');
	for (final MapEntry<int, Message> entry in messages.entries) {
		out.add('	${entry.key}: () => ${entry.value.name}(),');
	}
	out.add('};');
	File(outputFilename).writeAsStringSync(out.join('\n'));
}

void main(List<String> args) {
	if (args.isEmpty) fatal('Manifest filename is missing.');
	outputFilename = 'example/generated/example.generated.dart';
	late final String json;
	try {
		json = File(args[0]).readAsStringSync();
	}
	catch (err) {
		fatal('Unable to open manifest file: $err');
	}
	const JsonDecoder decoder = JsonDecoder();
	late final Map<String, dynamic> manifest;
	try {
		manifest = decoder.convert(json) as Map<String, dynamic>;
	}
	catch (err) {
		fatal('Unable to parse JSON: $err');
	}
	try {
		parseCommands(manifest);
	}
	catch (err) {
		fatal('An error occurred while processing manifest: $err');
	}
	try {
		writeOutput();
	}
	catch (err) {
		fatal('An error occurred while writing output file: $err');
	}
}