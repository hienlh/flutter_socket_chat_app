import 'package:bloc/bloc.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter_socket_chat_app/repositories/repository.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'event.dart';
import 'state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Repository _repository = Repository.instance;
  List<ChatMessage> _chatMessages = [];
  ChatUser _chatUser;

  Socket _socket;

  @override
  ChatState get initialState => ChatUninitialized();

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is ConnectChat) {
      yield ChatConnecting();
      _socket = await _repository.connectChatSocket(
          onConnect: _dispatchConnected,
          onReconnect: _dispatchConnected,
          onReconnecting: _dispatchConnected,
          onReconnectAttempt: _dispatchConnected,
          onConnectError: _dispatchConnectError,
          onConnectTimeout: _dispatchConnectError,
          onError: _dispatchConnectError,
          onReconnectError: _dispatchConnectError,
          onReconnectFailed: _dispatchConnectError,
          onNewMessage: _dispatchNewMessage,
          onFirstConnect: _dispatchFirstConnect);
      yield ChatConnecting();
    }

    if (event is DisconnectChat) {
      _socket.disconnect();
    }

    if (event is ConnectedChat) {
      yield ChatConnected(event.socket);
    }

    if (event is ConnectChatError) {
      yield ChatConnectFailure(event.error);
    }

    if (event is SentMessage) {
      _repository.sendMessageToChatSocket(event.message);
    }

    if (event is FirstConnect) {
      List<dynamic> list = event.data['messages'];
      _chatMessages = list.map((item) {
        return ChatMessage(
            id: item['id'],
            text: item['text'],
            user: ChatUser.fromJson(item['user']),
            createdAt: DateTime.parse(item['createdAt']));
      }).toList();
      _chatUser = ChatUser.fromJson(event.data['user']);
      yield ChatFirstConnect(_chatMessages, _chatUser);
    }

    if (event is NewMessage) {
      ChatMessage message = ChatMessage(
        id: event.data['id'],
        text: event.data['text'],
        user: ChatUser.fromJson(event.data['user']),
        createdAt: DateTime.parse(event.data['createdAt']).toLocal(),
      );
      _chatMessages.add(message);
      yield ChatHasNewMessage(_chatMessages);
    }
  }

  void _dispatchConnected([_]) {
    this.dispatch(ConnectedChat(_socket));
  }

  void _dispatchConnectError(dynamic error) {
    this.dispatch(ConnectChatError(error));
  }

  void _dispatchFirstConnect(dynamic data) {
    this.dispatch(FirstConnect(data));
  }

  void _dispatchNewMessage(dynamic data) {
    this.dispatch(NewMessage(data));
  }
}
