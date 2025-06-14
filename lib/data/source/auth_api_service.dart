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
  Future<Either> refreshToken();
  Future<Either> registerDeviceToken(String deviceToken);
  Future<Either> googleSignIn(String token);
}

class AuthApiServiceImpl extends AuthApiService {
  @override
  Future<Either> signup(SignupReqParams signupReq) async {
    try {
      var response =
          await sl<DioClient>().post(ApiUrls.register, data: signupReq.toMap());

      if (response.statusCode == 200) {
        return Right(response);
      }
      return Left(response.data.toString());
    } on DioException catch (e) {
      return Left(e.response?.data?.toString() ?? "Lỗi đăng ký");
    }
  }

  @override
  Future<Either> getUser() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');
      var response = await sl<DioClient>().get(ApiUrls.userProfile,
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
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

  @override
  Future<Either> refreshToken() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var refreshToken = sharedPreferences.getString('refreshToken');
      var userId = sharedPreferences.getString("userId");
      if (refreshToken == null) {
        return Left('Refresh token is missing');
      }
      if (userId == null) {
        return Left('Unknow User');
      }

      var response = await sl<DioClient>().post(
        ApiUrls.refreshToken,
        data: {'refreshToken': refreshToken, 'userId': userId},
      );

      // Lưu access token mới
      var newAccessToken = response.data['accessToken'];
      var newRefreshToken = response.data['refreshToken'];

      await sharedPreferences.setString('accessToken', newAccessToken);
      await sharedPreferences.setString('refreshToken', newRefreshToken);

      return Right(response);
    } on DioException catch (e) {
      return Left(e.response?.toString() ?? 'Error refreshing token');
    }
  }

  @override
  Future<Either> registerDeviceToken(String deviceToken) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var accessToken = sharedPreferences.getString('accessToken');

      var response = await sl<DioClient>().post(
        ApiUrls.registerToken,
        data: {'token': deviceToken},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return Right(response);
      }
      return Left(response.data.toString());
    } on DioException catch (e) {
      return Left(e.response?.data?.toString() ?? "Lỗi đăng ký device token");
    }
  }

  @override
  Future<Either> googleSignIn(String token) async {
    try {
      var response = await sl<DioClient>()
          .post(ApiUrls.googleSignIn, data: {'token': token});

      if (response.statusCode == 200) {
        return Right(response);
      }
      return Left(response.data.toString());
    } on DioException catch (e) {
      return Left(e.response?.data?.toString() ?? "Lỗi đăng nhập Google");
    }
  }
}
