import 'package:flutter/material.dart';

class RedirectingCountdown extends AnimatedWidget {
  RedirectingCountdown({Key key, this.animation})
      : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Redirecting to home page in ' +
          animation.value.toString() +
          ' seconds...',
      textAlign: TextAlign.center,
    );
  }
}
