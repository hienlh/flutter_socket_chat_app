import 'package:flutter/material.dart';
import 'package:flutter_socket_chat_app/widgets/imageBackground.dart';
import 'package:flutter_socket_chat_app/widgets/loginForm.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading;

  final PageController controller = PageController();
  var currentPageValue = 0.0;

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ImageBackground(),
          PageView.builder(
            controller: controller,
            itemBuilder: (context, position) {
              return Transform(
                transform: Matrix4.identity()
                  ..rotateY(currentPageValue - position)
                  ..rotateZ(currentPageValue - position),
                child: LoginForm(),
              );
            },
            itemCount: 1,
          ),
        ],
      ),
    );
  }
}
