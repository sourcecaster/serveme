import 'package:packme/packme.dart';

class GetAllRequest extends PackMeMessage {
	
	@override
	GetAllResponse get $response {
		final GetAllResponse message = GetAllResponse();
		message.$request = this;
		return message;
	}
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		return bytes;
	}
	
	@override
	void $pack() {
		$initPack(12982278);
	}
	
	@override
	void $unpack() {
		$initUnpack();
	}
	
}

class GetAllResponseUser extends PackMeMessage {
	late List<int> id;
	late String nickname;
	String? firstName;
	String? lastName;
	int? age;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 1;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += $stringBytes(nickname);
		$setFlag(firstName != null);
		if (firstName != null) {
			bytes += $stringBytes(firstName!);
		}
		$setFlag(lastName != null);
		if (lastName != null) {
			bytes += $stringBytes(lastName!);
		}
		$setFlag(age != null);
		if (age != null) {
			bytes += 1;
		}
		return bytes;
	}
	
	@override
	void $pack() {
		for (int i = 0; i < 1; i++) $packUint8($flags[i]);
		$packUint32(id.length);
		id.forEach($packUint8);
		$packString(nickname);
		if (firstName != null) $packString(firstName!);
		if (lastName != null) $packString(lastName!);
		if (age != null) $packUint8(age!);
	}
	
	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		id = <int>[];
		final int idLength = $unpackUint32();
		for (int i = 0; i < idLength; i++) {
			id.add($unpackUint8());
		}
		nickname = $unpackString();
		if ($getFlag()) {
			firstName = $unpackString();
		}
		if ($getFlag()) {
			lastName = $unpackString();
		}
		if ($getFlag()) {
			age = $unpackUint8();
		}
	}
	
}

class GetAllResponse extends PackMeMessage {
	late List<GetAllResponseUser> users;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		for (int i = 0; i < users.length; i++) bytes += users[i].$estimate();
		return bytes;
	}
	
	@override
	void $pack() {
		$initPack(242206268);
		$packUint32(users.length);
		users.forEach($packMessage);
	}
	
	@override
	void $unpack() {
		$initUnpack();
		users = <GetAllResponseUser>[];
		final int usersLength = $unpackUint32();
		for (int i = 0; i < usersLength; i++) {
			users.add($unpackMessage(GetAllResponseUser()) as GetAllResponseUser);
		}
	}
	
}

class GetRequest extends PackMeMessage {
	late List<int> userId;
	
	@override
	GetResponse get $response {
		final GetResponse message = GetResponse();
		message.$request = this;
		return message;
	}
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		bytes += 1 * userId.length;
		return bytes;
	}
	
	@override
	void $pack() {
		$initPack(781905656);
		$packUint32(userId.length);
		userId.forEach($packUint8);
	}
	
	@override
	void $unpack() {
		$initUnpack();
		userId = <int>[];
		final int userIdLength = $unpackUint32();
		for (int i = 0; i < userIdLength; i++) {
			userId.add($unpackUint8());
		}
	}
	
}

class GetResponseInfo extends PackMeMessage {
	String? firstName;
	String? lastName;
	int? male;
	int? age;
	DateTime? birthDate;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 1;
		$setFlag(firstName != null);
		if (firstName != null) {
			bytes += $stringBytes(firstName!);
		}
		$setFlag(lastName != null);
		if (lastName != null) {
			bytes += $stringBytes(lastName!);
		}
		$setFlag(male != null);
		if (male != null) {
			bytes += 1;
		}
		$setFlag(age != null);
		if (age != null) {
			bytes += 1;
		}
		$setFlag(birthDate != null);
		if (birthDate != null) {
			bytes += 8;
		}
		return bytes;
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
		if ($getFlag()) {
			firstName = $unpackString();
		}
		if ($getFlag()) {
			lastName = $unpackString();
		}
		if ($getFlag()) {
			male = $unpackUint8();
		}
		if ($getFlag()) {
			age = $unpackUint8();
		}
		if ($getFlag()) {
			birthDate = $unpackDateTime();
		}
	}
	
}

class GetResponseSocial extends PackMeMessage {
	String? facebookId;
	String? twitterId;
	String? instagramId;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 1;
		$setFlag(facebookId != null);
		if (facebookId != null) {
			bytes += $stringBytes(facebookId!);
		}
		$setFlag(twitterId != null);
		if (twitterId != null) {
			bytes += $stringBytes(twitterId!);
		}
		$setFlag(instagramId != null);
		if (instagramId != null) {
			bytes += $stringBytes(instagramId!);
		}
		return bytes;
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
		if ($getFlag()) {
			facebookId = $unpackString();
		}
		if ($getFlag()) {
			twitterId = $unpackString();
		}
		if ($getFlag()) {
			instagramId = $unpackString();
		}
	}
	
}

class GetResponseStats extends PackMeMessage {
	late int posts;
	late int comments;
	late int likes;
	late int dislikes;
	late double rating;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 20;
		return bytes;
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
	
}

class GetResponseLastActive extends PackMeMessage {
	late DateTime datetime;
	late String ip;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += $stringBytes(ip);
		return bytes;
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
	
}

class GetResponseSession extends PackMeMessage {
	late DateTime created;
	late String ip;
	late bool active;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 9;
		bytes += $stringBytes(ip);
		return bytes;
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
	
}

class GetResponse extends PackMeMessage {
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
		int bytes = 18;
		bytes += $stringBytes(email);
		bytes += $stringBytes(nickname);
		bytes += info.$estimate();
		bytes += social.$estimate();
		bytes += stats.$estimate();
		$setFlag(lastActive != null);
		if (lastActive != null) {
			bytes += lastActive!.$estimate();
		}
		bytes += 4;
		for (int i = 0; i < sessions.length; i++) bytes += sessions[i].$estimate();
		return bytes;
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
		sessions.forEach($packMessage);
	}
	
	@override
	void $unpack() {
		$initUnpack();
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		email = $unpackString();
		nickname = $unpackString();
		hidden = $unpackBool();
		created = $unpackDateTime();
		info = $unpackMessage(GetResponseInfo()) as GetResponseInfo;
		social = $unpackMessage(GetResponseSocial()) as GetResponseSocial;
		stats = $unpackMessage(GetResponseStats()) as GetResponseStats;
		if ($getFlag()) {
			lastActive = $unpackMessage(GetResponseLastActive()) as GetResponseLastActive;
		}
		sessions = <GetResponseSession>[];
		final int sessionsLength = $unpackUint32();
		for (int i = 0; i < sessionsLength; i++) {
			sessions.add($unpackMessage(GetResponseSession()) as GetResponseSession);
		}
	}
	
}

class DeleteRequest extends PackMeMessage {
	late List<int> userId;
	
	@override
	DeleteResponse get $response {
		final DeleteResponse message = DeleteResponse();
		message.$request = this;
		return message;
	}
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		bytes += 1 * userId.length;
		return bytes;
	}
	
	@override
	void $pack() {
		$initPack(808423104);
		$packUint32(userId.length);
		userId.forEach($packUint8);
	}
	
	@override
	void $unpack() {
		$initUnpack();
		userId = <int>[];
		final int userIdLength = $unpackUint32();
		for (int i = 0; i < userIdLength; i++) {
			userId.add($unpackUint8());
		}
	}
	
}

class DeleteResponse extends PackMeMessage {
	String? error;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 9;
		$setFlag(error != null);
		if (error != null) {
			bytes += $stringBytes(error!);
		}
		return bytes;
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
		if ($getFlag()) {
			error = $unpackString();
		}
	}
	
}

final Map<int, PackMeMessage Function()> exampleUsersMessageFactory = <int, PackMeMessage Function()>{
	12982278: () => GetAllRequest(),
	242206268: () => GetAllResponse(),
	781905656: () => GetRequest(),
	430536944: () => GetResponse(),
	808423104: () => DeleteRequest(),
	69897231: () => DeleteResponse(),
};