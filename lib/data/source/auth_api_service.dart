import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';
import '../models/signin_req_params.dart';
import '../models/signup_req_params.dart';

abstract class AuthApiService {
  Future<Either> signup(SignupReqParams signupReq);
  Future<Either> getUser();
  Future<Either> signin(SigninReqParams signinReq);
}

class AuthApiServiceImpl extends AuthApiService {
  @override
  Future<Either> signup(SignupReqParams signupReq) async {
    try {
      var response =
          await sl<DioClient>().post(ApiUrls.register, data: signupReq.toMap());

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }

  @override
  Future<Either> getUser() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      print("auth_api_service: ");
      print(accessToken);
      var response = await sl<DioClient>().get(ApiUrls.userProfile,
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
      print(response.toString());
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }

  // @override
  // Future<Either> getUser() async {
  //   try {
  //     SharedPreferences sharedPreferences =
  //         await SharedPreferences.getInstance();
  //     var token = sharedPreferences.getString('accessToken');
  //     var response = await sl<DioClient>().get(
  //         "https://covid-api.com/api/regions",
  //         options: Options(headers: {'Authorization': 'Bearer $token '}));

  //     return Right(response);
  //   } on DioException catch (e) {
  //     SharedPreferences sharedPreferences =
  //         await SharedPreferences.getInstance();
  //     var token = sharedPreferences.getString('accessToken');
  //     var response = await sl<DioClient>().get(
  //         "https://covid-api.com/api/regions",
  //         options: Options(headers: {'Authorization': 'Bearer $token '}));

  //     return Right(response);
  //   }
  // }

  @override
  Future<Either> signin(SigninReqParams signinReq) async {
    try {
      var response =
          await sl<DioClient>().post(ApiUrls.login, data: signinReq.toMap());
      return Right(response);
    } on DioException catch (e) {
      return Left(e.response!.toString());
    }
  }
}
