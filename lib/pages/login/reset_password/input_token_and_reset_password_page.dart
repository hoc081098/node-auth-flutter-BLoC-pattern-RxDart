import 'dart:async';

import 'package:flutter/material.dart';
import 'package:node_auth/pages/login/reset_password/input_token_and_reset_password_bloc.dart';
import 'package:node_auth/widgets/password_textfield.dart';

class InputTokenAndResetPasswordPage extends StatefulWidget {
  final VoidCallback toggle;
  final ValueGetter<InputTokenAndResetPasswordBloc> initBloc;

  const InputTokenAndResetPasswordPage({
    Key key,
    @required this.toggle,
    @required this.initBloc,
  }) : super(key: key);

  @override
  _InputTokenAndResetPasswordPageState createState() =>
      _InputTokenAndResetPasswordPageState();
}

class _InputTokenAndResetPasswordPageState
    extends State<InputTokenAndResetPasswordPage>
    with SingleTickerProviderStateMixin<InputTokenAndResetPasswordPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  InputTokenAndResetPasswordBloc _resetPasswordBloc;
  List<StreamSubscription> _subscriptions;

  FocusNode _tokenFocusNode;
  FocusNode _passwordFocusNode;

  AnimationController _fadeController;
  Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: _fadeController,
      ),
    );

    _tokenFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _resetPasswordBloc = widget.initBloc();
    _subscriptions = <StreamSubscription>[
      _resetPasswordBloc.message$.listen((message) async {
        await _showSnackBar(_getMessageString(message));
        if (message is ResetPasswordSuccess) {
          Navigator.pop<String>(context, message.email);
        }
      }),
      _resetPasswordBloc.isLoading$.listen((isLoading) {
        if (isLoading) {
          _fadeController.forward();
        } else {
          _fadeController.reverse();
        }
      }),
    ];
  }

  static String _getMessageString(InputTokenAndResetPasswordMessage msg) {
    if (msg is InvalidInformation) {
      return 'Invalid information. Try again';
    }
    if (msg is ResetPasswordSuccess) {
      return 'Reset password successfully';
    }
    if (msg is ResetPasswordFailure) {
      return msg.message;
    }
    return 'An unexpected error has occurred';
  }

  Future<void> _showSnackBar(String message) => _scaffoldKey.currentState
      ?.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      )
      ?.closed;

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _fadeController.dispose();
    _resetPasswordBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField = StreamBuilder<String>(
      stream: _resetPasswordBloc.emailError$,
      builder: (context, snapshot) {
        return TextField(
          autocorrect: true,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.email),
            ),
            labelText: 'Email',
            errorText: snapshot.data,
          ),
          keyboardType: TextInputType.emailAddress,
          maxLines: 1,
          autofocus: true,
          onChanged: _resetPasswordBloc.emailChanged,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_tokenFocusNode);
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    final tokenTextField = StreamBuilder<String>(
      stream: _resetPasswordBloc.tokenError$,
      builder: (context, snapshot) {
        return TextField(
          autocorrect: true,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.security),
            ),
            labelText: 'Token',
            errorText: snapshot.data,
          ),
          keyboardType: TextInputType.text,
          maxLines: 1,
          focusNode: _tokenFocusNode,
          onChanged: _resetPasswordBloc.tokenChanged,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    final passwordTextField = StreamBuilder<String>(
      stream: _resetPasswordBloc.passwordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          onChanged: _resetPasswordBloc.passwordChanged,
          labelText: 'Password',
          onSubmitted: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          textInputAction: TextInputAction.done,
          focusNode: _passwordFocusNode,
        );
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Reset password'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(0xBF),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: emailTextField,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: tokenTextField,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: passwordTextField,
                ),
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: RaisedButton(
                    child: Text('Submit'),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Theme.of(context).cardColor,
                    splashColor: Theme.of(context).accentColor,
                    onPressed: _resetPasswordBloc.submit,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: RaisedButton(
                    child: Text('Request email'),
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).cardColor,
                    splashColor: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onPressed: widget.toggle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
