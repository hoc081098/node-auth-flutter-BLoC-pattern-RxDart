import 'dart:async';

import 'package:did_change_dependencies/did_change_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:node_auth/pages/home/home.dart';
import 'package:node_auth/pages/login/login.dart';
import 'package:node_auth/pages/register/register.dart';
import 'package:node_auth/pages/reset_password/reset_password_page.dart';
import 'package:node_auth/utils/delay.dart';
import 'package:node_auth/utils/snackbar.dart';
import 'package:node_auth/widgets/password_textfield.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login_page';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<LoginPage>
    with
        SingleTickerProviderStateMixin<LoginPage>,
        DisposeBagMixin,
        DidChangeDependenciesStream {
  late final AnimationController loginButtonController;
  late final Animation<double> buttonSqueezeAnimation;

  final passwordFocusNode = FocusNode();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    loginButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    buttonSqueezeAnimation = Tween(
      begin: 320.0,
      end: 70.0,
    ).animate(
      CurvedAnimation(
        parent: loginButtonController,
        curve: Interval(
          0.0,
          0.250,
        ),
      ),
    );

    didChangeDependencies$
        .exhaustMap((_) => context.bloc<LoginBloc>().message$)
        .exhaustMap(handleMessage)
        .collect()
        .disposedBy(bag);

    didChangeDependencies$
        .exhaustMap((_) => context.bloc<LoginBloc>().isLoading$)
        .listen((isLoading) {
      if (isLoading) {
        loginButtonController
          ..reset()
          ..forward();
      } else {
        loginButtonController.reverse();
      }
    }).disposedBy(bag);
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    loginButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    return Scaffold(
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
                        child: emailTextField(loginBloc),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: passwordTextField(loginBloc),
                      ),
                      const SizedBox(height: 32.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: loginButton(loginBloc),
                      ),
                      const SizedBox(height: 32.0),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: needAnAccount(loginBloc),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: forgotPassword(loginBloc),
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

  Stream<void> handleMessage(message) async* {
    if (message is LoginSuccessMessage) {
      context.showSnackBar('Login successfully');
      await delay(1000);
      yield null;

      context.hideCurrentSnackBar();
      await Navigator.of(context).pushReplacementNamed(HomePage.routeName);
    }
    if (message is LoginErrorMessage) {
      context.showSnackBar(message.message);
    }
    if (message is InvalidInformationMessage) {
      context.showSnackBar('Invalid information');
    }
  }

  Widget emailTextField(LoginBloc loginBloc) {
    return StreamBuilder<String?>(
      stream: loginBloc.emailError$,
      builder: (context, snapshot) {
        return TextField(
          controller: emailController,
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
          onChanged: loginBloc.emailChanged,
          textInputAction: TextInputAction.next,
          autofocus: true,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(passwordFocusNode);
          },
        );
      },
    );
  }

  Widget passwordTextField(LoginBloc loginBloc) {
    return StreamBuilder<String?>(
      stream: loginBloc.passwordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          onChanged: loginBloc.passwordChanged,
          labelText: 'Password',
          textInputAction: TextInputAction.done,
          onSubmitted: () {
            FocusScope.of(context).unfocus();
          },
          focusNode: passwordFocusNode,
        );
      },
    );
  }

  Widget loginButton(LoginBloc loginBloc) {
    return AnimatedBuilder(
      animation: buttonSqueezeAnimation,
      child: MaterialButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          loginBloc.submitLogin();
        },
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
        final value = buttonSqueezeAnimation.value;

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
  }

  Widget needAnAccount(LoginBloc loginBloc) {
    return TextButton(
      onPressed: () async {
        context.hideCurrentSnackBar();
        final email = await Navigator.pushNamed(
          context,
          RegisterPage.routeName,
        );
        print('[DEBUG] email = $email');
        if (email != null && email is String) {
          emailController.text = email;
          loginBloc.emailChanged(email);
          FocusScope.of(context).requestFocus(passwordFocusNode);
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
  }

  Widget forgotPassword(LoginBloc loginBloc) {
    return TextButton(
      onPressed: () async {
        context.hideCurrentSnackBar();
        final email = await Navigator.pushNamed(
          context,
          ResetPasswordPage.routeName,
        );
        print('[DEBUG] email = $email');
        if (email != null && email is String) {
          emailController.text = email;
          loginBloc.emailChanged(email);
          FocusScope.of(context).requestFocus(passwordFocusNode);
        }
      },
      child: Text(
        'Forgot password?',
        style: TextStyle(
          color: Colors.white70,
          fontStyle: FontStyle.italic,
          fontSize: 14.0,
        ),
      ),
    );
  }
}
