import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:node_auth/pages/home/change_password/change_password.dart';
import 'package:node_auth/widgets/password_textfield.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({Key key}) : super(key: key);

  @override
  _ChangePasswordBottomSheetState createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet>
    with SingleTickerProviderStateMixin<ChangePasswordBottomSheet> {
  AnimationController fadeMessageController;
  Animation<double> messageOpacity;

  StreamSubscription subscription;
  FocusNode newPasswordFocusNode;

  @override
  void initState() {
    super.initState();

    fadeMessageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    messageOpacity = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: fadeMessageController,
        curve: Curves.bounceIn,
      ),
    );

    newPasswordFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    subscription ??= BlocProvider.of<ChangePasswordBloc>(context)
        .changePasswordState$
        .listen((state) async {
      if (state.message != null) {
        fadeMessageController.reset();
        await fadeMessageController.forward();

        if (state?.error == null) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    fadeMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changePasswordBloc = BlocProvider.of<ChangePasswordBloc>(context);

    final passwordTextField = StreamBuilder<String>(
      stream: changePasswordBloc.passwordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          onChanged: changePasswordBloc.passwordChanged,
          labelText: 'Old password',
          onSubmitted: () {
            FocusScope.of(context).requestFocus(newPasswordFocusNode);
          },
          textInputAction: TextInputAction.next,
          focusNode: null,
        );
      },
    );

    final newPasswordTextField = StreamBuilder<String>(
      stream: changePasswordBloc.newPasswordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          onChanged: changePasswordBloc.newPasswordChanged,
          labelText: 'New password',
          focusNode: newPasswordFocusNode,
          onSubmitted: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          textInputAction: TextInputAction.done,
        );
      },
    );

    final messageText = StreamBuilder<ChangePasswordState>(
      stream: changePasswordBloc.changePasswordState$,
      builder: (context, snapshot) {
        final message = snapshot.data?.message;
        if (message != null) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: FadeTransition(
              opacity: messageOpacity,
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
      stream: changePasswordBloc.changePasswordState$,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data.isLoading) {
          return RaisedButton(
            padding: const EdgeInsets.all(12),
            elevation: 8,
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              changePasswordBloc.changePassword();
            },
            child: Text(
              'Change password',
              style: TextStyle(fontSize: 16.0),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
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
      ),
    );
  }
}
