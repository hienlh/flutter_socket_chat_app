import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_chat_app/loginScreen.dart';
import 'package:flutter_socket_chat_app/widgets/loadingIndicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> chatMessages = [];
  String token;
  Socket socket;
  ChatUser user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen(),
          ),
        );
      } else {
        _connectSocket();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resman User Chat'),
        actions: <Widget>[
          CupertinoButton(
            child: Icon(
              Icons.clear,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                loading = true;
              });

              SharedPreferences.getInstance().then((prefs) {
                prefs.remove('token');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen(),
                  ),
                );
              });
            },
          )
        ],
      ),
      body: loading
          ? LoadingIndicator()
          : DashChat(
        user: user,
        messages: chatMessages,
        onSend: (ChatMessage chatMessage) {
          socket.emit('global_message', chatMessage.text);

          var list = chatMessages;
          list.add(chatMessage);

          setState(() {
            chatMessages = list;
          });
        },
        showAvatarForEveryMessage: false,
      ),
    );
  }

  void _connectSocket() {
    socket = io(
      'https://resman-web-admin-api.herokuapp.com/user-chat',
      <String, dynamic>{
        'transports': ['websocket'],
        'extraHeaders': {'Authorization': token}
      },
    );

    socket.on('connect', (_) {
      setState(() {
        loading = false;
      });
    });

    socket.on('first_connect', (data) {
      List<dynamic> list = data['messages'];

      setState(() {
        chatMessages = list.map((item) {
          return ChatMessage(
              id: item['id'],
              text: item['text'],
              user: ChatUser.fromJson(item['user']),
              createdAt: DateTime.parse(item['createdAt']));
        }).toList();
        user = ChatUser.fromJson(data['user']);
      });
    });

    socket.on('new_message', (data) {
      ChatMessage message = ChatMessage(
        id: data['id'],
        text: data['text'],
        user: ChatUser.fromJson(data['user']),
        createdAt: DateTime.parse(data['createdAt']).toLocal(),
      );

      var list = chatMessages;
      list.add(message);

      setState(() {
        chatMessages = list;
      });
    });
  }
}