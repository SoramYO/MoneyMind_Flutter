import 'package:dartz/dartz.dart';
import 'package:my_project/core/usecase/usecase.dart';
import 'package:my_project/data/models/signin_req_params.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/domain/repository/auth.dart';

class SigninUseCase implements UseCase<Either, SigninReqParams> {
  @override
  Future<Either> call({SigninReqParams? param}) async {
    return sl<AuthRepository>().signin(param!);
  }
}
