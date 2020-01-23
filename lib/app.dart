import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
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
    final routes = <String, WidgetBuilder>{
      '/': (context) => const Home(),
      RegisterPage.routeName: (context) {
        final userRepository = Provider.of<UserRepository>(context);

        return BlocProvider<RegisterBloc>(
          child: const RegisterPage(),
          initBloc: () => RegisterBloc(userRepository),
        );
      },
      HomePage.routeName: (context) {
        final userRepository = Provider.of<UserRepository>(context);
        return BlocProvider<HomeBloc>(
          child: const HomePage(),
          initBloc: () => HomeBloc(userRepository),
        );
      },
      LoginPage.routeName: (context) {
        final userRepository = Provider.of<UserRepository>(context);
        return BlocProvider<LoginBloc>(
          initBloc: () => LoginBloc(userRepository),
          child: const LoginPage(),
        );
      },
      ResetPasswordPage.routeName: (context) {
        return const ResetPasswordPage();
      },
    };

    return Provider<Map<String, WidgetBuilder>>(
      value: routes,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          accentColor: const Color(0xFF00e676),
        ),
        initialRoute: '/',
        routes: routes,
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context);
    final routes = Provider.of<Map<String, WidgetBuilder>>(context);
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
          return routes[LoginPage.routeName](context);
        }

        if (snapshot.data is AuthenticatedState) {
          print('[HOME] home [3] >> [Authenticated]');
          return routes[HomePage.routeName](context);
        }

        return Container(width: 0, height: 0);
      },
    );
  }
}
