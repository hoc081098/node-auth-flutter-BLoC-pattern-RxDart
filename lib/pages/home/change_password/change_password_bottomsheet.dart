import 'dart:async';

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
  Animation<double> _messageOpacity;

  ChangePasswordBloc _changePasswordBloc;
  StreamSubscription _subscription;

  FocusNode _newPasswordFocusNode;

  @override
  void initState() {
    super.initState();

    _fadeMessageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _messageOpacity = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeMessageController,
        curve: Curves.bounceIn,
      ),
    );

    _changePasswordBloc = widget.initBloc();
    _subscription =
        _changePasswordBloc.changePasswordState$.listen((state) async {
      if (state.message != null) {
        _fadeMessageController.reset();
        await _fadeMessageController.forward();

        if (state?.error == null) {
          Navigator.of(context).pop();
        }
      }
    });

    _newPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _subscription.cancel();
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
          onSubmitted: () {
            FocusScope.of(context).requestFocus(_newPasswordFocusNode);
          },
          textInputAction: TextInputAction.next,
          focusNode: null,
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
          focusNode: _newPasswordFocusNode,
          onSubmitted: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          textInputAction: TextInputAction.done,
        );
      },
    );

    final messageText = StreamBuilder<ChangePasswordState>(
      stream: _changePasswordBloc.changePasswordState$,
      builder: (context, snapshot) {
        final message = snapshot.data?.message;
        if (message != null) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: FadeTransition(
              opacity: _messageOpacity,
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
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
            padding: const EdgeInsets.all(12),
            elevation: 8,
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              _changePasswordBloc.changePassword();
            },
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
