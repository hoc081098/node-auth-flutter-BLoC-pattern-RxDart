import 'package:flutter/material.dart';
import 'package:node_auth/authentication_bloc/authentication.dart';
import 'package:node_auth/dependency_injection.dart';
import 'package:node_auth/pages/home/home.dart';
import 'package:node_auth/pages/login/login.dart';
import 'package:node_auth/pages/register/register.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Home(),
      routes: <String, WidgetBuilder>{
        '/register_page': (context) => RegisterPage(),
        '/home_page': (context) => HomePage(),
        '/login_page': (context) => LoginPage(
              initBloc: () {
                return LoginBloc(DependencyInjector.of(context).userRepository);
              },
            ),
      },
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc =
        AuthenticationBlocProvider.of(context);
    final future = authenticationBloc.authenticationState$.first;

    return FutureBuilder<AuthenticationState>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data is NotAuthenticatedState) {
          return LoginPage(
            initBloc: () {
              return LoginBloc(
                DependencyInjector.of(context).userRepository,
              );
            },
          );
        }
        if (snapshot.data is AuthenticatedState) {
          return HomePage();
        }
      },
    );
  }
}
