import 'package:dartz/dartz.dart';
import 'package:my_project/core/usecase/usecase.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/domain/repository/auth.dart';

class GetUserUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call({dynamic param}) async {
    return sl<AuthRepository>().getUser();
  }
}
