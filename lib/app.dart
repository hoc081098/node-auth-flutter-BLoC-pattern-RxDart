import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:node_auth/domain/usecases/get_auth_state_stream_use_case.dart';
import 'package:node_auth/domain/usecases/get_auth_state_use_case.dart';
import 'package:node_auth/domain/usecases/login_use_case.dart';
import 'package:node_auth/domain/usecases/logout_use_case.dart';
import 'package:node_auth/domain/usecases/register_use_case.dart';
import 'package:node_auth/domain/usecases/upload_image_use_case.dart';
import 'package:node_auth/pages/home/home.dart';
import 'package:node_auth/pages/login/login.dart';
import 'package:node_auth/pages/register/register.dart';
import 'package:node_auth/pages/reset_password/reset_password_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routes = <String, WidgetBuilder>{
      Navigator.defaultRouteName: (context) {
        return Provider<GetAuthStateUseCase>.factory(
          (context) => GetAuthStateUseCase(context.get()),
          child: const Home(),
        );
      },
      RegisterPage.routeName: (context) {
        return BlocProvider<RegisterBloc>(
          initBloc: (context) => RegisterBloc(
            RegisterUseCase(context.get()),
          ),
          child: const RegisterPage(),
        );
      },
      HomePage.routeName: (context) {
        return BlocProvider<HomeBloc>(
          initBloc: (context) {
            final userRepository = context.get<UserRepository>();
            return HomeBloc(
              LogoutUseCase(userRepository),
              GetAuthStateStreamUseCase(userRepository),
              UploadImageUseCase(userRepository),
            );
          },
          child: const HomePage(),
        );
      },
      LoginPage.routeName: (context) {
        return BlocProvider<LoginBloc>(
          initBloc: (context) => LoginBloc(
            LoginUseCase(context.get()),
          ),
          child: const LoginPage(),
        );
      },
      ResetPasswordPage.routeName: (context) {
        return const ResetPasswordPage();
      },
    };

    final themeData = ThemeData(brightness: Brightness.dark);
    return Provider<Map<String, WidgetBuilder>>.value(
      routes,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: themeData.copyWith(
          colorScheme: themeData.colorScheme.copyWith(
            secondary: const Color(0xFF00e676),
          ),
        ),
        routes: routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final getAuthState = Provider.of<GetAuthStateUseCase>(context);
    final routes = Provider.of<Map<String, WidgetBuilder>>(context);

    return FutureBuilder<AuthenticationState>(
      future: getAuthState(),
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
          return routes[LoginPage.routeName]!(context);
        }

        if (snapshot.data is AuthenticatedState) {
          print('[HOME] home [3] >> [Authenticated]');
          return routes[HomePage.routeName]!(context);
        }

        return Container(width: 0, height: 0);
      },
    );
  }
}
