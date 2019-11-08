import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_socket_chat_app/chatScreen.dart';
import 'package:flutter_socket_chat_app/widgets/loadingButton.dart';
import 'package:flutter_socket_chat_app/widgets/loginButton.dart';
import 'package:flutter_socket_chat_app/widgets/loginTextInput.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class LoginForm extends StatefulWidget {
  final GestureTapCallback onTap;

  const LoginForm({Key key, this.onTap}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginFormState();
  }
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _loginButton = GlobalKey<LoadingButtonState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _autoValidate;

  @override
  void initState() {
    _autoValidate = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: new LinearGradient(
                  colors: <Color>[
                    const Color.fromRGBO(88, 39, 176, 0.5),
                    const Color.fromRGBO(156, 39, 176, 0.6),
                    const Color.fromRGBO(0, 0, 0, 0.7),
                  ],
                  stops: [0.1, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: 'HeroLogoImage',
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 200,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Divider(color: Colors.transparent),
                    LoginTextInput(
                      controller: _usernameController,
                      hint: 'Email / Tên đăng nhập',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                      obscure: false,
                    ),
                    Divider(color: Colors.transparent),
                    LoginTextInput(
                      controller: _passwordController,
                      hint: 'Mật khẩu',
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    Divider(color: Colors.transparent),
                    LoginButton(
                      loadingKey: _loginButton,
                      text: "Đăng nhập",
                      onPressed: () async {
                        if (_validateInputs()) {
                          Client client = Client();
                          try {
                            final response = await client.post(
                                'http://resman-web-admin-api.herokuapp.com/api/users/login',
                                body: {
                                  'usernameOrEmail': _usernameController.text,
                                  'password': _passwordController.text
                                });
                            print(response.body);
                            if (response.statusCode == 200) {
                              final token =
                                  response.body.toString().replaceAll('"', '');

                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('token', token);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => ChatScreen(),
                                ),
                              );
                            } else {
                              String message;
                              try {
                                message = jsonDecode(response.body)['message'];
                                Toast.show('Login Fail: $message', context, duration: 2);
                              } catch (e) {
                                Toast.show('Login Fail', context, duration: 2);
                              }
                            }
                          } catch (e) {
                            Toast.show('Login Fail', context, duration: 2);
                          }
                        }
                        _loginButton.currentState.loadingComplete();
                      },
                    ),
                    Divider(
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    bool result = _formKey.currentState.validate();
    if (!result) {
      setState(() {
        _autoValidate = true;
      });
    }
    return result;
  }
}
