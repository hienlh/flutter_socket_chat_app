import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_socket_chat_app/repositories/dataProviders/socketProvider.dart';

class ChatSocketProvider extends SocketProvider {
  Function(dynamic) _onFirstConnect;
  Function(dynamic) _onNewMessage;

  ChatSocketProvider(String token)
      : super('${DotEnv().env['SERVER_URL']}/user-chat', <String, dynamic>{
          'transports': ['websocket'],
          'extraHeaders': {'Authorization': token}
        });

  @override
  void connect() {
    super.connect();
    if (_onFirstConnect != null) socket?.on('first_connect', _onFirstConnect);
    if (_onNewMessage != null) socket?.on('new_message', _onNewMessage);
  }

  void sendMessage(String message) {
    socket?.emit('global_message', message);
  }

  set onFirstConnect(Function(dynamic) value) {
    _onFirstConnect = value;
  }

  set onNewMessage(Function(dynamic) value) {
    _onNewMessage = value;
  }
}
