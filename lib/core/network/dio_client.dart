import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:my_project/data/source/auth_api_service.dart';
import 'package:my_project/domain/repository/auth.dart';
import 'package:my_project/main.dart';
import 'package:my_project/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'interceptors.dart';

class DioClient {
  late final Dio _dio;

  DioClient()
      : _dio = Dio(
          BaseOptions(
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            responseType: ResponseType.json,
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
          ),
        )..interceptors.addAll([LoggerInterceptor()]);

  /// Giải mã JWT để lấy thời gian hết hạn (exp)
  int? _getTokenExpiration(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = json.decode(payload) as Map<String, dynamic>;
      return payloadMap['exp'] as int?;
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra accessToken, nếu hết hạn thì refresh
  /// Kiểm tra accessToken, nếu hết hạn thì refresh hoặc logout
  Future<String?> _getValidAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('accessToken');
    var refreshToken = prefs.getString('refreshToken');
    var expRefreshTokenStr = prefs.getString('expRefreshToken');

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expAccessToken = _getTokenExpiration(accessToken);
    final expRefreshToken =
        expRefreshTokenStr != null ? int.tryParse(expRefreshTokenStr) : null;

    // Nếu accessToken vẫn còn hạn => sử dụng luôn
    if (expAccessToken != null && expAccessToken > currentTimestamp) {
      return accessToken;
    }

// Nếu refreshToken đã hết hạn => LOGOUT
    if (expRefreshToken == null || expRefreshToken <= currentTimestamp) {
      // Gọi phương thức logout
      await _logoutUser();
      return null;
    }

    // Nếu accessToken hết hạn nhưng refreshToken còn hạn => gọi API refresh token
    if (refreshToken != null) {
      try {
        final response = await sl<AuthApiService>().refreshToken();
        return response.fold((error) => null, (data) async {
          final newAccessToken = data.data['accessToken'];
          final newRefreshToken = data.data['refreshToken'];

          // Cập nhật token mới vào SharedPreferences
          await prefs.setString('accessToken', newAccessToken);
          await prefs.setString('refreshToken', newRefreshToken);
          // await prefs.setString(
          //     'expRefreshToken',
          //     (DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch ~/
          //             1000)
          //         .toString());

          return newAccessToken;
        });
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  Future<void> _logoutUser() async {
    await sl<AuthRepository>().logout();
  }

  /// Gắn accessToken hợp lệ vào request trước khi gửi
  Future<Options?> _getAuthOptions(String url, [Options? options]) async {
    if (url.contains('Authentications')) {
      return options; // Bỏ qua auth cho API đăng nhập / đăng ký
    }

    final token = await _getValidAccessToken();

    if (token == null) {
      // Nếu không có token, điều hướng về trang đăng nhập
      navigationKey.currentState
          ?.pushNamedAndRemoveUntil('/signin', (route) => false);
      return null; // Không tiếp tục gọi API
    }

    return Options(
      headers: {
        ...options?.headers ?? {},
        'Authorization': 'Bearer $token',
      },
    );
  }

  // GET METHOD
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final authOptions = await _getAuthOptions(url, options);
      if (authOptions == null) {
        // Không gọi API nếu đã logout
        throw DioException(
          requestOptions: RequestOptions(path: url),
          type:
              DioExceptionType.cancel, // Hủy request nếu không có token hợp lệ
          error: 'Unauthorized: Token is expired or user is logged out.',
        );
      }
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: authOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // POST METHOD
  Future<Response> post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final authOptions = await _getAuthOptions(url, options);
      if (!url.contains('Authentications')) {
        if (authOptions == null) {
          throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.cancel,
            error: 'Unauthorized: Token is expired or user is logged out.',
          );
        }
      }
      final Response response = await _dio.post(
        url,
        data: data,
        options: authOptions,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT METHOD
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final authOptions = await _getAuthOptions(url, options);
      if (authOptions == null) {
        throw DioException(
          requestOptions: RequestOptions(path: url),
          type: DioExceptionType.cancel,
          error: 'Unauthorized: Token is expired or user is logged out.',
        );
      }
      final Response response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: authOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE METHOD
  Future<dynamic> delete(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final authOptions = await _getAuthOptions(url, options);
      if (authOptions == null) {
        throw DioException(
          requestOptions: RequestOptions(path: url),
          type: DioExceptionType.cancel,
          error: 'Unauthorized: Token is expired or user is logged out.',
        );
      }
      final Response response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: authOptions,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
