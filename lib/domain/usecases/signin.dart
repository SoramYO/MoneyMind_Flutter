import 'package:dartz/dartz.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/signin_req_params.dart';
import '../../service_locator.dart';
import '../repository/auth.dart';

class SigninUseCase implements UseCase<Either, SigninReqParams> {
  @override
  Future<Either> call({SigninReqParams? param}) async {
    return sl<AuthRepository>().signin(param!);
  }
}
