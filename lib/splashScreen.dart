import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_chat_app/chatScreen.dart';
import 'package:flutter_socket_chat_app/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 0.9],
          colors: [
            Color(0xFFFC5C7D),
            Color(0xFF6A82FB),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 90.0),
      child: Hero(
        tag: 'HeroLogoImage',
        child: AnimationLogo(
          animationTime: 1000,
          onAnimationCompleted: () {
            _onAnimationCompleted(context);
          },
        ),
      ),
    );
  }

  _onAnimationCompleted(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => ChatScreen(),
        ),
      );
    }
  }
}

class AnimationLogo extends StatefulWidget {
  final VoidCallback onAnimationCompleted;
  final int animationTime;

  const AnimationLogo(
      {Key key, this.onAnimationCompleted, this.animationTime = 2000})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AnimationLogoState();
  }
}

class AnimationLogoState extends State<AnimationLogo>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: widget.animationTime), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn)
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          widget.onAnimationCompleted?.call();
        }
      });
    _playAnimation();
  }

  Future<void> _playAnimation() async {
    await new Future.delayed(Duration(seconds: 1));
    controller.forward();
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedLogo(
        animation: animation,
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class AnimatedLogo extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);
  static final _sizeTween = Tween<double>(begin: 0, end: 150);

  AnimatedLogo({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Opacity(
      opacity: _opacityTween.evaluate(animation),
      child: Image.asset(
        'assets/images/logo.png',
        height: _sizeTween.evaluate(animation),
        fit: BoxFit.fill,
      ),
    );
  }
}
