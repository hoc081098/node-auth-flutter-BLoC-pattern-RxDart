import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/app.dart';
import 'package:node_auth/authentication_bloc/authentication.dart';
import 'package:node_auth/data/data.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final rxPrefs = RxSharedPreferences(SharedPreferences.getInstance());

  const RemoteDataSource remoteDataSource = ApiService();
  final LocalDataSource localDataSource = SharedPrefUtil(rxPrefs);
  final UserRepository userRepository = UserRepositoryImpl(
    remoteDataSource,
    localDataSource,
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
