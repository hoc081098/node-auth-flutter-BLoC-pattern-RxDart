import 'dart:async';

import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/data/user_repository.dart';
import 'package:node_auth/pages/login/reset_password/input_token_and_reset_password_bloc.dart';
import 'package:node_auth/pages/login/reset_password/input_token_and_reset_password_page.dart';
import 'package:node_auth/pages/login/reset_password/send_email.dart';
import 'package:rxdart/rxdart.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with SingleTickerProviderStateMixin<ResetPasswordPage> {
  ///
  /// Observable of bool value, true if current page is request email page
  /// and reset password page otherwise
  ///
  final _requestEmailController = PublishSubject<void>();
  DistinctValueConnectableStream<bool> _requestEmail$;
  List<StreamSubscription> _subscriptions;

  AnimationController _animationController;
  Animation<Offset> _animationPosition;
  Animation<double> _animationScale;
  Animation<double> _animationOpacity;
  Animation<double> _animationTurns;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationPosition = Tween(
      begin: Offset(2.0, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationScale = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _animationOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _animationTurns = Tween<double>(
      begin: 0.5,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _requestEmail$ = _requestEmailController
        .scan((acc, e, _) => !acc, true)
        .publishValueSeededDistinct(seedValue: true);
    _subscriptions = [
      _requestEmail$.listen((requestEmailPage) {
        if (requestEmailPage) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      }),
      _requestEmail$.connect(),
    ];
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context);

    final sendEmailPage = SendEmailPage(
      initBloc: () => SendEmailBloc(userRepository),
      toggle: () => _requestEmailController.add(null),
    );

    final resetPasswordPage = InputTokenAndResetPasswordPage(
      toggle: () => _requestEmailController.add(null),
      initBloc: () => InputTokenAndResetPasswordBloc(userRepository),
    );

    return Stack(
      children: <Widget>[
        Positioned.fill(child: sendEmailPage),
        Positioned.fill(
          child: RotationTransition(
            child: SlideTransition(
              position: _animationPosition,
              child: ScaleTransition(
                scale: _animationScale,
                child: FadeTransition(
                  opacity: _animationOpacity,
                  child: resetPasswordPage,
                ),
              ),
            ),
            turns: _animationTurns,
          ),
        )
      ],
    );
  }
}
