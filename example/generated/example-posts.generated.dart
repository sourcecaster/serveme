import 'package:packme/packme.dart';

class GetAllResponsePost extends PackMeMessage {
	GetAllResponsePost({
		required this.id,
		required this.author,
		required this.title,
		required this.shortContent,
		required this.posted,
	});
	GetAllResponsePost.$empty();

	late List<int> id;
	late GetAllResponsePostAuthor author;
	late String title;
	late String shortContent;
	late DateTime posted;

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + id.length * 1;
		_bytes += author.$estimate();
		_bytes += $stringBytes(title);
		_bytes += $stringBytes(shortContent);
		return _bytes;
	}

	@override
	void $pack() {
		$packUint32(id.length);
		for (int _i2 = 0; _i2 < id.length; _i2++) {
			$packUint8(id[_i2]);
		}
		$packMessage(author);
		$packString(title);
		$packString(shortContent);
		$packDateTime(posted);
	}

	@override
	void $unpack() {
		id = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
		author = $unpackMessage(GetAllResponsePostAuthor.$empty());
		title = $unpackString();
		shortContent = $unpackString();
		posted = $unpackDateTime();
	}

	@override
	String toString() {
		return 'GetAllResponsePost\x1b[0m(id: ${PackMe.dye(id)}, author: ${PackMe.dye(author)}, title: ${PackMe.dye(title)}, shortContent: ${PackMe.dye(shortContent)}, posted: ${PackMe.dye(posted)})';
	}
}

class GetAllResponsePostAuthor extends PackMeMessage {
	GetAllResponsePostAuthor({
		required this.id,
		required this.nickname,
		required this.avatar,
	});
	GetAllResponsePostAuthor.$empty();

	late List<int> id;
	late String nickname;
	late String avatar;

	@override
	int $estimate() {
		$reset();
		int _bytes = 0;
		_bytes += 4 + id.length * 1;
		_bytes += $stringBytes(nickname);
		_bytes += $stringBytes(avatar);
		return _bytes;
	}

	@override
	void $pack() {
		$packUint32(id.length);
		for (int _i2 = 0; _i2 < id.length; _i2++) {
			$packUint8(id[_i2]);
		}
		$packString(nickname);
		$packString(avatar);
	}

	@override
	void $unpack() {
		id = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
		nickname = $unpackString();
		avatar = $unpackString();
	}

	@override
	String toString() {
		return 'GetAllResponsePostAuthor\x1b[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, avatar: ${PackMe.dye(avatar)})';
	}
}

class GetResponseAuthor extends PackMeMessage {
	GetResponseAuthor({
		required this.id,
		required this.nickname,
		required this.avatar,
		this.facebookId,
		this.twitterId,
		this.instagramId,
	});
	GetResponseAuthor.$empty();

	late List<int> id;
	late String nickname;
	late String avatar;
	String? facebookId;
	String? twitterId;
	String? instagramId;

	@override
	int $estimate() {
		$reset();
		int _bytes = 1;
		_bytes += 4 + id.length * 1;
		_bytes += $stringBytes(nickname);
		_bytes += $stringBytes(avatar);
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
		$packUint32(id.length);
		for (int _i2 = 0; _i2 < id.length; _i2++) {
			$packUint8(id[_i2]);
		}
		$packString(nickname);
		$packString(avatar);
		if (facebookId != null) $packString(facebookId!);
		if (twitterId != null) $packString(twitterId!);
		if (instagramId != null) $packString(instagramId!);
	}

	@override
	void $unpack() {
		for (int i = 0; i < 1; i++) $flags.add($unpackUint8());
		id = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
		nickname = $unpackString();
		avatar = $unpackString();
		if ($getFlag()) facebookId = $unpackString();
		if ($getFlag()) twitterId = $unpackString();
		if ($getFlag()) instagramId = $unpackString();
	}

	@override
	String toString() {
		return 'GetResponseAuthor\x1b[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, avatar: ${PackMe.dye(avatar)}, facebookId: ${PackMe.dye(facebookId)}, twitterId: ${PackMe.dye(twitterId)}, instagramId: ${PackMe.dye(instagramId)})';
	}
}

class GetResponseComment extends PackMeMessage {
	GetResponseComment({
		required this.author,
		required this.comment,
		required this.posted,
	});
	GetResponseComment.$empty();

	late GetResponseCommentAuthor author;
	late String comment;
	late DateTime posted;

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += author.$estimate();
		_bytes += $stringBytes(comment);
		return _bytes;
	}

	@override
	void $pack() {
		$packMessage(author);
		$packString(comment);
		$packDateTime(posted);
	}

	@override
	void $unpack() {
		author = $unpackMessage(GetResponseCommentAuthor.$empty());
		comment = $unpackString();
		posted = $unpackDateTime();
	}

	@override
	String toString() {
		return 'GetResponseComment\x1b[0m(author: ${PackMe.dye(author)}, comment: ${PackMe.dye(comment)}, posted: ${PackMe.dye(posted)})';
	}
}

class GetResponseCommentAuthor extends PackMeMessage {
	GetResponseCommentAuthor({
		required this.id,
		required this.nickname,
		required this.avatar,
	});
	GetResponseCommentAuthor.$empty();

	late List<int> id;
	late String nickname;
	late String avatar;

	@override
	int $estimate() {
		$reset();
		int _bytes = 0;
		_bytes += 4 + id.length * 1;
		_bytes += $stringBytes(nickname);
		_bytes += $stringBytes(avatar);
		return _bytes;
	}

	@override
	void $pack() {
		$packUint32(id.length);
		for (int _i2 = 0; _i2 < id.length; _i2++) {
			$packUint8(id[_i2]);
		}
		$packString(nickname);
		$packString(avatar);
	}

	@override
	void $unpack() {
		id = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
		nickname = $unpackString();
		avatar = $unpackString();
	}

	@override
	String toString() {
		return 'GetResponseCommentAuthor\x1b[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, avatar: ${PackMe.dye(avatar)})';
	}
}

class GetResponseStats extends PackMeMessage {
	GetResponseStats({
		required this.likes,
		required this.dislikes,
	});
	GetResponseStats.$empty();

	late int likes;
	late int dislikes;

	@override
	int $estimate() {
		$reset();
		return 8;
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

	@override
	String toString() {
		return 'GetResponseStats\x1b[0m(likes: ${PackMe.dye(likes)}, dislikes: ${PackMe.dye(dislikes)})';
	}
}

class GetAllRequest extends PackMeMessage {
	GetAllRequest();
	GetAllRequest.$empty();


	GetAllResponse $response({
		required List<GetAllResponsePost> posts,
	}) {
		final GetAllResponse message = GetAllResponse(posts: posts);
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
		$initPack(63570112);
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
		required this.posts,
	});
	GetAllResponse.$empty();

	late List<GetAllResponsePost> posts;

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + posts.fold(0, (int a, GetAllResponsePost b) => a + b.$estimate());
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(280110613);
		$packUint32(posts.length);
		for (int _i5 = 0; _i5 < posts.length; _i5++) {
			$packMessage(posts[_i5]);
		}
	}

	@override
	void $unpack() {
		$initUnpack();
		posts = List<GetAllResponsePost>.generate($unpackUint32(), (int i) {
			return $unpackMessage(GetAllResponsePost.$empty());
		});
	}

	@override
	String toString() {
		return 'GetAllResponse\x1b[0m(posts: ${PackMe.dye(posts)})';
	}
}

class GetRequest extends PackMeMessage {
	GetRequest({
		required this.postId,
	});
	GetRequest.$empty();

	late List<int> postId;

	GetResponse $response({
		required String title,
		required String content,
		required DateTime posted,
		required GetResponseAuthor author,
		required GetResponseStats stats,
		required List<GetResponseComment> comments,
	}) {
		final GetResponse message = GetResponse(title: title, content: content, posted: posted, author: author, stats: stats, comments: comments);
		message.$request = this;
		return message;
	}

	@override
	int $estimate() {
		$reset();
		int _bytes = 8;
		_bytes += 4 + postId.length * 1;
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(187698222);
		$packUint32(postId.length);
		for (int _i6 = 0; _i6 < postId.length; _i6++) {
			$packUint8(postId[_i6]);
		}
	}

	@override
	void $unpack() {
		$initUnpack();
		postId = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
	}

	@override
	String toString() {
		return 'GetRequest\x1b[0m(postId: ${PackMe.dye(postId)})';
	}
}

class GetResponse extends PackMeMessage {
	GetResponse({
		required this.title,
		required this.content,
		required this.posted,
		required this.author,
		required this.stats,
		required this.comments,
	});
	GetResponse.$empty();

	late String title;
	late String content;
	late DateTime posted;
	late GetResponseAuthor author;
	late GetResponseStats stats;
	late List<GetResponseComment> comments;

	@override
	int $estimate() {
		$reset();
		int _bytes = 16;
		_bytes += $stringBytes(title);
		_bytes += $stringBytes(content);
		_bytes += author.$estimate();
		_bytes += stats.$estimate();
		_bytes += 4 + comments.fold(0, (int a, GetResponseComment b) => a + b.$estimate());
		return _bytes;
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
		for (int _i8 = 0; _i8 < comments.length; _i8++) {
			$packMessage(comments[_i8]);
		}
	}

	@override
	void $unpack() {
		$initUnpack();
		title = $unpackString();
		content = $unpackString();
		posted = $unpackDateTime();
		author = $unpackMessage(GetResponseAuthor.$empty());
		stats = $unpackMessage(GetResponseStats.$empty());
		comments = List<GetResponseComment>.generate($unpackUint32(), (int i) {
			return $unpackMessage(GetResponseComment.$empty());
		});
	}

	@override
	String toString() {
		return 'GetResponse\x1b[0m(title: ${PackMe.dye(title)}, content: ${PackMe.dye(content)}, posted: ${PackMe.dye(posted)}, author: ${PackMe.dye(author)}, stats: ${PackMe.dye(stats)}, comments: ${PackMe.dye(comments)})';
	}
}

class DeleteRequest extends PackMeMessage {
	DeleteRequest({
		required this.postId,
	});
	DeleteRequest.$empty();

	late List<int> postId;

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
		_bytes += 4 + postId.length * 1;
		return _bytes;
	}

	@override
	void $pack() {
		$initPack(486637631);
		$packUint32(postId.length);
		for (int _i6 = 0; _i6 < postId.length; _i6++) {
			$packUint8(postId[_i6]);
		}
	}

	@override
	void $unpack() {
		$initUnpack();
		postId = List<int>.generate($unpackUint32(), (int i) {
			return $unpackUint8();
		});
	}

	@override
	String toString() {
		return 'DeleteRequest\x1b[0m(postId: ${PackMe.dye(postId)})';
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
		$initPack(788388804);
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

final Map<int, PackMeMessage Function()> examplePostsMessageFactory = <int, PackMeMessage Function()>{
	63570112: () => GetAllRequest.$empty(),
	187698222: () => GetRequest.$empty(),
	486637631: () => DeleteRequest.$empty(),
	280110613: () => GetAllResponse.$empty(),
	244485545: () => GetResponse.$empty(),
	788388804: () => DeleteResponse.$empty(),
};