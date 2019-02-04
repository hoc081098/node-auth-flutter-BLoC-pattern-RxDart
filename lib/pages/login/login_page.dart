import 'dart:async';

import 'package:flutter/material.dart';
import 'package:node_auth/pages/login/login.dart';
import 'package:node_auth/pages/login/reset_password_dialog.dart';
import 'package:node_auth/widgets/password_textfield.dart';

class LoginPage extends StatefulWidget {
  final LoginBloc Function() initBloc;

  const LoginPage({Key key, @required this.initBloc}) : super(key: key);

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController _loginButtonController;
  Animation<double> _buttonSqueezeAnimation;

  LoginBloc _loginBloc;
  List<StreamSubscription> _subscriptions;

  FocusNode _passwordFocusNode;
  TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _loginButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _buttonSqueezeAnimation = Tween(
      begin: 320.0,
      end: 70.0,
    ).animate(
      CurvedAnimation(
        parent: _loginButtonController,
        curve: Interval(
          0.0,
          0.250,
        ),
      ),
    );

    _loginBloc = widget.initBloc();
    _subscriptions = [
      _loginBloc.message$.listen(_handleMessage),
      _loginBloc.isLoading$.listen((isLoading) {
        if (isLoading) {
          _loginButtonController
            ..reset()
            ..forward();
        } else {
          _loginButtonController.reverse();
        }
      })
    ];

    _passwordFocusNode = FocusNode();
    _emailController = TextEditingController();
  }

  void _handleMessage(message) async {
    if (message is LoginSuccessMessage) {
      await _showMessage('Login successfully');
      Navigator.of(context).pushReplacementNamed('/home_page');
    }
    if (message is LoginErrorMessage) {
      await _showMessage(message.message);
    }
    if (message is InvalidInformationMessage) {
      await _showMessage('Invalid information');
    }
  }

  Future<void> _showMessage(String message) => _scaffoldKey.currentState
      ?.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      )
      ?.closed;

  @override
  void dispose() {
    _loginButtonController.dispose();
    _subscriptions.forEach((s) => s.cancel());
    _loginBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField = StreamBuilder<String>(
      stream: _loginBloc.emailError$,
      builder: (context, snapshot) {
        return TextField(
          controller: _emailController,
          autocorrect: true,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.email),
            ),
            labelText: 'Email',
            errorText: snapshot.data,
          ),
          keyboardType: TextInputType.emailAddress,
          maxLines: 1,
          style: TextStyle(fontSize: 16.0),
          onChanged: _loginBloc.emailChanged,
          textInputAction: TextInputAction.next,
          autofocus: true,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
        );
      },
    );

    final passwordTextField = StreamBuilder<String>(
      stream: _loginBloc.passwordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          onChanged: _loginBloc.passwordChanged,
          labelText: 'Password',
          textInputAction: TextInputAction.done,
          onSubmitted: () {
            FocusScope.of(context).requestFocus(FocusNode());
            _loginBloc.submitLogin();
          },
          focusNode: _passwordFocusNode,
        );
      },
    );

    final loginButton = AnimatedBuilder(
      animation: _buttonSqueezeAnimation,
      child: MaterialButton(
        onPressed: _loginBloc.submitLogin,
        color: Theme.of(context).backgroundColor,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        splashColor: Theme.of(context).accentColor,
      ),
      builder: (context, child) {
        var value = _buttonSqueezeAnimation.value;

        return Container(
          width: value,
          height: 60.0,
          child: Material(
            elevation: 5.0,
            clipBehavior: Clip.antiAlias,
            shadowColor: Theme.of(context).accentColor,
            borderRadius: BorderRadius.circular(24.0),
            child: value > 75.0
                ? child
                : Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
          ),
        );
      },
    );

    final needAnAccount = FlatButton(
      onPressed: () async {
        final email = await Navigator.pushNamed(context, '/register_page');
        print('[DEBUG] email = $email');
        if (email != null && email is String) {
          _emailController.text = email;
          _loginBloc.emailChanged(email);
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        }
      },
      child: Text(
        "Don't have an account? Sign up",
        style: TextStyle(
          color: Colors.white70,
          fontStyle: FontStyle.italic,
          fontSize: 14.0,
        ),
      ),
    );

    final forgotPassword = FlatButton(
      onPressed: _resetPassword,
      child: Text(
        "Forgot password?",
        style: TextStyle(
          color: Colors.white70,
          fontStyle: FontStyle.italic,
          fontSize: 14.0,
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              color: Colors.transparent,
              width: double.infinity,
              height: kToolbarHeight,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: emailTextField,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: passwordTextField,
                      ),
                      SizedBox(height: 32.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: loginButton,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: needAnAccount,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: forgotPassword,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _resetPassword() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ResetPasswordDialog(),
    );
  }
}
