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
		$initPack(63570112);
	}
	
	@override
	void $unpack() {
		$initUnpack();
	}
	
}

class GetAllResponsePostAuthor extends PackMeMessage {
	late List<int> id;
	late String nickname;
	late String avatar;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 0;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += $stringBytes(nickname);
		bytes += $stringBytes(avatar);
		return bytes;
	}
	
	@override
	void $pack() {
		$packUint32(id.length);
		id.forEach($packUint8);
		$packString(nickname);
		$packString(avatar);
	}
	
	@override
	void $unpack() {
		id = <int>[];
		final int idLength = $unpackUint32();
		for (int i = 0; i < idLength; i++) {
			id.add($unpackUint8());
		}
		nickname = $unpackString();
		avatar = $unpackString();
	}
	
}

class GetAllResponsePost extends PackMeMessage {
	late List<int> id;
	late GetAllResponsePostAuthor author;
	late String title;
	late String shortContent;
	late DateTime posted;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += author.$estimate();
		bytes += $stringBytes(title);
		bytes += $stringBytes(shortContent);
		return bytes;
	}
	
	@override
	void $pack() {
		$packUint32(id.length);
		id.forEach($packUint8);
		$packMessage(author);
		$packString(title);
		$packString(shortContent);
		$packDateTime(posted);
	}
	
	@override
	void $unpack() {
		id = <int>[];
		final int idLength = $unpackUint32();
		for (int i = 0; i < idLength; i++) {
			id.add($unpackUint8());
		}
		author = $unpackMessage(GetAllResponsePostAuthor()) as GetAllResponsePostAuthor;
		title = $unpackString();
		shortContent = $unpackString();
		posted = $unpackDateTime();
	}
	
}

class GetAllResponse extends PackMeMessage {
	late List<GetAllResponsePost> posts;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += 4;
		for (int i = 0; i < posts.length; i++) bytes += posts[i].$estimate();
		return bytes;
	}
	
	@override
	void $pack() {
		$initPack(280110613);
		$packUint32(posts.length);
		posts.forEach($packMessage);
	}
	
	@override
	void $unpack() {
		$initUnpack();
		posts = <GetAllResponsePost>[];
		final int postsLength = $unpackUint32();
		for (int i = 0; i < postsLength; i++) {
			posts.add($unpackMessage(GetAllResponsePost()) as GetAllResponsePost);
		}
	}
	
}

class GetRequest extends PackMeMessage {
	late List<int> postId;
	
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
		bytes += 1 * postId.length;
		return bytes;
	}
	
	@override
	void $pack() {
		$initPack(187698222);
		$packUint32(postId.length);
		postId.forEach($packUint8);
	}
	
	@override
	void $unpack() {
		$initUnpack();
		postId = <int>[];
		final int postIdLength = $unpackUint32();
		for (int i = 0; i < postIdLength; i++) {
			postId.add($unpackUint8());
		}
	}
	
}

class GetResponseAuthor extends PackMeMessage {
	late List<int> id;
	late String nickname;
	late String avatar;
	String? facebookId;
	String? twitterId;
	String? instagramId;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 1;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += $stringBytes(nickname);
		bytes += $stringBytes(avatar);
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
		$packUint32(id.length);
		id.forEach($packUint8);
		$packString(nickname);
		$packString(avatar);
		if (facebookId != null) $packString(facebookId!);
		if (twitterId != null) $packString(twitterId!);
		if (instagramId != null) $packString(instagramId!);
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
		avatar = $unpackString();
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
	late int likes;
	late int dislikes;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		return bytes;
	}
	
	@override
	void $pack() {
		$packUint32(likes);
		$packUint32(dislikes);
	}
	
	@override
	void $unpack() {
		likes = $unpackUint32();
		dislikes = $unpackUint32();
	}
	
}

class GetResponseCommentAuthor extends PackMeMessage {
	late List<int> id;
	late String nickname;
	late String avatar;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 0;
		bytes += 4;
		bytes += 1 * id.length;
		bytes += $stringBytes(nickname);
		bytes += $stringBytes(avatar);
		return bytes;
	}
	
	@override
	void $pack() {
		$packUint32(id.length);
		id.forEach($packUint8);
		$packString(nickname);
		$packString(avatar);
	}
	
	@override
	void $unpack() {
		id = <int>[];
		final int idLength = $unpackUint32();
		for (int i = 0; i < idLength; i++) {
			id.add($unpackUint8());
		}
		nickname = $unpackString();
		avatar = $unpackString();
	}
	
}

class GetResponseComment extends PackMeMessage {
	late GetResponseCommentAuthor author;
	late String comment;
	late DateTime posted;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 8;
		bytes += author.$estimate();
		bytes += $stringBytes(comment);
		return bytes;
	}
	
	@override
	void $pack() {
		$packMessage(author);
		$packString(comment);
		$packDateTime(posted);
	}
	
	@override
	void $unpack() {
		author = $unpackMessage(GetResponseCommentAuthor()) as GetResponseCommentAuthor;
		comment = $unpackString();
		posted = $unpackDateTime();
	}
	
}

class GetResponse extends PackMeMessage {
	late String title;
	late String content;
	late DateTime posted;
	late GetResponseAuthor author;
	late GetResponseStats stats;
	late List<GetResponseComment> comments;
	
	@override
	int $estimate() {
		$reset();
		int bytes = 16;
		bytes += $stringBytes(title);
		bytes += $stringBytes(content);
		bytes += author.$estimate();
		bytes += stats.$estimate();
		bytes += 4;
		for (int i = 0; i < comments.length; i++) bytes += comments[i].$estimate();
		return bytes;
	}
	
	@override
	void $pack() {
		$initPack(244485545);
		$packString(title);
		$packString(content);
		$packDateTime(posted);
		$packMessage(author);
		$packMessage(stats);
		$packUint32(comments.length);
		comments.forEach($packMessage);
	}
	
	@override
	void $unpack() {
		$initUnpack();
		title = $unpackString();
		content = $unpackString();
		posted = $unpackDateTime();
		author = $unpackMessage(GetResponseAuthor()) as GetResponseAuthor;
		stats = $unpackMessage(GetResponseStats()) as GetResponseStats;
		comments = <GetResponseComment>[];
		final int commentsLength = $unpackUint32();
		for (int i = 0; i < commentsLength; i++) {
			comments.add($unpackMessage(GetResponseComment()) as GetResponseComment);
		}
	}
	
}

class DeleteRequest extends PackMeMessage {
	late List<int> postId;
	
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
		bytes += 1 * postId.length;
		return bytes;
	}
	
	@override
	void $pack() {
		$initPack(486637631);
		$packUint32(postId.length);
		postId.forEach($packUint8);
	}
	
	@override
	void $unpack() {
		$initUnpack();
		postId = <int>[];
		final int postIdLength = $unpackUint32();
		for (int i = 0; i < postIdLength; i++) {
			postId.add($unpackUint8());
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
		$initPack(788388804);
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

final Map<int, PackMeMessage Function()> examplePostsMessageFactory = <int, PackMeMessage Function()>{
	63570112: () => GetAllRequest(),
	280110613: () => GetAllResponse(),
	187698222: () => GetRequest(),
	244485545: () => GetResponse(),
	486637631: () => DeleteRequest(),
	788388804: () => DeleteResponse(),
};