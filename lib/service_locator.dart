import 'package:get_it/get_it.dart';
import 'core/network/dio_client.dart';
import 'data/repository/auth.dart';
import 'data/source/auth_api_service.dart';
import 'data/source/auth_local_service.dart';
import 'domain/repository/auth.dart';
import 'domain/usecases/get_user.dart';
import 'domain/usecases/is_logged_in.dart';
import 'domain/usecases/logout.dart';
import 'domain/usecases/signin.dart';
import 'domain/usecases/signup.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());

  // Services
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl());

  sl.registerSingleton<AuthLocalService>(AuthLocalServiceImpl());

  // Repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Usecases
  sl.registerSingleton<SignupUseCase>(SignupUseCase());

  sl.registerSingleton<IsLoggedInUseCase>(IsLoggedInUseCase());

  sl.registerSingleton<GetUserUseCase>(GetUserUseCase());

  sl.registerSingleton<LogoutUseCase>(LogoutUseCase());

  sl.registerSingleton<SigninUseCase>(SigninUseCase());
}
