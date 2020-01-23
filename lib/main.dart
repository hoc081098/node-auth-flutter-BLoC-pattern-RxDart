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
import 'package:node_auth/domain/usecases/change_password_use_case.dart';
import 'package:node_auth/domain/usecases/get_auth_state_use_case.dart';
import 'package:node_auth/domain/usecases/login_use_case.dart';
import 'package:node_auth/domain/usecases/logout_use_case.dart';
import 'package:node_auth/domain/usecases/register_use_case.dart';
import 'package:node_auth/domain/usecases/reset_password_use_case.dart';
import 'package:node_auth/domain/usecases/send_reset_password_email_use_case.dart';
import 'package:node_auth/domain/usecases/upload_image_use_case.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final rxPrefs = RxSharedPreferences(
    SharedPreferences.getInstance(),
    DefaultLogger(),
  );

  const RemoteDataSource remoteDataSource = ApiService();
  final LocalDataSource localDataSource = SharedPrefUtil(rxPrefs);
  final UserRepository userRepository = UserRepositoryImpl(
    remoteDataSource,
    localDataSource,
  );

  runApp(
    Providers(
      providers: [
        Provider<LoginUseCase>(value: LoginUseCase(userRepository)),
        Provider<RegisterUseCase>(value: RegisterUseCase(userRepository)),
        Provider<LogoutUseCase>(value: LogoutUseCase(userRepository)),
        Provider<GetAuthStateUseCase>(
          value: GetAuthStateUseCase(userRepository),
        ),
        Provider<UploadImageUseCase>(
          value: UploadImageUseCase(userRepository),
        ),
        Provider<ChangePasswordUseCase>(
          value: ChangePasswordUseCase(userRepository),
        ),
        Provider<SendResetPasswordEmailUseCase>(
          value: SendResetPasswordEmailUseCase(userRepository),
        ),
        Provider<ResetPasswordUseCase>(
          value: ResetPasswordUseCase(userRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
