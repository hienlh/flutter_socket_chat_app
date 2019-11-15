/**
 * Created by hienlh (HierenLee)
 * Created at 15/11/2019
 */
import 'package:socket_io_client/socket_io_client.dart';

class SocketDisconnectReason {
  static const SERVER_DISCONNECT = 'io server disconnect';
  static const CLIENT_DISCONNECT = 'io client disconnect';
  static const PING_TIMEOUT = 'ping timeout';
}

abstract class SocketProvider {
  Socket _socket;
  final String _url;
  final Map<String, dynamic> _headers;
  Function _onConnect;
  Function(Object) _onConnectError;
  Function(dynamic) _onConnectTimeout;
  Function(Object) _onError;
  Function(String) _onDisconnect;
  Function(int) _onReconnect;
  Function(int) _onReconnectAttempt;
  Function(int) _onReconnecting;
  Function(Object) _onReconnectError;
  Function _onReconnectFailed;
  Function _onPing;
  Function(int) _onPong;

  SocketProvider(this._url, this._headers);

  Socket get socket => _socket;

  /// Override require call super on top of function.
  void connect() {
    _socket = io(_url, _headers);

    _socket.on('connect', (_) {
      print('Connected');
      _onConnect?.call();
    });
    _socket.on('connect_error', _onConnectError);
    _socket.on('connect_timeout', _onConnectTimeout);
    _socket.on('error', _onError);
    _socket.on('disconnect', _onDisconnect);
    _socket.on('reconnect', _onReconnect);
    _socket.on('reconnect_attempt', _onReconnectAttempt);
    _socket.on('reconnecting', _onReconnecting);
    _socket.on('reconnect_error', _onReconnectError);
    _socket.on('reconnect_failed', _onReconnectFailed);
    _socket.on('ping', _onPing);
    _socket.on('pong', _onPong);
  }

  void disconnect() {
    if(_socket != null) {
      _socket.disconnect();
    }
  }

  set onConnect(Function value) {
    _onConnect = value;
  }

  set onConnectError(Function(Object) value) {
    _onConnectError = value;
  }

  set onConnectTimeout(Function(dynamic) value) {
    _onConnectTimeout = value;
  }

  set onError(Function(Object) value) {
    _onError = value;
  }

  set onDisconnect(Function(String) value) {
    _onDisconnect = value;
  }

  set onReconnect(Function(int) value) {
    _onReconnect = value;
  }

  set onReconnectAttempt(Function(int) value) {
    _onReconnectAttempt = value;
  }

  set onReconnecting(Function(int) value) {
    _onReconnecting = value;
  }

  set onReconnectError(Function(Object) value) {
    _onReconnectError = value;
  }

  set onReconnectFailed(Function value) {
    _onReconnectFailed = value;
  }

  set onPing(Function value) {
    _onPing = value;
  }

  set onPong(Function(int) value) {
    _onPong = value;
  }
}
