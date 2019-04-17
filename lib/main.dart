import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:node_auth/app.dart';
import 'package:node_auth/authentication_bloc/authentication.dart';
import 'package:node_auth/data/data.dart';
import 'package:flutter_provider/flutter_provider.dart';

void main() async {
  //TODO: reset password

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  const RemoteDataSource remoteDataSource = ApiService();
  const LocalDataSource localDataSource = SharedPrefUtil();
  final UserRepository userRepository = UserRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  runApp(
    Provider<UserRepository>(
      value: userRepository,
      child: AuthenticationBlocProvider(
        authenticationBloc: AuthenticationBloc(
          userRepository,
        ),
        child: const MyApp(),
      ),
    ),
  );
}
