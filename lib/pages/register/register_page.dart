// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:did_change_dependencies/did_change_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:node_auth/pages/register/register.dart';
import 'package:node_auth/utils/snackbar.dart';
import 'package:node_auth/widgets/password_textfield.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = '/register_page';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with
        SingleTickerProviderStateMixin,
        DisposeBagMixin,
        DidChangeDependenciesStream {
  late AnimationController registerButtonController;
  late Animation<double> buttonSqueezeAnimation;

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    registerButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    buttonSqueezeAnimation = Tween(
      begin: 320.0,
      end: 70.0,
    ).animate(
      CurvedAnimation(
        parent: registerButtonController,
        curve: const Interval(0.0, 0.250),
      ),
    );

    didChangeDependencies$
        .exhaustMap((_) => context.bloc<RegisterBloc>().message$)
        .exhaustMap(handleMessage)
        .collect()
        .disposedBy(bag);

    didChangeDependencies$
        .exhaustMap((_) => context.bloc<RegisterBloc>().isLoading$)
        .listen((isLoading) {
      if (isLoading) {
        registerButtonController
          ..reset()
          ..forward();
      } else {
        registerButtonController.reverse();
      }
    }).disposedBy(bag);
  }

  @override
  void dispose() {
    registerButtonController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerBloc = BlocProvider.of<RegisterBloc>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/bg.jpg'),
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
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BackButton(color: Colors.white),
                ],
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
                        child: nameTextField(registerBloc),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: emailTextField(registerBloc),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: passwordTextField(registerBloc),
                      ),
                      const SizedBox(height: 32.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: registerButton(registerBloc),
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

  Stream<void> handleMessage(RegisterMessage message) async* {
    switch (message) {
      case RegisterSuccessMessage():
        context.showSnackBar('Register successfully');
        await delay(1000);
        yield null;
        Navigator.pop<String>(context, message.email);

      case RegisterErrorMessage():
        context.showSnackBar(message.message);

      case RegisterInvalidInformationMessage():
        context.showSnackBar('Invalid information');
    }
  }

  Widget emailTextField(RegisterBloc registerBloc) {
    return StreamBuilder<String?>(
      stream: registerBloc.emailError$,
      builder: (context, snapshot) {
        return TextField(
          onChanged: registerBloc.emailChanged,
          autocorrect: true,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.email),
            ),
            labelText: 'Email',
            errorText: snapshot.data,
          ),
          keyboardType: TextInputType.emailAddress,
          maxLines: 1,
          style: const TextStyle(fontSize: 16.0),
          focusNode: emailFocusNode,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(passwordFocusNode);
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }

  Widget passwordTextField(RegisterBloc registerBloc) {
    return StreamBuilder<String?>(
      stream: registerBloc.passwordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          labelText: 'Password',
          onChanged: registerBloc.passwordChanged,
          focusNode: passwordFocusNode,
          onSubmitted: () {
            FocusScope.of(context).unfocus();
          },
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  Widget registerButton(RegisterBloc registerBloc) {
    return AnimatedBuilder(
      animation: buttonSqueezeAnimation,
      builder: (context, child) {
        final value = buttonSqueezeAnimation.value;

        return SizedBox(
          width: value,
          height: 60.0,
          child: Material(
            elevation: 5.0,
            clipBehavior: Clip.antiAlias,
            shadowColor: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(24.0),
            child: value > 75.0
                ? child
                : const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
          ),
        );
      },
      child: MaterialButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          registerBloc.submitRegister();
        },
        color: Theme.of(context).colorScheme.surface,
        splashColor: Theme.of(context).colorScheme.secondary,
        child: const Text(
          'REGISTER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget nameTextField(RegisterBloc registerBloc) {
    return StreamBuilder<String?>(
      stream: registerBloc.nameError$,
      builder: (context, snapshot) {
        return TextField(
          autocorrect: true,
          onChanged: registerBloc.nameChanged,
          decoration: InputDecoration(
            labelText: 'Name',
            errorText: snapshot.data,
            prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.person),
            ),
          ),
          keyboardType: TextInputType.text,
          maxLines: 1,
          style: const TextStyle(fontSize: 16.0),
          autofocus: true,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(emailFocusNode);
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}
