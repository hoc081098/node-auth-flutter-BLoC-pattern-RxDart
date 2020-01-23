import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/data/user_repository.dart';
import 'package:node_auth/pages/reset_password/input_token/input_token_and_reset_password.dart';
import 'package:node_auth/pages/reset_password/send_email/send_email.dart';
import 'package:rxdart/rxdart.dart';

class ResetPasswordPage extends StatefulWidget {
  static const routeName = '/reset_password_page';

  const ResetPasswordPage({Key key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with SingleTickerProviderStateMixin<ResetPasswordPage> {
  /// Observable of bool values,
  /// Emits true if current page is request email page
  /// and reset password page otherwise
  final requestEmailS = PublishSubject<void>();
  DistinctValueConnectableStream<bool> requestEmail$;
  DisposeBag disposeBag;

  AnimationController animationController;
  Animation<Offset> animationPosition;
  Animation<double> animationScale;
  Animation<double> animationOpacity;
  Animation<double> animationTurns;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    animationPosition = Tween(
      begin: Offset(2.0, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );
    animationScale = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animationOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animationTurns = Tween<double>(
      begin: 0.5,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    requestEmail$ = requestEmailS
        .scan((acc, e, _) => !acc, true)
        .publishValueSeededDistinct(seedValue: true);

    disposeBag = DisposeBag([
      requestEmail$.listen((requestEmailPage) {
        if (requestEmailPage) {
          animationController.reverse();
        } else {
          animationController.forward();
        }
      }),
      requestEmail$.connect(),
    ]);
  }

  @override
  void dispose() {
    disposeBag.dispose();
    animationController.dispose();
    super.dispose();
  }

  void onToggle() => requestEmailS.add(null);

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context);

    final sendEmailPage = BlocProvider<SendEmailBloc>(
      initBloc: () => SendEmailBloc(userRepository),
      child: SendEmailPage(toggle: onToggle),
    );

    final resetPasswordPage = BlocProvider<InputTokenAndResetPasswordBloc>(
      initBloc: () => InputTokenAndResetPasswordBloc(userRepository),
      child: InputTokenAndResetPasswordPage(toggle: onToggle),
    );

    return Stack(
      children: <Widget>[
        Positioned.fill(child: sendEmailPage),
        Positioned.fill(
          child: RotationTransition(
            child: SlideTransition(
              position: animationPosition,
              child: ScaleTransition(
                scale: animationScale,
                child: FadeTransition(
                  opacity: animationOpacity,
                  child: resetPasswordPage,
                ),
              ),
            ),
            turns: animationTurns,
          ),
        )
      ],
    );
  }
}
