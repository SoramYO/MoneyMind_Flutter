import 'package:dartz/dartz.dart';
import 'package:my_project/core/usecase/usecase.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/domain/repository/auth.dart';

class LogoutUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call({param}) async {
    return await sl<AuthRepository>().logout();
  }
}
