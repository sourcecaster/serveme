import 'dart:convert';
import 'dart:typed_data';

const Utf8Codec _utf8 = Utf8Codec();

abstract class PackMeMessage {
	int offset = 0;
	Uint8List? data;
	final List<int> flags = <int>[];
	int _bitNumber = 0;

	int estimate();
	void pack();
	void unpack();

	void setFlag(bool on) {
		final int index = _bitNumber ~/ 8;
		if (index >= flags.length) flags.add(0);
		if (on) flags[index] |= 1 << (_bitNumber % 8);
		_bitNumber++;
	}
	bool getFlag() {
		final int index = _bitNumber ~/ 8;
		final bool result = (flags[index] >> (_bitNumber % 8)) & 1 == 1;
		_bitNumber++;
		return result;
	}

	int stringBytes(String value) {
		final Uint8List bytes = _utf8.encoder.convert(value);
		return 4 + bytes.length;
	}

	void packMessage(PackMeMessage message) {
		message.data = data;
		message.offset = offset;
		message.pack();
		offset = message.offset;
	}
	PackMeMessage unpackMessage(PackMeMessage message) {
		message.data = data;
		message.offset = offset;
		message.unpack();
		offset = message.offset;
		return message;
	}

	void packInt8(int value) {
		data!.buffer.asByteData().setInt8(offset, value);
		offset++;
	}
	void packInt16(int value) {
		data!.buffer.asByteData().setInt16(offset, value, Endian.big);
		offset += 2;
	}
	void packInt32(int value) {
		data!.buffer.asByteData().setInt32(offset, value, Endian.big);
		offset += 4;
	}
	void packInt64(int value) {
		data!.buffer.asByteData().setInt64(offset, value, Endian.big);
		offset += 8;
	}
	void packUint8(int value) {
		data!.buffer.asByteData().setUint8(offset, value);
		offset++;
	}
	void packUint16(int value) {
		data!.buffer.asByteData().setUint16(offset, value, Endian.big);
		offset += 2;
	}
	void packUint32(int value) {
		data!.buffer.asByteData().setUint32(offset, value, Endian.big);
		offset += 4;
	}
	void packUint64(int value) {
		data!.buffer.asByteData().setUint64(offset, value, Endian.big);
		offset += 8;
	}
	void packFloat(double value) {
		data!.buffer.asByteData().setFloat32(offset, value, Endian.big);
		offset += 4;
	}
	void packDouble(double value) {
		data!.buffer.asByteData().setFloat64(offset, value, Endian.big);
		offset += 8;
	}
	void packDateTime(DateTime value) {
		data!.buffer.asByteData().setUint64(offset, value.millisecondsSinceEpoch, Endian.big);
		offset += 8;
	}
	void packString(String value) {
		final Uint8List bytes = _utf8.encoder.convert(value);
		data!.buffer.asByteData().setUint32(offset, bytes.length, Endian.big);
		offset += 4;
		for (int i = 0; i < bytes.length; i++) {
			data!.buffer.asByteData().setInt8(offset++, bytes[i]);
		}
	}

	int unpackInt8() {
		final int value = data!.buffer.asByteData().getInt8(offset);
		offset++;
		return value;
	}
	int unpackInt16() {
		final int value = data!.buffer.asByteData().getInt16(offset, Endian.big);
		offset += 2;
		return value;
	}
	int unpackInt32() {
		final int value = data!.buffer.asByteData().getInt32(offset, Endian.big);
		offset += 4;
		return value;
	}
	int unpackInt64() {
		final int value = data!.buffer.asByteData().getInt64(offset, Endian.big);
		offset += 8;
		return value;
	}
	int unpackUint8() {
		final int value = data!.buffer.asByteData().getUint8(offset);
		offset++;
		return value;
	}
	int unpackUint16() {
		final int value = data!.buffer.asByteData().getUint16(offset, Endian.big);
		offset += 2;
		return value;
	}
	int unpackUint32() {
		final int value = data!.buffer.asByteData().getUint32(offset, Endian.big);
		offset += 4;
		return value;
	}
	int unpackUint64() {
		final int value = data!.buffer.asByteData().getUint64(offset, Endian.big);
		offset += 8;
		return value;
	}
	double unpackFloat() {
		final double value = data!.buffer.asByteData().getFloat32(offset, Endian.big);
		offset += 4;
		return value;
	}
	double unpackDouble() {
		final double value = data!.buffer.asByteData().getFloat64(offset, Endian.big);
		offset += 8;
		return value;
	}
	DateTime unpackDateTime() {
		final int value = data!.buffer.asByteData().getUint64(offset, Endian.big);
		offset += 8;
		return DateTime.fromMillisecondsSinceEpoch(value);
	}
	String unpackString() {
		final int length = data!.buffer.asByteData().getUint32(offset, Endian.big);
		offset += 4;
		final String result = _utf8.decoder.convert(data!.buffer.asUint8List(offset, length));
		offset += length;
		return result;
	}
}