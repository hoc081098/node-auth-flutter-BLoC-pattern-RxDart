import 'package:flutter/material.dart';
import 'package:node_auth/app.dart';
import 'package:node_auth/authentication_bloc/authentication.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/dependency_injection.dart';

void main() {
  //TODO: reset password
  //TODO: register page

  const RemoteDataSource remoteDataSource = ApiService();
  const LocalDataSource localDataSource = SharedPrefUtil();
  final UserRepository userRepository = UserRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  runApp(
    DependencyInjector(
      userRepository,
      child: AuthenticationBlocProvider(
        authenticationBloc: AuthenticationBloc(
          userRepository,
        ),
        child: const MyApp(),
      ),
    ),
  );
}
