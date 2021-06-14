/// This file allows you to generate Dart source code files for PackMe data
/// protocol using JSON manifest files.
///
/// Usage: dart compile.dart <sourceDirectory> <destinationDirectory>
///
/// JSON Manifest file represents a set of commands, each command consists of
/// one (single message) or two (request and response) messages. In your server
/// code you mostly listen for request messages from client and reply with
/// response messages. However it totally depends on your architecture: server
/// may as well send request messages and in some cases client may process those
/// requests without reply. Though using single messages are preferred in such
/// cases.
///
/// The reason why each command is strictly divided on two messages (instead of
/// just using raw messages) is to make manifest structure as clear as possible.
/// I.e. when you look at some command you already know how it is supposed to
/// work, not just some random message which will be used by server or client in
/// unobvious ways.
///
/// Another thing worth mentioning is that it is not possible to separately
/// declare a message (like in FlatBuffers or ProtoBuffers) and then reuse it in
/// different commands. Here's why: if you look carefully in .json examples you
/// will see that the same entities (like user) in different commands have
/// different set of parameters. You don't want to encode the whole user's
/// profile when you need to send a list of friends. Or when you need to show
/// short user info on the post etc. Reusing declared messages firstly leads to
/// encoding and transferring unused data, and secondly makes it hard to
/// refactor your data protocol when different parts of your application are
/// being changed.
///
/// Nested object in command request or response will be represented with class
/// SomeCommandResponsNested. For example compiling example-posts.json will
/// result in creating class GetResponseCommentAuthor which will contain three
/// fields: List<int> id, String nickname and String avatar.
///
/// Prefix "?" in field declaration means it is optional (Null by default).

import 'package:packme/compiler.dart' as compiler;

void main(List<String> args) {
	compiler.main(args);
}