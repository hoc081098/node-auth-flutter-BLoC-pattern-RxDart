import 'dart:async';

import 'package:flutter/material.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/utils/validators.dart';
import 'package:rxdart/rxdart.dart';

// ignore_for_file: close_sinks

abstract class SendEmailMessage {}

class SendEmailInvalidInformationMessage implements SendEmailMessage {
  const SendEmailInvalidInformationMessage();
}

class SendEmailSuccessMessage implements SendEmailMessage {
  const SendEmailSuccessMessage();
}

class SendEmailErrorMessage implements SendEmailMessage {
  final String message;
  final Object error;
  const SendEmailErrorMessage(this.message, [this.error]);
}

class SendEmailBloc {
  ///
  ///
  ///
  final void Function() submit;
  final void Function(String) emailChanged;

  ///
  ///
  ///
  final Stream<String> emailError$;
  final Stream<SendEmailMessage> message$;
  final ValueObservable<bool> isLoading$;

  ///
  ///
  ///
  final void Function() dispose;

  const SendEmailBloc._({
    @required this.submit,
    @required this.emailChanged,
    @required this.emailError$,
    @required this.message$,
    @required this.isLoading$,
    @required this.dispose,
  });

  factory SendEmailBloc(UserRepository userRepository) {
    assert(userRepository != null);

    final emailController = PublishSubject<String>();
    final submitController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>(seedValue: false);

    final emailError$ = emailController.map((email) {
      if (Validator.isValidEmail(email)) return null;
      return 'Invalid email address';
    }).share();

    final submit$ = submitController
        .withLatestFrom(emailController, (_, String email) => email)
        .share();

    final sendResult$ = submit$.where(Validator.isValidEmail).exhaustMap(
        (email) => send(email, userRepository, isLoadingController));
    final message$ = Observable.merge([
      submit$
          .where((email) => !Validator.isValidEmail(email))
          .map((_) => const SendEmailInvalidInformationMessage()),
      sendResult$,
    ]).share();

    return SendEmailBloc._(
      dispose: () async {
        await Future.wait(<StreamController>[
          emailController,
          submitController,
          isLoadingController,
        ].map((c) => c.close()));
      },
      emailChanged: emailController.add,
      emailError$: emailError$,
      submit: () => submitController.add(null),
      message$: message$,
      isLoading$: isLoadingController,
    );
  }

  static Stream<SendEmailMessage> send(
    String email,
    UserRepository userRepository,
    Sink<bool> isLoadingController,
  ) {
    SendEmailMessage _resultToMessage(result) {
      if (result is Success) {
        return const SendEmailSuccessMessage();
      }
      if (result is Failure) {
        return SendEmailErrorMessage(result.message, result.error);
      }
      return SendEmailErrorMessage('An error occurred!');
    }

    return userRepository
        .sendResetPasswordEmail(email)
        .doOnListen(() => isLoadingController.add(true))
        .doOnData((_) => isLoadingController.add(false))
        .map(_resultToMessage);
  }
}

class SendEmailPage extends StatefulWidget {
  final SendEmailBloc Function() initBloc;

  const SendEmailPage({Key key, @required this.initBloc}) : super(key: key);

  _SendEmailPageState createState() => _SendEmailPageState();
}

class _SendEmailPageState extends State<SendEmailPage> {
  SendEmailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.initBloc();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailTextField = StreamBuilder<String>(
      stream: _bloc.emailError$,
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
          onChanged: _bloc.emailChanged,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

    final messageText = StreamBuilder<SendEmailMessage>(
      stream: _bloc.message$,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(width: 0, height: 0);
        }
        print('[DEBUG] send_email_message snapshot=$snapshot');
        if (snapshot.data is SendEmailSuccessMessage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context, true);
          });
        }
        return _Message(message: _getMessageString(snapshot.data));
      },
    );

    final loadingIndicator = StreamBuilder<bool>(
      stream: _bloc.isLoading$,
      initialData: _bloc.isLoading$.value,
      builder: (context, snapshot) {
        if (snapshot.data) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }
        return Container(width: 0, height: 0);
      },
    );

    return AlertDialog(
      title: Text('Send reset password email'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            emailTextField,
            messageText,
            loadingIndicator,
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
            _bloc.submit();
          },
        ),
      ],
    );
  }

  String _getMessageString(SendEmailMessage msg) {
    if (msg is SendEmailInvalidInformationMessage) {
      return 'Invalid information';
    }
    if (msg is SendEmailSuccessMessage) {
      return 'Email sended. Check your email inbox';
    }
    if (msg is SendEmailErrorMessage) {
      return msg.message;
    }
    return null;
  }
}

class _Message extends StatefulWidget {
  final String message;

  const _Message({Key key, this.message}) : super(key: key);

  __MessageState createState() => __MessageState();
}

class __MessageState extends State<_Message>
    with SingleTickerProviderStateMixin<_Message> {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _controller.forward();
    print('[DEBUG] __MessageState::initState message=${widget.message}');
  }

  @override
  void didUpdateWidget(_Message oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('[DEBUG] __MessageState::didUpdateWidget message=${widget.message}');
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    print('[DEBUG] __MessageState::dispose message=${widget.message}');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: Tween<double>(
        begin: 1,
        end: 0,
      ).animate(
        CurvedAnimation(
          curve: Curves.fastOutSlowIn,
          parent: _controller,
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 1,
          end: 0,
        ).animate(
          CurvedAnimation(
            curve: Curves.easeInOut,
            parent: _controller,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
