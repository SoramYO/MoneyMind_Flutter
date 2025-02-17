import 'package:my_project/core/usecase/usecase.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/domain/repository/auth.dart';

class IsLoggedInUseCase implements UseCase<bool, dynamic> {
  @override
  Future<bool> call({dynamic param}) async {
    return sl<AuthRepository>().isLoggedIn();
  }
}
