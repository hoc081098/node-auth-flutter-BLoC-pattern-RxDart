import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:node_auth/pages/home/change_password/change_password.dart';
import 'package:node_auth/widgets/password_textfield.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({Key? key}) : super(key: key);

  @override
  _ChangePasswordBottomSheetState createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet>
    with
        SingleTickerProviderStateMixin<ChangePasswordBottomSheet>,
        DisposeBagMixin {
  late final AnimationController fadeMessageController;
  late final Animation<double> messageOpacity;
  Object? listen;

  final newPasswordFocusNode = FocusNode();

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    listen ??= BlocProvider.of<ChangePasswordBloc>(context)
        .changePasswordState$
        .flatMap((state) async* {
          if (state.message != null) {
            fadeMessageController.reset();
            await fadeMessageController.forward();
            yield null;

            if (state?.error == null) {
              Navigator.of(context).pop();
            }
          }
        })
        .collect()
        .disposedBy(bag);
  }

  @override
  void dispose() {
    fadeMessageController.dispose();
    newPasswordFocusNode.dispose();
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
            FocusScope.of(context).unfocus();
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
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
              elevation: 4,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
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

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
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
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      ),
    );
  }
}
