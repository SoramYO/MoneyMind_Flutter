import 'package:dartz/dartz.dart';
import '../../core/usecase/usecase.dart';
import '../../service_locator.dart';
import '../repository/auth.dart';

class RegisterDeviceTokenUseCase extends UseCase<Either, String> {
  @override
  Future<Either> call({String? param}) async {
    return sl<AuthRepository>().registerDeviceToken(param!);
  }
}
