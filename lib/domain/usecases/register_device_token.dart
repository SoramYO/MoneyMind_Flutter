import 'package:dartz/dartz.dart';
import 'package:my_project/core/usecase/usecase.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/domain/repository/auth.dart';

class RegisterDeviceTokenUseCase extends UseCase<Either, String> {
  @override
  Future<Either> call({String? param}) async {
    return sl<AuthRepository>().registerDeviceToken(param!);
  }
}
