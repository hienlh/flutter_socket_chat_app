import 'package:equatable/equatable.dart';
import 'package:socket_io_client/socket_io_client.dart';

abstract class ChatEvent extends Equatable {
  ChatEvent([List props = const []]) : super(props);
}

class ConnectChat extends ChatEvent {
  final Function(dynamic) onFirstConnect;
  final Function(dynamic) onNewMessage;

  ConnectChat({this.onFirstConnect, this.onNewMessage});

  @override
  String toString() => 'ConnectChat';
}

class ConnectedChat extends ChatEvent {
  final Socket socket;

  ConnectedChat(this.socket);

  @override
  String toString() => 'ConnectChat';
}

class ConnectChatError extends ChatEvent {
  final Object error;

  ConnectChatError(this.error);

  @override
  String toString() => 'ConnectChatError ($error)';
}

class SentMessage extends ChatEvent {
  final String message;

  SentMessage(this.message);

  @override
  String toString() => 'SentMessage ($message)';
}

class DisconnectChat extends ChatEvent {
  @override
  String toString() => 'DisconnectChat';
}

class FirstConnect extends ChatEvent {
  final dynamic data;

  FirstConnect(this.data);

  @override
  String toString() => 'First Connect ($data)';
}

class NewMessage extends ChatEvent {
  final dynamic data;

  NewMessage(this.data);

  @override
  String toString() => 'New Message ($data)';
}

class Idle extends ChatEvent {
  @override
  String toString() => 'Idle';
}
