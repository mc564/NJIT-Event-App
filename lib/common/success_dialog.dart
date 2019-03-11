import 'package:flutter/material.dart';

class SuccessDialog extends StatefulWidget {
  final String _successMessage;

  SuccessDialog(this._successMessage);
  @override
  State<StatefulWidget> createState() {
    return _SuccessDialogState();
  }
}

class _SuccessDialogState extends State<SuccessDialog>
    with TickerProviderStateMixin {
  AnimationController _controller;
  int _secondsCountdown = 10;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _secondsCountdown),
    )
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pushReplacementNamed(context, '/');
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.sentiment_satisfied,
            size: 90.0,
            color:Colors.yellow,
          ),
          SizedBox(height: 10.0),
          Text(widget._successMessage),
          SizedBox(height: 10.0),
          RedirectingCountdown(
            animation: StepTween(
              begin: _secondsCountdown,
              end: 0,
            ).animate(_controller),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No, take me back', style: TextStyle(color:Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


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
