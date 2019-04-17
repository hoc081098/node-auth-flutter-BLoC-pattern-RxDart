import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/authentication_bloc/authentication.dart';
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
    final future =
        AuthenticationBlocProvider.of(context).authenticationState$.first;

    return FutureBuilder<AuthenticationState>(
      future: future,
      builder: (context, snapshot) {
        print('[DEBUG] home snapshot=$snapshot');

        if (!snapshot.hasData) {
          print('[DEBUG] home snapshot=$snapshot [1][waiting]');
          return Container(
            width: double.infinity,
            height: double.infinity,
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
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data is NotAuthenticatedState) {
          print('[DEBUG] home snapshot=$snapshot [2][NotAuthenticatedState]');
          return LoginPage(initBloc: () => LoginBloc(userRepository));
        }
        if (snapshot.data is AuthenticatedState) {
          print('[DEBUG] home snapshot=$snapshot [3][AuthenticatedState]');
          return HomePage(initBloc: () => HomeBloc(userRepository));
        }
      },
    );
  }
}
