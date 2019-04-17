import 'dart:async';

import 'package:flutter/material.dart';
import 'package:node_auth/pages/register/register.dart';
import 'package:node_auth/widgets/password_textfield.dart';

class RegisterPage extends StatefulWidget {
  final RegisterBloc Function() initBloc;

  const RegisterPage({
    Key key,
    @required this.initBloc,
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController _registerButtonController;
  Animation<double> _buttonSqueezeAnimation;

  RegisterBloc _registerBloc;
  List<StreamSubscription> _subscriptions;

  FocusNode _emailFocusNode;
  FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();

    _registerButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _buttonSqueezeAnimation = Tween(
      begin: 320.0,
      end: 70.0,
    ).animate(
      CurvedAnimation(
        parent: _registerButtonController,
        curve: Interval(0.0, 0.250),
      ),
    );

    _registerBloc = widget.initBloc();
    _subscriptions = [
      _registerBloc.message$.listen(_handleMessage),
      _registerBloc.isLoading$.listen((isLoading) {
        if (isLoading) {
          _registerButtonController
            ..reset()
            ..forward();
        } else {
          _registerButtonController.reverse();
        }
      })
    ];

    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  void _handleMessage(RegisterMessage message) async {
    if (message is RegisterSuccessMessage) {
      await _showMessage('Register successfully');
      Navigator.pop<String>(context, message.email);
    }
    if (message is RegisterErrorMessage) {
      await _showMessage(message.message);
    }
    if (message is RegisterInvalidInformationMessage) {
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
    _subscriptions.forEach((s) => s.cancel());
    _registerButtonController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField = StreamBuilder<String>(
      stream: _registerBloc.emailError$,
      builder: (context, snapshot) {
        return TextField(
          onChanged: _registerBloc.emailChanged,
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
          focusNode: _emailFocusNode,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          textInputAction: TextInputAction.next,
        );
      },
    );

    final passwordTextField = StreamBuilder<String>(
      stream: _registerBloc.passwordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          labelText: 'Password',
          onChanged: _registerBloc.passwordChanged,
          focusNode: _passwordFocusNode,
          onSubmitted: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          textInputAction: TextInputAction.done,
        );
      },
    );

    final registerButton = AnimatedBuilder(
      animation: _buttonSqueezeAnimation,
      child: MaterialButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());
          _registerBloc.submitRegister();
        },
        color: Theme.of(context).backgroundColor,
        child: Text(
          'REGISTER',
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

    final nameTextField = StreamBuilder<String>(
      stream: _registerBloc.nameError$,
      builder: (context, snapshot) {
        return TextField(
          autocorrect: true,
          onChanged: _registerBloc.nameChanged,
          decoration: InputDecoration(
            labelText: 'Name',
            errorText: snapshot.data,
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.person),
            ),
          ),
          keyboardType: TextInputType.text,
          maxLines: 1,
          style: TextStyle(fontSize: 16.0),
          autofocus: true,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_emailFocusNode);
          },
          textInputAction: TextInputAction.next,
        );
      },
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[BackButton(color: Colors.white)],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: nameTextField,
                      ),
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
                        child: registerButton,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
