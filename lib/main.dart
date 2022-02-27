import 'package:disposebag/disposebag.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, debugPrintSynchronously, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:node_auth/app.dart';
import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/local/method_channel_crypto_impl.dart';
import 'package:node_auth/data/local/shared_pref_util.dart';
import 'package:node_auth/data/remote/api_service.dart';
import 'package:node_auth/data/remote/remote_data_source.dart';
import 'package:node_auth/data/user_repository_imp.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RxStreamBuilder.checkStateStreamEnabled = !kReleaseMode;
  _setupLoggers();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // construct RemoteDataSource
  const RemoteDataSource remoteDataSource = ApiService();

  // construct LocalDataSource
  final rxPrefs = RxSharedPreferences.getInstance();
  final crypto = MethodChannelCryptoImpl();
  final LocalDataSource localDataSource = SharedPrefUtil(rxPrefs, crypto);

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
  DisposeBagConfigs.logger = kReleaseMode ? null : disposeBagDefaultLogger;

  RxSharedPreferencesConfigs.logger =
      kReleaseMode ? null : const RxSharedPreferencesDefaultLogger();

  debugPrint = kReleaseMode
      ? (String? message, {int? wrapWidth}) {}
      : debugPrintSynchronously;
}
