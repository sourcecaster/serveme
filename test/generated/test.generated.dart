import 'package:packme/packme.dart';

class TestRequest extends PackMeMessage {
	TestRequest({
		required this.requestParam,
	});
	TestRequest.$empty();

	late double requestParam;

	TestResponse $response({
		required double responseParam,
	}) {
		final TestResponse message = TestResponse(responseParam: responseParam);
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		return 16;
	}

	@override
	void $pack() {
		$initPack(764832169);
		$packDouble(requestParam);
	}

	@override
	void $unpack() {
		$initUnpack();
		requestParam = $unpackDouble();
	}

	@override
	String toString() {
		return 'TestRequest\x1b[0m(requestParam: ${PackMe.dye(requestParam)})';
	}
}

class TestResponse extends PackMeMessage {
	TestResponse({
		required this.responseParam,
	});
	TestResponse.$empty();

	late double responseParam;

	@override
	int $estimate() {
		$reset();
		return 16;
	}

	@override
	void $pack() {
		$initPack(216725115);
		$packDouble(responseParam);
	}

	@override
	void $unpack() {
		$initUnpack();
		responseParam = $unpackDouble();
	}

	@override
	String toString() {
		return 'TestResponse\x1b[0m(responseParam: ${PackMe.dye(responseParam)})';
	}
}

final Map<int, PackMeMessage Function()> testMessageFactory = <int, PackMeMessage Function()>{
	764832169: () => TestRequest.$empty(),
	216725115: () => TestResponse.$empty(),
};