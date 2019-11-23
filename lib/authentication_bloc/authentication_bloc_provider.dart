import 'package:flutter/material.dart';
import 'package:node_auth/authentication_bloc/authentication_bloc.dart';

class AuthenticationBlocProvider extends StatefulWidget {
  final Widget child;
  final AuthenticationBloc authenticationBloc;

  const AuthenticationBlocProvider({
    Key key,
    @required this.authenticationBloc,
    this.child,
  }) : super(key: key);

  _AuthenticationBlocProviderState createState() =>
      _AuthenticationBlocProviderState();

  static AuthenticationBloc of(BuildContext context) {
    return _AuthenticationBlocInherited.of(context).authenticationBloc;
  }
}

class _AuthenticationBlocProviderState
    extends State<AuthenticationBlocProvider> {
  @override
  Widget build(BuildContext context) {
    return _AuthenticationBlocInherited(
      child: widget.child,
      authenticationBloc: widget.authenticationBloc,
    );
  }

  @override
  void dispose() {
    widget.authenticationBloc.dispose();
    super.dispose();
  }
}

class _AuthenticationBlocInherited extends InheritedWidget {
  final AuthenticationBloc authenticationBloc;

  _AuthenticationBlocInherited({
    @required this.authenticationBloc,
    @required Widget child,
    Key key,
  }) : super(key: key, child: child);

  static _AuthenticationBlocInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AuthenticationBlocInherited>();
  }

  @override
  bool updateShouldNotify(_AuthenticationBlocInherited oldWidget) {
    return authenticationBloc != oldWidget.authenticationBloc;
  }
}
