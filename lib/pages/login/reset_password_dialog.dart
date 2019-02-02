import 'package:flutter/material.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/data/models/my_http_exception.dart';

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
