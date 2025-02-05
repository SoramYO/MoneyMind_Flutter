import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalService {
  Future<bool> isLoggedIn();
  Future<Either> logout();
}

class AuthLocalServiceImpl extends AuthLocalService {
  @override
  Future<bool> isLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Kiểm tra sự tồn tại của accessToken và refreshToken
    var accessToken = sharedPreferences.getString('accessToken');
    if (accessToken == null) {
      return false; // Người dùng chưa đăng nhập
    } else {
      return true; // Người dùng đã đăng nhập
    }
  }

  @override
  Future<Either> logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    return const Right(true);
  }
}
