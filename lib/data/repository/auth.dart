import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/utils/firebase_utils.dart';
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
      if (response.statusCode == 200) {
        return Right(response.data); // Trả về message thành công
      }
      return Left("Đăng ký thất bại");
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
      return Left(error.data['message']);
    }, (data) {
      Response response = data;
      var userModel = UserModel.fromMap(response.data['data']);
      var userEntity = userModel.toEntity();
      return Right(userEntity);
    });
  }

  // @override
  // Future<Either> getUser() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   String fullName = sharedPreferences.getString('fullName').toString();
  //   String email = sharedPreferences.getString('email').toString();
  //   Either result = await sl<AuthApiService>().getUser();
  //   return result.fold((error) {
  //     UserEntity userEntity = new UserEntity(email: email, fullName: fullName);
  //     return Right(userEntity);
  //   }, (data) {
  //     UserEntity userEntity = new UserEntity(email: email, fullName: fullName);
  //     return Right(userEntity);
  //   });
  // }

  @override
  Future<Either> logout() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      // Xóa tất cả dữ liệu trong SharedPreferences
      await sharedPreferences.clear();

      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either> signin(SigninReqParams signinReq) async {
    Either result = await sl<AuthApiService>().signin(signinReq);
    return result.fold((error) {
      return Left(error);
    }, (data) async {
      Response response = data;
      var roles = response.data['data']['roles'];
      if (roles.contains('User')) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        // Lưu userId vào SharedPreferences
        sharedPreferences.setString('userId', response.data['data']['userId']);

        // Lưu tokens vào SharedPreferences
        sharedPreferences.setString(
            'accessToken', response.data['data']['tokens']['accessToken']);
        sharedPreferences.setString(
            'refreshToken', response.data['data']['tokens']['refreshToken']);
        // Lưu user tạm vào SharedPreferences
        sharedPreferences.setString(
            'fullName', response.data['data']['fullName']);
        sharedPreferences.setString('email', response.data['data']['email']);

        // Xử lý device token
        String token = await getDeviceToken();
        print("Token: $token");
        if (token == "empty token") {
          return Left("Không thể lấy device token");
        }

        Either deviceTokenResult = await registerDeviceToken(token);
        return deviceTokenResult.fold(
            (error) => Left("Không thể đăng ký device token"),
            (success) => Right(response));

        return Right(response);
      }
      return Left(
          "Đăng nhập thất bại: Bạn không có quyền truy cập với role này.");
    });
  }

  @override
  Future<Either> registerDeviceToken(String deviceToken) async {
    Either result = await sl<AuthApiService>().registerDeviceToken(deviceToken);
    return result.fold((error) {
      return Left(error);
    }, (data) {
      Response response = data;
      return Right(response);
    });
  }

  // dart
  @override
  Future<Either> googleSignIn(String accessToken) async {
    try {
      final result = await sl<AuthApiService>().googleSignIn(accessToken);
      return await result.fold((error) async {
        return Left(error);
      }, (data) async {
        Response response = data;
        var roles = response.data['data']['roles'];
        if (roles.contains('User')) {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();

          // Save userId
          sharedPreferences.setString(
              'userId', response.data['data']['userId']);

          // Save tokens
          sharedPreferences.setString(
              'accessToken', response.data['data']['tokens']['accessToken']);
          sharedPreferences.setString(
              'refreshToken', response.data['data']['tokens']['refreshToken']);

          // Save temporary user info
          sharedPreferences.setString(
              'fullName', response.data['data']['fullName']);
          sharedPreferences.setString('email', response.data['data']['email']);

          String token = await getDeviceToken();
          print("Token: $token");
          if (token == "empty token") {
            return Left("Không thể lấy device token");
          }

          Either deviceTokenResult = await registerDeviceToken(token);
          return deviceTokenResult.fold(
              (error) => Left("Không thể đăng ký device token"),
              (success) => Right(response));

          return Right(true);
        } else {
          return Left(
              "Đăng nhập thất bại: Bạn không có quyền truy cập với role này.");
        }
      });
    } catch (e) {
      return Left(e.toString());
    }
  }
}
