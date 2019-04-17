import 'dart:async';

import 'package:flutter/material.dart';
import 'package:node_auth/pages/login/reset_password/send_email.dart';

class SendEmailPage extends StatefulWidget {
  final SendEmailBloc Function() initBloc;
  final VoidCallback toggle;

  const SendEmailPage({
    Key key,
    @required this.initBloc,
    @required this.toggle,
  }) : super(key: key);

  _SendEmailPageState createState() => _SendEmailPageState();
}

class _SendEmailPageState extends State<SendEmailPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  SendEmailBloc _bloc;
  List<StreamSubscription> _subscriptions;

  AnimationController _fadeController;
  Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _bloc = widget.initBloc();
    _subscriptions = <StreamSubscription>[
      _bloc.message$.map(_getMessageString).listen(_showSnackBar),
      _bloc.isLoading$.listen((isLoading) {
        if (isLoading) {
          _fadeController.forward();
        } else {
          _fadeController.reverse();
        }
      }),
    ];

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: _fadeController,
      ),
    );
  }

  _showSnackBar(String message) => _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Request email'),
      ),
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: emailTextField,
                ),
                SizedBox(height: 12),
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: RaisedButton(
                    child: Text('Send'),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Theme.of(context).cardColor,
                    splashColor: Theme.of(context).accentColor,
                    onPressed: _bloc.submit,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: RaisedButton(
                    child: Text('Input received token'),
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).cardColor,
                    splashColor: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onPressed: widget.toggle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _getMessageString(SendEmailMessage msg) {
    if (msg is SendEmailInvalidInformationMessage) {
      return 'Invalid information. Try again';
    }
    if (msg is SendEmailSuccessMessage) {
      return 'Email sended. Check your email inbox and go to reset password page';
    }
    if (msg is SendEmailErrorMessage) {
      return msg.message;
    }
    return 'An unexpected error has occurred';
  }
}
