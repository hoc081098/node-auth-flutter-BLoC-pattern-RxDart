import 'package:flutter/material.dart';
import 'package:node_auth/app.dart';
import 'package:node_auth/authentication_bloc/authentication.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/dependency_injection.dart';

void main() {
  const apiService = ApiService();
  const localDataSource = SharedPrefUtil();
  final userRepository = UserRepositoryImpl(
    apiService: apiService,
    localDataSource: localDataSource,
  );
  runApp(
    DependencyInjector(
      userRepository,
      child: AuthenticationBlocProvider(
        authenticationBloc: AuthenticationBloc(
          userRepository,
        ),
        child: MyApp(),
      ),
    ),
  );
}
