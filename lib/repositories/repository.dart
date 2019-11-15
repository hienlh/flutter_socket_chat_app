import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../models/userModel.dart';
import '../utils/validateEmail.dart';
import 'dataProviders/chatSocketProvider.dart';
import 'dataProviders/userProvider.dart';

class Repository {
  static Repository _singleton;

  static Repository get instance {
    if (_singleton == null) {
      print('Initialize Repository ...');
      _singleton = Repository._internal();
    }
    return _singleton;
  }

  factory Repository() {
    return instance;
  }

  Repository._internal();

  static const String PrepsTokenKey = 'jwt-login-token';
  static const String PrepsUsernameOrEmail = 'logged-in-username-or-email';
  static const String PrepsCart = 'user-cart';

  final UserProvider _userProvider = UserProvider();
  ChatSocketProvider _chatSocketProvider;

  UserModel _currentUser;

  UserModel get currentUser => _currentUser;

  Future<String> authenticate(
      {@required String usernameOrEmail, @required String password}) async {
    return await _userProvider.login(usernameOrEmail, password);
  }

  Future<void> deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrepsTokenKey); // Delete token
    await prefs.remove(PrepsUsernameOrEmail); // Delete username or email
    _currentUser = null;
    return;
  }

  Future<void> persistToken(String token, String usernameOrEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrepsTokenKey, token); // Save token
    await prefs.setString(
        PrepsUsernameOrEmail, usernameOrEmail); // Save username or email
    print('Persisted token!');
    return;
  }

  Future<bool> hasToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrepsTokenKey) != null;
  }

  Future<void> register(String username, String email, String password) async {
    await _userProvider.register(username, email, password);
  }

  Future<void> fetchCurrentUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final usernameOrEmail = prefs.getString(PrepsUsernameOrEmail);
    final token = prefs.getString(PrepsTokenKey);
    if (validateEmail(usernameOrEmail)) {
      _currentUser =
          await _userProvider.getProfileByEmail(usernameOrEmail, token);
    } else {
      _currentUser =
          await _userProvider.getProfileByUsername(usernameOrEmail, token);
    }
    print(_currentUser);
  }

  Future<Socket> connectChatSocket({
    Function onConnect,
    Function(Object) onConnectError,
    Function(dynamic) onConnectTimeout,
    Function(Object) onError,
    Function(String) onDisconnect,
    Function(int) onReconnect,
    Function(int) onReconnectAttempt,
    Function(int) onReconnecting,
    Function(Object) onReconnectError,
    Function onReconnectFailed,
    Function onPing,
    Function(int) onPong,
    Function(dynamic) onFirstConnect,
    Function(dynamic) onNewMessage,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(PrepsTokenKey);

    _chatSocketProvider = ChatSocketProvider(token);

    _chatSocketProvider.onConnect = onConnect;
    _chatSocketProvider.onConnectError = onConnectError;
    _chatSocketProvider.onConnectTimeout = onConnectTimeout;
    _chatSocketProvider.onError = onError;
    _chatSocketProvider.onDisconnect = onDisconnect;
    _chatSocketProvider.onReconnect = onReconnect;
    _chatSocketProvider.onReconnectAttempt = onReconnectAttempt;
    _chatSocketProvider.onReconnecting = onReconnecting;
    _chatSocketProvider.onReconnectError = onReconnectError;
    _chatSocketProvider.onReconnectFailed = onReconnectFailed;
    _chatSocketProvider.onPing = onPing;
    _chatSocketProvider.onPong = onPong;

    _chatSocketProvider.onFirstConnect = onFirstConnect;
    _chatSocketProvider.onNewMessage = onNewMessage;
    
    _chatSocketProvider.connect();

    return _chatSocketProvider.socket;
  }

  void sendMessageToChatSocket(String message) {
    _chatSocketProvider.sendMessage(message);
  }
}
