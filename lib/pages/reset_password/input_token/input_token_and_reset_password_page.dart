import 'package:disposebag/disposebag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:node_auth/pages/reset_password/input_token/input_token_and_reset_password.dart';
import 'package:node_auth/utils/delay.dart';
import 'package:node_auth/utils/snackbar.dart';
import 'package:node_auth/widgets/password_textfield.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class InputTokenAndResetPasswordPage extends StatefulWidget {
  final VoidCallback toggle;

  const InputTokenAndResetPasswordPage({Key? key, required this.toggle})
      : super(key: key);

  @override
  _InputTokenAndResetPasswordPageState createState() =>
      _InputTokenAndResetPasswordPageState();
}

class _InputTokenAndResetPasswordPageState
    extends State<InputTokenAndResetPasswordPage>
    with
        SingleTickerProviderStateMixin<InputTokenAndResetPasswordPage>,
        DisposeBagMixin {
  final tokenFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  late final AnimationController fadeController;
  late final Animation<double> fadeAnim;
  Object? listen;

  @override
  void initState() {
    super.initState();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: fadeController,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    listen ??= [
      context
          .bloc<InputTokenAndResetPasswordBloc>()
          .message$
          .flatMap((message) async* {
        context.showSnackBar(_getMessageString(message));
        await delay(1000);
        yield null;

        if (message is ResetPasswordSuccess) {
          Navigator.pop<String>(context, message.email);
        }
      }).collect(),
      context
          .bloc<InputTokenAndResetPasswordBloc>()
          .isLoading$
          .listen((isLoading) {
        if (isLoading) {
          fadeController.forward();
        } else {
          fadeController.reverse();
        }
      }),
    ].disposedBy(bag);
  }

  @override
  void dispose() {
    fadeController.dispose();
    tokenFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetPasswordBloc =
        BlocProvider.of<InputTokenAndResetPasswordBloc>(context);

    final emailTextField = StreamBuilder<String?>(
      stream: resetPasswordBloc.emailError$,
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
          onChanged: resetPasswordBloc.emailChanged,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(tokenFocusNode);
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    final tokenTextField = StreamBuilder<String?>(
      stream: resetPasswordBloc.tokenError$,
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
          focusNode: tokenFocusNode,
          onChanged: resetPasswordBloc.tokenChanged,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(passwordFocusNode);
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    final passwordTextField = StreamBuilder<String?>(
      stream: resetPasswordBloc.passwordError$,
      builder: (context, snapshot) {
        return PasswordTextField(
          errorText: snapshot.data,
          onChanged: resetPasswordBloc.passwordChanged,
          labelText: 'Password',
          onSubmitted: () {
            FocusScope.of(context).unfocus();
          },
          textInputAction: TextInputAction.done,
          focusNode: passwordFocusNode,
        );
      },
    );

    final overlayColor = MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.hovered)) {
        return Theme.of(context).accentColor.withOpacity(0.5);
      }
      if (states.contains(MaterialState.focused) ||
          states.contains(MaterialState.pressed)) {
        return Theme.of(context).accentColor.withOpacity(0.8);
      }
      return null;
    });

    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      primary: Theme.of(context).cardColor,
    ).copyWith(overlayColor: overlayColor);

    return Container(
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
              SizedBox(height: 24),
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
                  opacity: fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  child: Text('Submit'),
                  style: buttonStyle,
                  onPressed: resetPasswordBloc.submit,
                ),
              ),
              SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  child: Text('Request email'),
                  style: buttonStyle,
                  onPressed: widget.toggle,
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
}
