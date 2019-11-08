import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> chatMessages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resman User Chat'),
      ),
      body: DashChat(
        user: ChatUser(name: 'Hieren Lee'),
        messages: <ChatMessage>[
          ChatMessage(
            user: ChatUser(
              name: 'abcde',
              avatar:
                  'https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg',
            ),
            text: 'abcd',
          ),
          ChatMessage(
            user: ChatUser(uid: 'abcde', name: 'abcde'),
            text: 'abcd',
          ),
          ChatMessage(
            user: ChatUser(uid: 'abcde', name: 'abcde'),
            text: 'abcd',
          ),
          ChatMessage(
            user: ChatUser(uid: 'abcde', name: 'abcde'),
            text: 'abcd',
          ),
        ],
        onSend: (ChatMessage chatMessage) {
          print(chatMessage.text);
        },
        showAvatarForEveryMessage: false,
      ),
    );
  }
}
