import 'package:disposebag/disposebag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:node_auth/pages/reset_password/send_email/send_email.dart';
import 'package:node_auth/utils/snackbar.dart';

class SendEmailPage extends StatefulWidget {
  final VoidCallback toggle;

  const SendEmailPage({Key key, @required this.toggle}) : super(key: key);

  @override
  _SendEmailPageState createState() => _SendEmailPageState();
}

class _SendEmailPageState extends State<SendEmailPage>
    with SingleTickerProviderStateMixin, DisposeBagMixin {
  AnimationController fadeController;
  Animation<double> fadeAnim;
  Object listen;

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
          .bloc<SendEmailBloc>()
          .message$
          .map(_getMessageString)
          .listen(context.showSnackBar),
      context.bloc<SendEmailBloc>().isLoading$.listen((isLoading) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<SendEmailBloc>(context);

    final emailTextField = StreamBuilder<String>(
      stream: bloc.emailError$,
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
          onChanged: bloc.emailChanged,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
          style: TextStyle(fontSize: 16.0),
        );
      },
    );

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: emailTextField,
              ),
              Center(
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
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
                  onPressed: bloc.submit,
                ),
              ),
              SizedBox(height: 8),
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
    );
  }

  static String _getMessageString(SendEmailMessage msg) {
    if (msg is SendEmailInvalidInformationMessage) {
      return 'Invalid information. Try again';
    }
    if (msg is SendEmailSuccessMessage) {
      return 'Email sent. Check your email inbox and go to reset password page';
    }
    if (msg is SendEmailErrorMessage) {
      return msg.message;
    }
    return 'An unexpected error has occurred';
  }
}
