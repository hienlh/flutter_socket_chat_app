import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_socket_chat_app/blocs/authenticationBloc/event.dart';
import 'package:flutter_socket_chat_app/blocs/chatBloc/bloc.dart';
import 'package:flutter_socket_chat_app/blocs/chatBloc/state.dart';
import 'package:flutter_socket_chat_app/widgets/loadingIndicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/authenticationBloc/bloc.dart';
import 'blocs/chatBloc/event.dart';
import 'loginScreen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> chatMessages = [];
  ChatUser user;

  ChatBloc chatBloc;

  @override
  void initState() {
    super.initState();
    chatBloc = ChatBloc();
    chatBloc.dispatch(ConnectChat());
  }

  @override
  void dispose() {
    chatBloc.dispatch(DisconnectChat());
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
              chatBloc.dispatch(DisconnectChat());
              AuthenticationBloc().dispatch(LoggedOut());
              SharedPreferences.getInstance().then((prefs) {
                prefs.remove('token');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen(
                      authenticationBloc: AuthenticationBloc(),
                    ),
                  ),
                );
              });
            },
          )
        ],
      ),
      body: BlocListener(
        bloc: chatBloc,
        listener: (context, state) {
          if (state is ChatFirstConnect) {
            setState(() {
              chatMessages = state.chatMessages;
              user = state.user;
            });
            chatBloc.dispatch(Idle()); 
          }
          if(state is ChatHasNewMessage) {
            setState(() {
              chatMessages = state.chatMessages;
            });
            chatBloc.dispatch(Idle()); 
          }
        },
        child: BlocBuilder(
          bloc: chatBloc,
          builder: (context, state) {
            if (state is ChatConnectFailure) {
              return Text('Connect failed!');
            }
            if (state is ChatConnecting) {
              return LoadingIndicator();
            }
            return DashChat(
              user: user,
              messages: chatMessages,
              onSend: (ChatMessage chatMessage) {
                chatBloc.dispatch(SentMessage(chatMessage.text));

                var list = chatMessages;
                list.add(chatMessage);

                setState(() {
                  chatMessages = list;
                });
              },
              showAvatarForEveryMessage: false,
            );
          },
        ),
      ),
    );
  }
}
