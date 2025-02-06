import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repository/auth.dart';
import '../../service_locator.dart';
import '../models/signin_req_params.dart';
import '../models/signup_req_params.dart';
import '../models/user.dart';
import '../source/auth_api_service.dart';
import '../source/auth_local_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> signup(SignupReqParams signupReq) async {
    Either result = await sl<AuthApiService>().signup(signupReq);
    return result.fold((error) {
      return Left(error);
    }, (data) async {
      Response response = data;
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      // Lưu tokens vào SharedPreferences
      sharedPreferences.setString(
          'accessToken', response.data['data']['tokens']['accessToken']);
      sharedPreferences.setString(
          'refreshToken', response.data['data']['tokens']['refreshToken']);
      // Lưu user tạm vào SharedPreferences
      sharedPreferences.setString(
          'userName', response.data['data']['username']);
      sharedPreferences.setString('email', response.data['data']['email']);
      return Right(response);
    });
  }

  @override
  Future<bool> isLoggedIn() async {
    return await sl<AuthLocalService>().isLoggedIn();
  }

  @override
  Future<Either> getUser() async {
    Either result = await sl<AuthApiService>().getUser();
    return result.fold((error) {
      return Left(error);
    }, (data) {
      Response response = data;
      var userModel = UserModel.fromMap(response.data);
      var userEntity = userModel.toEntity();
      return Right(userEntity);
    });
  }

  // @override
  // Future<Either> getUser() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   String userName = sharedPreferences.getString('userName').toString();
  //   String email = sharedPreferences.getString('email').toString();
  //   Either result = await sl<AuthApiService>().getUser();
  //   return result.fold((error) {
  //     UserEntity userEntity = new UserEntity(email: email, username: userName);
  //     return Right(userEntity);
  //   }, (data) {
  //     UserEntity userEntity = new UserEntity(email: email, username: userName);
  //     return Right(userEntity);
  //   });
  // }

  @override
  Future<Either> logout() async {
    return await sl<AuthLocalService>().logout();
  }

  @override
  Future<Either> signin(SigninReqParams signinReq) async {
    Either result = await sl<AuthApiService>().signin(signinReq);
    return result.fold((error) {
      return Left(error);
    }, (data) async {
      Response response = data;
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      // Lưu tokens vào SharedPreferences
      sharedPreferences.setString(
          'accessToken', response.data['data']['tokens']['accessToken']);
      sharedPreferences.setString(
          'refreshToken', response.data['data']['tokens']['refreshToken']);
      // Lưu user tạm vào SharedPreferences
      sharedPreferences.setString(
          'userName', response.data['data']['username']);
      sharedPreferences.setString('email', response.data['data']['email']);
      return Right(response);
    });
  }
}
