import 'package:dartz/dartz.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/signup_req_params.dart';
import '../../service_locator.dart';
import '../repository/auth.dart';

class SignupUseCase implements UseCase<Either, SignupReqParams> {
  @override
  Future<Either> call({SignupReqParams? param}) async {
    return sl<AuthRepository>().signup(param!);
  }
}
