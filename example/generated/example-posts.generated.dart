import 'dart:typed_data';
import 'package:packme/packme.dart';

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
		for (final int item in id) $packUint8(item);
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

	@override
	String toString() {
		return 'GetAllResponsePostAuthor\x1b[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, avatar: ${PackMe.dye(avatar)})';
	}
}

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
		for (final int item in id) $packUint8(item);
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

class GetAllResponse extends PackMeMessage {
	GetAllResponse({
		required this.posts,
	});
	GetAllResponse.$empty();

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
		for (final GetAllResponsePost item in posts) $packMessage(item);
	}

	@override
	void $unpack() {
		$initUnpack();
		posts = <GetAllResponsePost>[];
		final int postsLength = $unpackUint32();
		for (int i = 0; i < postsLength; i++) {
			posts.add($unpackMessage(GetAllResponsePost.$empty()));
		}
	}

	@override
	String toString() {
		return 'GetAllResponse\x1b[0m(posts: ${PackMe.dye(posts)})';
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

	@override
	String toString() {
		return 'GetAllRequest\x1b[0m()';
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
		for (final int item in id) $packUint8(item);
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

	@override
	String toString() {
		return 'GetResponseAuthor\x1b[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, avatar: ${PackMe.dye(avatar)}, facebookId: ${PackMe.dye(facebookId)}, twitterId: ${PackMe.dye(twitterId)}, instagramId: ${PackMe.dye(instagramId)})';
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

	@override
	String toString() {
		return 'GetResponseStats\x1b[0m(likes: ${PackMe.dye(likes)}, dislikes: ${PackMe.dye(dislikes)})';
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
		for (final int item in id) $packUint8(item);
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

	@override
	String toString() {
		return 'GetResponseCommentAuthor\x1b[0m(id: ${PackMe.dye(id)}, nickname: ${PackMe.dye(nickname)}, avatar: ${PackMe.dye(avatar)})';
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
		author = $unpackMessage(GetResponseCommentAuthor.$empty());
		comment = $unpackString();
		posted = $unpackDateTime();
	}

	@override
	String toString() {
		return 'GetResponseComment\x1b[0m(author: ${PackMe.dye(author)}, comment: ${PackMe.dye(comment)}, posted: ${PackMe.dye(posted)})';
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
		for (final GetResponseComment item in comments) $packMessage(item);
	}

	@override
	void $unpack() {
		$initUnpack();
		title = $unpackString();
		content = $unpackString();
		posted = $unpackDateTime();
		author = $unpackMessage(GetResponseAuthor.$empty());
		stats = $unpackMessage(GetResponseStats.$empty());
		comments = <GetResponseComment>[];
		final int commentsLength = $unpackUint32();
		for (int i = 0; i < commentsLength; i++) {
			comments.add($unpackMessage(GetResponseComment.$empty()));
		}
	}

	@override
	String toString() {
		return 'GetResponse\x1b[0m(title: ${PackMe.dye(title)}, content: ${PackMe.dye(content)}, posted: ${PackMe.dye(posted)}, author: ${PackMe.dye(author)}, stats: ${PackMe.dye(stats)}, comments: ${PackMe.dye(comments)})';
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
		int bytes = 8;
		bytes += 4;
		bytes += 1 * postId.length;
		return bytes;
	}

	@override
	void $pack() {
		$initPack(187698222);
		$packUint32(postId.length);
		for (final int item in postId) $packUint8(item);
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

	@override
	String toString() {
		return 'GetRequest\x1b[0m(postId: ${PackMe.dye(postId)})';
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

	@override
	String toString() {
		return 'DeleteResponse\x1b[0m(error: ${PackMe.dye(error)})';
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
		int bytes = 8;
		bytes += 4;
		bytes += 1 * postId.length;
		return bytes;
	}

	@override
	void $pack() {
		$initPack(486637631);
		$packUint32(postId.length);
		for (final int item in postId) $packUint8(item);
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

	@override
	String toString() {
		return 'DeleteRequest\x1b[0m(postId: ${PackMe.dye(postId)})';
	}
}

final Map<int, PackMeMessage Function()> examplePostsMessageFactory = <int, PackMeMessage Function()>{
	280110613: () => GetAllResponse.$empty(),
	63570112: () => GetAllRequest.$empty(),
	244485545: () => GetResponse.$empty(),
	187698222: () => GetRequest.$empty(),
	788388804: () => DeleteResponse.$empty(),
	486637631: () => DeleteRequest.$empty(),
};