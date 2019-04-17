import 'dart:async';

import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/data/user_repository.dart';
import 'package:node_auth/pages/login/reset_password/input_token_and_reset_password_page.dart';
import 'package:node_auth/pages/login/reset_password/send_email.dart';
import 'package:rxdart/rxdart.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  ///
  /// Observable of bool value, true if current page is request email page
  /// and reset password page otherwise
  ///
  final _requestEmailController = PublishSubject<void>();
  DistinctValueConnectableObservable<bool> _requestEmail$;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _requestEmail$ = publishValueSeededDistinct(
      _requestEmailController.scan((acc, e, _) => !acc, true),
      seedValue: true,
    );
    _subscription = _requestEmail$.connect();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _requestEmail$,
      initialData: _requestEmail$.value,
      builder: (context, snapshot) {
        if (snapshot.data) {
          return SendEmailPage(
            initBloc: () {
              final userRepository = Provider.of<UserRepository>(context);
              return SendEmailBloc(userRepository);
            },
            toggle: () => _requestEmailController.add(null),
          );
        } else {
          return InputTokenAndResetPasswordPage(
            toggle: () => _requestEmailController.add(null),
          );
        }
      },
    );
  }
}

class StreamSubcription {}
