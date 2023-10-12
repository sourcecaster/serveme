import 'package:packme/packme.dart';

class GetAllResponseUser extends PackMeMessage {
	GetAllResponseUser({
		required this.id,
		required this.nickname,
		this.firstName,
		this.lastName,
		this.age,
	});
	GetAllResponseUser.$empty();

	late List<int> id;
	late String nickname;
	String? firstName;
	String? lastName;
	int? age;

	@override
	int $estimate() {
		$reset();
		int _bytes = 1;
		_bytes += 4 + id.length * 1;
		_bytes += $stringBytes(nickname);
		$setFlag(firstName != null);
		if (firstName != null) _bytes += $stringBytes(firstName!);
		$setFlag(lastName != null);
		if (lastName != null) _bytes += $stringBytes(lastName!);
		$setFlag(age != null);
		if (age != null) _bytes += 1;
		return _bytes;
	}

	@override
	void $pack() {
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		$packUint32(id.length);
		for (int _i2 = 0; _i2 < id.length; _i2++) {
			$packUint8(id[_i2]);
		}
		$packString(nickname);
		if (firstName != null) $packString(firstName!);
		if (lastName != null) $packString(lastName!);
		if (age != null) $packUint8(age!);
	}

	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		id = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
		nickname = $unpackString();
		if ($getFlag()) firstName = $unpackString();
		if ($getFlag()) lastName = $unpackString();
		if ($getFlag()) age = $unpackUint8();
	}

	@override
	String toString() {
		return 'GetAllResponseUser\x1b[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, firstName: ${PackMe.dye(firstName)}, lastName: ${PackMe.dye(lastName)}, age: ${PackMe.dye(age)})';
	}
}

class GetResponseInfo extends PackMeMessage {
	GetResponseInfo({
		this.firstName,
		this.lastName,
		this.male,
		this.age,
		this.birthDate,
	});
	GetResponseInfo.$empty();

	String? firstName;
	String? lastName;
	int? male;
	int? age;
	DateTime? birthDate;

	@override
	int $estimate() {
		$reset();
		int _bytes = 1;
		$setFlag(firstName != null);
		if (firstName != null) _bytes += $stringBytes(firstName!);
		$setFlag(lastName != null);
		if (lastName != null) _bytes += $stringBytes(lastName!);
		$setFlag(male != null);
		if (male != null) _bytes += 1;
		$setFlag(age != null);
		if (age != null) _bytes += 1;
		$setFlag(birthDate != null);
		if (birthDate != null) _bytes += 8;
		return _bytes;
	}

	@override
	void $pack() {
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		if (firstName != null) $packString(firstName!);
		if (lastName != null) $packString(lastName!);
		if (male != null) $packUint8(male!);
		if (age != null) $packUint8(age!);
		if (birthDate != null) $packDateTime(birthDate!);
	}

	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		if ($getFlag()) firstName = $unpackString();
		if ($getFlag()) lastName = $unpackString();
		if ($getFlag()) male = $unpackUint8();
		if ($getFlag()) age = $unpackUint8();
		if ($getFlag()) birthDate = $unpackDateTime();
	}

	@override
	String toString() {
		return 'GetResponseInfo\x1b[0m(firstName: ${PackMe.dye(firstName)}, lastName: ${PackMe.dye(lastName)}, male: ${PackMe.dye(male)}, age: ${PackMe.dye(age)}, birthDate: ${PackMe.dye(birthDate)})';
	}
}

class GetResponseLastActive extends PackMeMessage {
	GetResponseLastActive({
		required this.datetime,
		required this.ip,
	});
	GetResponseLastActive.$empty();

	late DateTime datetime;
	late String ip;

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += $stringBytes(ip);
		return _bytes;
	}

	@override
	void $pack() {
		$packDateTime(datetime);
		$packString(ip);
	}

	@override
	void $unpack() {
		datetime = $unpackDateTime();
		ip = $unpackString();
	}

	@override
	String toString() {
		return 'GetResponseLastActive\x1b[0m(datetime: ${PackMe.dye(datetime)}, ip: ${PackMe.dye(ip)})';
	}
}

class GetResponseSession extends PackMeMessage {
	GetResponseSession({
		required this.created,
		required this.ip,
		required this.active,
	});
	GetResponseSession.$empty();

	late DateTime created;
	late String ip;
	late bool active;

	@override
	int $estimate() {
		$reset();
		int _bytes = 9;
		_bytes += $stringBytes(ip);
		return _bytes;
	}

	@override
	void $pack() {
		$packDateTime(created);
		$packString(ip);
		$packBool(active);
	}

	@override
	void $unpack() {
		created = $unpackDateTime();
		ip = $unpackString();
		active = $unpackBool();
	}

	@override
	String toString() {
		return 'GetResponseSession\x1b[0m(created: ${PackMe.dye(created)}, ip: ${PackMe.dye(ip)}, active: ${PackMe.dye(active)})';
	}
}

class GetResponseSocial extends PackMeMessage {
	GetResponseSocial({
		this.facebookId,
		this.twitterId,
		this.instagramId,
	});
	GetResponseSocial.$empty();

	String? facebookId;
	String? twitterId;
	String? instagramId;

	@override
	int $estimate() {
		$reset();
		int _bytes = 1;
		$setFlag(facebookId != null);
		if (facebookId != null) _bytes += $stringBytes(facebookId!);
		$setFlag(twitterId != null);
		if (twitterId != null) _bytes += $stringBytes(twitterId!);
		$setFlag(instagramId != null);
		if (instagramId != null) _bytes += $stringBytes(instagramId!);
		return _bytes;
	}

	@override
	void $pack() {
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		if (facebookId != null) $packString(facebookId!);
		if (twitterId != null) $packString(twitterId!);
		if (instagramId != null) $packString(instagramId!);
	}

	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		if ($getFlag()) facebookId = $unpackString();
		if ($getFlag()) twitterId = $unpackString();
		if ($getFlag()) instagramId = $unpackString();
	}

	@override
	String toString() {
		return 'GetResponseSocial\x1b[0m(facebookId: ${PackMe.dye(facebookId)}, twitterId: ${PackMe.dye(twitterId)}, instagramId: ${PackMe.dye(instagramId)})';
	}
}

class GetResponseStats extends PackMeMessage {
	GetResponseStats({
		required this.posts,
		required this.comments,
		required this.likes,
		required this.dislikes,
		required this.rating,
	});
	GetResponseStats.$empty();

	late int posts;
	late int comments;
	late int likes;
	late int dislikes;
	late double rating;

	@override
	int $estimate() {
		$reset();
		return 20;
	}

	@override
	void $pack() {
		$packUint32(posts);
		$packUint32(comments);
		$packUint32(likes);
		$packUint32(dislikes);
		$packFloat(rating);
	}

	@override
	void $unpack() {
		posts = $unpackUint32();
		comments = $unpackUint32();
		likes = $unpackUint32();
		dislikes = $unpackUint32();
		rating = $unpackFloat();
	}

	@override
	String toString() {
		return 'GetResponseStats\x1b[0m(posts: ${PackMe.dye(posts)}, comments: ${PackMe.dye(comments)}, likes: ${PackMe.dye(likes)}, dislikes: ${PackMe.dye(dislikes)}, rating: ${PackMe.dye(rating)})';
	}
}

class GetAllRequest extends PackMeMessage {
	GetAllRequest();
	GetAllRequest.$empty();


	GetAllResponse $response({
		required List<GetAllResponseUser> users,
	}) {
		final GetAllResponse message = GetAllResponse(users: users);
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		return 8;
	}

	@override
	void $pack() {
		$initPack(12982278);
	}

	@override
	void $unpack() {
		$initUnpack();
	}

	@override
	String toString() {
		return 'GetAllRequest\x1b[0m()';
	}
}

class GetAllResponse extends PackMeMessage {
	GetAllResponse({
		required this.users,
	});
	GetAllResponse.$empty();

	late List<GetAllResponseUser> users;

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + users.fold(0, (int a, GetAllResponseUser b) => a + b.$estimate());
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(242206268);
		$packUint32(users.length);
		for (int _i5 = 0; _i5 < users.length; _i5++) {
			$packMessage(users[_i5]);
		}
	}

	@override
	void $unpack() {
		$initUnpack();
		users = List<GetAllResponseUser>.generate($unpackUint32(), (int i) {
			return $unpackMessage(GetAllResponseUser.$empty());
		});
	}

	@override
	String toString() {
		return 'GetAllResponse\x1b[0m(users: ${PackMe.dye(users)})';
	}
}

class GetRequest extends PackMeMessage {
	GetRequest({
		required this.userId,
	});
	GetRequest.$empty();

	late List<int> userId;

	GetResponse $response({
		required String email,
		required String nickname,
		required bool hidden,
		required DateTime created,
		required GetResponseInfo info,
		required GetResponseSocial social,
		required GetResponseStats stats,
		GetResponseLastActive? lastActive,
		required List<GetResponseSession> sessions,
	}) {
		final GetResponse message = GetResponse(email: email, nickname: nickname, hidden: hidden, created: created, info: info, social: social, stats: stats, lastActive: lastActive, sessions: sessions);
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + userId.length * 1;
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(781905656);
		$packUint32(userId.length);
		for (int _i6 = 0; _i6 < userId.length; _i6++) {
			$packUint8(userId[_i6]);
		}
	}

	@override
	void $unpack() {
		$initUnpack();
		userId = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
	}

	@override
	String toString() {
		return 'GetRequest\x1b[0m(userId: ${PackMe.dye(userId)})';
	}
}

class GetResponse extends PackMeMessage {
	GetResponse({
		required this.email,
		required this.nickname,
		required this.hidden,
		required this.created,
		required this.info,
		required this.social,
		required this.stats,
		this.lastActive,
		required this.sessions,
	});
	GetResponse.$empty();

	late String email;
	late String nickname;
	late bool hidden;
	late DateTime created;
	late GetResponseInfo info;
	late GetResponseSocial social;
	late GetResponseStats stats;
	GetResponseLastActive? lastActive;
	late List<GetResponseSession> sessions;

	@override
	int $estimate() {
		$reset();
		int _bytes = 18;
		_bytes += $stringBytes(email);
		_bytes += $stringBytes(nickname);
		_bytes += info.$estimate();
		_bytes += social.$estimate();
		_bytes += stats.$estimate();
		$setFlag(lastActive != null);
		if (lastActive != null) _bytes += lastActive!.$estimate();
		_bytes += 4 + sessions.fold(0, (int a, GetResponseSession b) => a + b.$estimate());
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(430536944);
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		$packString(email);
		$packString(nickname);
		$packBool(hidden);
		$packDateTime(created);
		$packMessage(info);
		$packMessage(social);
		$packMessage(stats);
		if (lastActive != null) $packMessage(lastActive!);
		$packUint32(sessions.length);
		for (int _i8 = 0; _i8 < sessions.length; _i8++) {
			$packMessage(sessions[_i8]);
		}
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		email = $unpackString();
		nickname = $unpackString();
		hidden = $unpackBool();
		created = $unpackDateTime();
		info = $unpackMessage(GetResponseInfo.$empty());
		social = $unpackMessage(GetResponseSocial.$empty());
		stats = $unpackMessage(GetResponseStats.$empty());
		if ($getFlag()) lastActive = $unpackMessage(GetResponseLastActive.$empty());
		sessions = List<GetResponseSession>.generate($unpackUint32(), (int i) {
			return $unpackMessage(GetResponseSession.$empty());
		});
	}

	@override
	String toString() {
		return 'GetResponse\x1b[0m(email: ${PackMe.dye(email)}, nickname: ${PackMe.dye(nickname)}, hidden: ${PackMe.dye(hidden)}, created: ${PackMe.dye(created)}, info: ${PackMe.dye(info)}, social: ${PackMe.dye(social)}, stats: ${PackMe.dye(stats)}, lastActive: ${PackMe.dye(lastActive)}, sessions: ${PackMe.dye(sessions)})';
	}
}

class DeleteRequest extends PackMeMessage {
	DeleteRequest({
		required this.userId,
	});
	DeleteRequest.$empty();

	late List<int> userId;

	DeleteResponse $response({
		String? error,
	}) {
		final DeleteResponse message = DeleteResponse(error: error);
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + userId.length * 1;
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(808423104);
		$packUint32(userId.length);
		for (int _i6 = 0; _i6 < userId.length; _i6++) {
			$packUint8(userId[_i6]);
		}
	}

	@override
	void $unpack() {
		$initUnpack();
		userId = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
	}

	@override
	String toString() {
		return 'DeleteRequest\x1b[0m(userId: ${PackMe.dye(userId)})';
	}
}

class DeleteResponse extends PackMeMessage {
	DeleteResponse({
		this.error,
	});
	DeleteResponse.$empty();

	String? error;

	@override
	int $estimate() {
		$reset();
		int _bytes = 9;
		$setFlag(error != null);
		if (error != null) _bytes += $stringBytes(error!);
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(69897231);
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		if (error != null) $packString(error!);
	}

	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		if ($getFlag()) error = $unpackString();
	}

	@override
	String toString() {
		return 'DeleteResponse\x1b[0m(error: ${PackMe.dye(error)})';
	}
}

final Map<int, PackMeMessage Function()> exampleUsersMessageFactory = <int, PackMeMessage Function()>{
	12982278: () => GetAllRequest.$empty(),
	781905656: () => GetRequest.$empty(),
	808423104: () => DeleteRequest.$empty(),
	242206268: () => GetAllResponse.$empty(),
	430536944: () => GetResponse.$empty(),
	69897231: () => DeleteResponse.$empty(),
};