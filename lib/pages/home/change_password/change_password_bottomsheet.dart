import 'package:flutter/material.dart';
import 'package:node_auth/pages/home/change_password/change_password.dart';
import 'package:node_auth/widgets/password_textfield.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  final ChangePasswordBloc Function() initBloc;

  const ChangePasswordBottomSheet({
    Key key,
    @required this.initBloc,
  }) : super(key: key);

  @override
  _ChangePasswordBottomSheetState createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet>
    with SingleTickerProviderStateMixin<ChangePasswordBottomSheet> {
  AnimationController _fadeMessageController;
  ChangePasswordBloc _changePasswordBloc;

  @override
  void initState() {
    super.initState();

    _fadeMessageController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _changePasswordBloc = widget.initBloc();
  }

  @override
  void dispose() {
    _fadeMessageController.dispose();
    _changePasswordBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordTextField = StreamBuilder<String>(
      stream: _changePasswordBloc.passwordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          onChanged: _changePasswordBloc.passwordChanged,
          labelText: 'Old password',
        );
      },
    );

    final newPasswordTextField = StreamBuilder<String>(
      stream: _changePasswordBloc.newPasswordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          onChanged: _changePasswordBloc.newPasswordChanged,
          labelText: 'New password',
        );
      },
    );

    final messageText = StreamBuilder<ChangePasswordState>(
      stream: _changePasswordBloc.changePasswordState$,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final message = data?.message;

        if (message != null) {
          _fadeMessageController.reset();
          _fadeMessageController.reverse(from: 1).then((_) {
            if (data?.error == null) {
              Navigator.of(context).pop();
            }
          });

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _fadeMessageController,
                  curve: Curves.easeOut,
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          );
        }
        return Container(width: 0, height: 0);
      },
    );

    final changePasswordButton = StreamBuilder<ChangePasswordState>(
      stream: _changePasswordBloc.changePasswordState$,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data.isLoading) {
          return RaisedButton(
            padding: const EdgeInsets.all(16),
            elevation: 8,
            onPressed: _changePasswordBloc.changePassword,
            child: Text(
              "Change password",
              style: TextStyle(fontSize: 16.0),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: passwordTextField,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: newPasswordTextField,
          ),
          messageText,
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: changePasswordButton,
          )
        ],
      ),
    );
  }
}
