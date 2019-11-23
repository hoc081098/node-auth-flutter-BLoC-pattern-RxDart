import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/pages/home/home.dart';
import 'package:node_auth/pages/login/login.dart';
import 'package:node_auth/pages/login/reset_password/reset_password_page.dart';
import 'package:node_auth/pages/register/register.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: const Color(0xFF00e676),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => const Home(),
        '/register_page': (context) {
          return RegisterPage(
            initBloc: () {
              return RegisterBloc(
                Provider.of<UserRepository>(context),
              );
            },
          );
        },
        '/home_page': (context) {
          return HomePage(
            initBloc: () {
              return HomeBloc(Provider.of<UserRepository>(context));
            },
          );
        },
        '/login_page': (context) {
          return LoginPage(
            initBloc: () {
              return LoginBloc(Provider.of<UserRepository>(context));
            },
          );
        },
        '/reset_password_page': (context) {
          return ResetPasswordPage();
        },
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context);
    final future = userRepository.authenticationState$.first;

    return FutureBuilder<AuthenticationState>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          print('[HOME] home [1] >> [waiting...]');

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).cardColor,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data is UnauthenticatedState) {
          print('[HOME] home [2] >> [NotAuthenticated]');
          return LoginPage(initBloc: () => LoginBloc(userRepository));
        }
        if (snapshot.data is AuthenticatedState) {
          print('[HOME] home [3] >> [Authenticated]');
          return HomePage(initBloc: () => HomeBloc(userRepository));
        }
        return Container(width: 0, height: 0);
      },
    );
  }
}
