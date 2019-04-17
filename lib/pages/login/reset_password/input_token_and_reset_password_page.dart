import 'package:flutter/material.dart';

class InputTokenAndResetPasswordPage extends StatefulWidget {
  final VoidCallback toggle;

  const InputTokenAndResetPasswordPage({Key key, @required this.toggle})
      : super(key: key);

  @override
  _InputTokenAndResetPasswordPageState createState() =>
      _InputTokenAndResetPasswordPageState();
}

class _InputTokenAndResetPasswordPageState
    extends State<InputTokenAndResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset password'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Good'),
            RaisedButton(
              onPressed: widget.toggle,
              child: Text('Toggle'),
            )
          ],
        ),
      ),
    );
  }
}
