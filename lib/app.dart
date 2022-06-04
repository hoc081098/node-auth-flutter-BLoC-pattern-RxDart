import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_disposebag/flutter_disposebag.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/domain/models/app_error.dart';
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
import 'package:node_auth/utils/streams.dart';

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

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with DisposeBagMixin {
  late final StateStream<Result<AuthenticationState>?> authState$;

  @override
  void initState() {
    super.initState();

    final getAuthState = Provider.of<GetAuthStateUseCase>(context);
    authState$ = getAuthState().castAsNullable().publishState(null)
      ..connect().disposedBy(bag);
  }

  @override
  Widget build(BuildContext context) {
    final routes = Provider.of<Map<String, WidgetBuilder>>(context);

    return RxStreamBuilder<Result<AuthenticationState>?>(
      stream: authState$,
      builder: (context, result) {
        if (result == null) {
          debugPrint('[HOME] home [1] >> [waiting...]');

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).cardColor,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          );
        }

        return result.fold(
          ifLeft: (appError) {
            debugPrint(
                '[HOME] home [2] >> [error -> NotAuthenticated] error=$appError');
            return routes[LoginPage.routeName]!(context);
          },
          ifRight: (authState) {
            if (authState is UnauthenticatedState) {
              debugPrint('[HOME] home [3] >> [Unauthenticated]');
              return routes[LoginPage.routeName]!(context);
            }

            if (authState is AuthenticatedState) {
              debugPrint('[HOME] home [4] >> [Authenticated]');
              return routes[HomePage.routeName]!(context);
            }

            throw StateError('Unknown auth state: $authState');
          },
        );
      },
    );
  }
}
