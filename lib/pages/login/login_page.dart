import 'dart:async';

import 'package:flutter/material.dart';
import 'package:node_auth/pages/home/home.dart';
import 'package:node_auth/pages/login/login_bloc.dart';
import 'package:node_auth/pages/login/reset_password_dialog.dart';

class LoginPage extends StatefulWidget {
  final LoginBloc Function() initBloc;

  const LoginPage({Key key, @required this.initBloc}) : super(key: key);

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin<LoginPage> {
  bool _obscurePassword = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController _loginButtonController;
  Animation<double> _buttonSqueezeAnimation;

  LoginBloc _loginBloc;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _loginButtonController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 2000,
      ),
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
    _subscription = _loginBloc.message$.listen((message) {
      if (message is LoginSuccessMessage) {
        _loginButtonController.reverse();
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Login successfully')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomePage(),
            fullscreenDialog: true,
            maintainState: false,
          ),
          ModalRoute.withName(Navigator.defaultRouteName),
        );
      }
      if (message is LoginErrorMessage) {
        _loginButtonController.reverse();
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      }
    });
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    _subscription.cancel();
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField = StreamBuilder<String>(
      stream: _loginBloc.emailError$,
      builder: (context, snapshot) {
        return TextField(
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
        );
      },
    );

    final passwordTextField = StreamBuilder<String>(
      stream: _loginBloc.passwordError$,
      builder: (context, snapshot) {
        return TextField(
          autocorrect: true,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            errorText: snapshot.data,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility),
              iconSize: 18.0,
            ),
            labelText: 'Password',
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.lock),
            ),
          ),
          keyboardType: TextInputType.text,
          maxLines: 1,
          style: TextStyle(fontSize: 16.0),
          onChanged: _loginBloc.passwordChanged,
        );
      },
    );

    final loginButton = AnimatedBuilder(
      animation: _buttonSqueezeAnimation,
      child: StreamBuilder<bool>(
        initialData: _loginBloc.isValidSubmit$.value,
        stream: _loginBloc.isValidSubmit$,
        builder: (context, snapshot) {
          return MaterialButton(
            onPressed: snapshot.data ? _login : null,
            color: Theme.of(context).backgroundColor,
            child: Text(
              'LOGIN',
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
            splashColor: Color(0xFF00e676),
          );
        },
      ),
      builder: (context, child) {
        var value = _buttonSqueezeAnimation.value;

        return Container(
          width: value,
          height: 60.0,
          child: Material(
            elevation: 5.0,
            shadowColor: Theme.of(context).accentColor,
            borderRadius: BorderRadius.circular(24.0),
            child: value > 75.0
                ? child
                : Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 10.0,
                    ),
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
      onPressed: () {
        Navigator.of(context).pushNamed('/register_page');
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
      ),
    );
  }

  void _login() {
    _loginButtonController.reset();
    _loginButtonController.forward();
    _loginBloc.submitLogin();
  }

  void _resetPassword() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ResetPasswordDialog(),
    );
  }
}
