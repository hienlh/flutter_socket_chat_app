import 'package:dash_chat/dash_chat.dart';
import 'package:equatable/equatable.dart';
import 'package:socket_io_client/socket_io_client.dart';

abstract class ChatState extends Equatable {
  ChatState([List props = const []]) : super(props);
}

class ChatUninitialized extends ChatState {
  @override
  String toString() => 'ChatUninitialized';
}

class ChatConnecting extends ChatState {
  @override
  String toString() => 'ChatConnecting';
}

class ChatConnected extends ChatState {
  final Socket socket;

  ChatConnected(this.socket);
  
  @override
  String toString() => 'ChatConnected';
}

class ChatConnectFailure extends ChatState {
  final dynamic error;

  ChatConnectFailure(this.error);

  @override
  String toString() => 'ChatConnectFailure $error';
}

class ChatFirstConnect extends ChatState {
  final List<ChatMessage> chatMessages;
  final ChatUser user;

  ChatFirstConnect(this.chatMessages, this.user);

  @override
  String toString() => 'ChatFirstConnect (${user.name})';
}

class ChatHasNewMessage extends ChatState {
  final List<ChatMessage> chatMessages;

  ChatHasNewMessage(this.chatMessages);

  @override
  String toString() => 'ChatHasNewMessage (${chatMessages[chatMessages.length - 1]})';
}


