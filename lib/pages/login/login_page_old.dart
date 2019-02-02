import 'dart:async';

import 'package:flutter/material.dart';
import 'package:node_auth/data/remote/api_service.dart';
import 'package:node_auth/data/models/my_http_exception.dart';
import 'package:node_auth/data/models/response.dart';
import 'package:node_auth/pages/home/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  String _email, _password;
  static const String emailRegExpString =
      r'[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+';
  static final RegExp emailRegExp =
      RegExp(emailRegExpString, caseSensitive: false);
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController _loginButtonController;
  Animation<double> _buttonSqueezeAnimation;

  ApiService apiService;

  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _buttonSqueezeAnimation = Tween(
      begin: 320.0,
      end: 70.0,
    ).animate(CurvedAnimation(
        parent: _loginButtonController, curve: Interval(0.0, 0.250)))
      ..addListener(() {
        debugPrint(_buttonSqueezeAnimation.value.toString());
        setState(() {});
      });
    apiService = ApiService();
  }

  @override
  void dispose() {
    super.dispose();
    _loginButtonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField = TextFormField(
      autocorrect: true,
      autovalidate: true,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: Icon(Icons.email),
        ),
        labelText: 'Email',
      ),
      keyboardType: TextInputType.emailAddress,
      maxLines: 1,
      style: TextStyle(fontSize: 16.0),
      onSaved: (s) => _email = s,
      validator: (s) =>
          emailRegExp.hasMatch(s) ? null : 'Invalid email address!',
    );

    final passwordTextField = TextFormField(
      autocorrect: true,
      autovalidate: true,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon:
              Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
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
      onSaved: (s) => _password = s,
      validator: (s) => s.length < 6 ? "Minimum length of password is 6" : null,
    );

    final loginButton = Container(
      width: _buttonSqueezeAnimation.value,
      height: 60.0,
      child: Material(
        elevation: 5.0,
        shadowColor: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(24.0),
        child: _buttonSqueezeAnimation.value > 75.0
            ? MaterialButton(
                onPressed: _login,
                color: Theme.of(context).backgroundColor,
                child: Text(
                  'LOGIN',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                splashColor: Color(0xFF00e676),
              )
            : Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
      ),
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
                    Colors.black.withAlpha(0xBF), BlendMode.darken))),
        child: Center(
          child: Form(
            key: _formKey,
            autovalidate: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
    if (!_formKey.currentState.validate()) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('Invalid information')),
      );
      return;
    }

    _formKey.currentState.save();
    _loginButtonController.reset();
    _loginButtonController.forward();

    apiService.loginUser(_email, _password).then((Response response) {
      _loginButtonController.reverse();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(response.message)),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(),
          fullscreenDialog: true,
          maintainState: false,
        ),
      );
    }).catchError((error) {
      _loginButtonController.reverse();
      final message =
          error is MyHttpException ? error.message : 'Unknown error occurred';
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  _resetPassword() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ResetPasswordDialog();
      },
    );
  }
}

class ResetPasswordDialog extends StatefulWidget {
  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  String _email, _token, _newPassword;

  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  bool _isInit;
  bool _obscurePassword;
  bool _isLoading;
  String _message;

  @override
  void initState() {
    super.initState();
    _isInit = true;
    _obscurePassword = true;
    _isLoading = false;
    _message = null;
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField = TextFormField(
      autocorrect: true,
      autovalidate: true,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: Icon(Icons.email),
        ),
        labelText: 'Email',
      ),
      keyboardType: TextInputType.emailAddress,
      maxLines: 1,
      style: TextStyle(fontSize: 16.0),
      onSaved: (s) => _email = s,
      validator: (s) => _MyLoginPageState.emailRegExp.hasMatch(s)
          ? null
          : 'Invalid email address!',
    );

    final tokenTextField = TextFormField(
      autocorrect: true,
      autovalidate: true,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: Icon(Icons.email),
        ),
        labelText: 'Token',
      ),
      keyboardType: TextInputType.emailAddress,
      maxLines: 1,
      style: TextStyle(fontSize: 16.0),
      onSaved: (s) => _token = s,
    );

    final passwordTextField = TextFormField(
      autocorrect: true,
      autovalidate: true,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon:
              Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
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
      onSaved: (s) => _newPassword = s,
      validator: (s) => s.length < 6 ? "Minimum length of password is 6" : null,
    );

    return AlertDialog(
      title: Text('Reset password'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Form(
              autovalidate: true,
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: emailTextField,
                  ),
                  _isInit
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: tokenTextField,
                        ),
                  _isInit
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: passwordTextField,
                        ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : _message != null
                            ? Text(
                                _message,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.amber,
                                ),
                              )
                            : Container(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: _onPressed,
        ),
      ],
    );
  }

  _onPressed() {
    if (!_formKey.currentState.validate()) {
      setState(() => _message = 'Invalid information');
      Future.delayed(Duration(seconds: 1))
          .then((_) => setState(() => _message = null));
      return;
    }

    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_isInit) {
      _sendResetEmail();
    } else {
      _resetPassword();
    }
  }

  _sendResetEmail() {
    print("send reset email...");

    _apiService.resetPassword(_email).then((response) {
      setState(() {
        _isInit = _isLoading = false;
        _message = response.message;
      });
      Future.delayed(Duration(seconds: 1))
          .then((_) => setState(() => _message = null));
    }).catchError((e) {
      final message =
          e is MyHttpException ? e.message : "An unknown error occurred";
      setState(() {
        _isLoading = false;
        _message = message;
      });
      Future.delayed(Duration(seconds: 1))
          .then((_) => setState(() => _message = null));
    });
  }

  _resetPassword() {
    print("reset password...");

    _apiService
        .resetPassword(_email, newPassword: _newPassword, token: _token)
        .then((response) {
      setState(() {
        _isLoading = false;
        _isInit = true;
        _message = response.message;
      });
      Future.delayed(Duration(seconds: 1))
          .then((_) => Navigator.of(context).pop());
    }).catchError((e) {
      final message =
          e is MyHttpException ? e.message : "An unknown error occurred";
      setState(() {
        _isLoading = false;
        _message = message;
      });
      Future.delayed(Duration(seconds: 1))
          .then((_) => setState(() => _message = null));
    });
  }
}
