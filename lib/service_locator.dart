import 'package:get_it/get_it.dart';
import 'package:my_project/data/repository/transaction.dart';
import 'package:my_project/data/repository/wallet_category.dart';
import 'package:my_project/data/source/transaction_api_service.dart';
import 'package:my_project/data/source/wallet_category_api_service.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/domain/usecases/transaction_list.dart';
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
import 'domain/usecases/register_device_token.dart';


final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());

  // Services
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl());
  sl.registerSingleton<AuthLocalService>(AuthLocalServiceImpl());
  sl.registerSingleton<TransactionApiService>(TransactionApiServiceIml());
sl.registerSingleton<WalletCategoryApiService>(WalletCategoryApiServiceImpl());

  // Repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<TransactionRepository>(TransactionRepositoryImpl());
  sl.registerSingleton<WalletCategoryRepository>(WalletCategoryRepositoryImpl());
  // Usecases
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<IsLoggedInUseCase>(IsLoggedInUseCase());
  sl.registerSingleton<GetUserUseCase>(GetUserUseCase());
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase());
  sl.registerSingleton<SigninUseCase>(SigninUseCase());
  sl.registerSingleton<TransactionListUseCase>(TransactionListUseCase());
  sl.registerLazySingleton(() => RegisterDeviceTokenUseCase());
}
