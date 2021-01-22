import 'package:disposebag/disposebag.dart' show DisposeBag, defaultLogger;
import 'package:flutter/foundation.dart'
    show debugPrint, debugPrintSynchronously, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/app.dart';
import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/local/shared_pref_util.dart';
import 'package:node_auth/data/remote/api_service.dart';
import 'package:node_auth/data/remote/remote_data_source.dart';
import 'package:node_auth/data/user_repository_imp.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart'
    show DefaultLogger, RxSharedPreferences, RxSharedPreferencesConfigs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLoggers();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // construct RemoteDataSource
  const RemoteDataSource remoteDataSource = ApiService();

  // construct LocalDataSource
  final rxPrefs = RxSharedPreferences.getInstance();
  final LocalDataSource localDataSource = SharedPrefUtil(rxPrefs);

  // construct UserRepository
  final UserRepository userRepository = UserRepositoryImpl(
    remoteDataSource,
    localDataSource,
  );

  runApp(
    Provider<UserRepository>.value(
      userRepository,
      child: const MyApp(),
    ),
  );
}

void _setupLoggers() {
  // set loggers to `null` to disable logging.
  DisposeBag.logger = kReleaseMode ? null : defaultLogger;
  RxSharedPreferencesConfigs.logger =
      kReleaseMode ? null : const DefaultLogger();
  debugPrint = kReleaseMode ? null : debugPrintSynchronously;
}
