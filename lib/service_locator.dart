import 'package:get_it/get_it.dart';
import 'package:my_project/data/models/wallet_type.dart';
import 'package:my_project/data/repository/activity.dart';
import 'package:my_project/data/repository/goal_item.dart';
import 'package:my_project/data/repository/monthly_goal.dart';
import 'package:my_project/data/repository/chat.dart';
import 'package:my_project/data/repository/message.dart';
import 'package:my_project/data/repository/sheet_repository.dart';
import 'package:my_project/data/repository/transaction.dart';
import 'package:my_project/data/repository/wallet.dart';
import 'package:my_project/data/repository/wallet_category.dart';
import 'package:my_project/data/repository/wallet_type.dart';
import 'package:my_project/data/source/activity_api_service.dart';
import 'package:my_project/data/source/goal_item_api_service.dart';
import 'package:my_project/data/source/monthly_goal_api_service.dart';
import 'package:my_project/data/source/chat_api_service.dart';
import 'package:my_project/data/source/message_api_service.dart';
import 'package:my_project/data/source/sheet_api_service.dart';
import 'package:my_project/data/source/transaction_api_service.dart';
import 'package:my_project/data/source/wallet_api_service.dart';
import 'package:my_project/data/source/wallet_category_api_service.dart';
import 'package:my_project/data/source/wallet_type_api_service.dart';
import 'package:my_project/domain/repository/activitiy.dart';
import 'package:my_project/domain/repository/goal_item.dart';
import 'package:my_project/domain/repository/monthly_goal.dart';
import 'package:my_project/domain/repository/chat.dart';
import 'package:my_project/domain/repository/message.dart';
import 'package:my_project/domain/repository/sheet.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/domain/repository/wallet.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/domain/repository/wallet_type.dart';
import 'package:my_project/domain/usecases/get_total_balance.dart';
import 'package:my_project/domain/usecases/google_signin.dart';
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
  sl.registerSingleton<GoalItemApiService>(GoalItemApiServiceImpl());
  sl.registerSingleton<WalletApiService>(WalletApiServiceImpl());
  sl.registerSingleton<TransactionApiService>(TransactionApiServiceIml());
  sl.registerSingleton<MonthlyGoalApiService>(MonthlyGoalApiServiceImpl());
  sl.registerSingleton<ActivityApiService>(ActivityApiServiceImpl());
  sl.registerSingleton<WalletCategoryApiService>(
      WalletCategoryApiServiceImpl());
  sl.registerSingleton<ChatApiService>(ChatApiServiceIml());
  sl.registerSingleton<MessageApiService>(MessageApiServiceIml());
  sl.registerSingleton<SheetApiService>(SheetApiServiceImpl());
  sl.registerSingleton<WalletTypeApiService>(WalletTypeApiServiceImpl());

  // Repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<TransactionRepository>(TransactionRepositoryImpl());
  sl.registerSingleton<GoalItemRepository>(GoalItemRepositoryImpl());
  sl.registerSingleton<MonthlyGoalRepository>(MonthlyGoalRepositoryImpl());
  sl.registerSingleton<ActivityRepository>(ActivityRepositoryImpl());
  sl.registerSingleton<WalletRepository>(WalletRepositoryImpl());
  sl.registerSingleton<WalletCategoryRepository>(
      WalletCategoryRepositoryImpl());
  sl.registerSingleton<ChatRepository>(ChatRepositoryImpl());
  sl.registerSingleton<MessageRepository>(MessageRepositoryImpl());
  sl.registerSingleton<SheetRepository>(SheetRepositoryImpl());
  sl.registerSingleton<WalletTypeRepository>(WalletTypeRepositoryImpl());

  // Usecases
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<IsLoggedInUseCase>(IsLoggedInUseCase());
  sl.registerSingleton<GetUserUseCase>(GetUserUseCase());
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase());
  sl.registerSingleton<SigninUseCase>(SigninUseCase());
  sl.registerSingleton<getTotalUsedAmountUseCase>(getTotalUsedAmountUseCase());
  sl.registerSingleton<TransactionListUseCase>(TransactionListUseCase());
  sl.registerLazySingleton(() => RegisterDeviceTokenUseCase());
  sl.registerLazySingleton(() => GoogleSignInUseCase());
}
