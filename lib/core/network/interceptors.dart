import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:my_project/core/network/dio_client.dart';
import 'package:my_project/data/source/auth_api_service.dart';
import 'package:my_project/data/source/auth_local_service.dart';
import 'package:my_project/domain/repository/auth.dart';
import 'package:my_project/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
      printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true));

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath'); //Error log
    logger.d('Error type: ${err.error} \n '
        'Error message: ${err.message}'); //Debug log

    if (err.response?.statusCode == 401) {
      // Nếu mã lỗi là 401 (token hết hạn), thực hiện refresh token
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var refreshToken = sharedPreferences.getString('refreshToken');

      if (refreshToken != null) {
        try {
          // Gọi phương thức refreshToken
          var response = await sl<AuthApiService>().refreshToken();
          response.fold((error) {
            handler.next(
                err); // Nếu có lỗi trong refresh token, tiếp tục với lỗi cũ
          }, (data) async {
            // Lưu accessToken mới vào SharedPreferences
            Response newResponse = data;
            var newAccessToken = newResponse.data['accessToken'];
            var newRefreshToken = newResponse.data['refreshToken'];
            await sharedPreferences.setString('accessToken', newAccessToken);
            // Lưu refreshToken mới vào SharedPreferences
            await sharedPreferences.setString('refreshToken', newRefreshToken);
            // Retry request ban đầu với accessToken mới
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            final newRequest = await sl<DioClient>().dio.request(
                  options.path,
                  queryParameters: options.queryParameters,
                  data: options.data,
                  options:
                      Options(method: options.method, headers: options.headers),
                );
            handler.resolve(newRequest); // Tiếp tục với yêu cầu mới
          });
        } catch (e) {
          logger.d('Error refreshing token: $e');
          handler
              .next(err); // Nếu có lỗi khi refresh token, tiếp tục với lỗi cũ
        }
      } else {
        logger.d('Refresh token not available');
        handler.next(err); // Không có refresh token, tiếp tục với lỗi cũ
      }
    }
    if (err.response?.statusCode == 400) {
      // Nếu mã lỗi là 400 (refreshToken hết hạn), thực hiện logout
      try {
        // Gọi phương thức logout
        await sl<AuthRepository>().logout();
      } catch (e) {
        logger.d('Error logout: $e');
        handler.next(err); // Nếu có lỗi khi logout, tiếp tục với lỗi cũ
      }
    } else {
      handler.next(err); // Nếu không phải lỗi 401, 400, tiếp tục với lỗi cũ
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath'); //Info log
    handler.next(options); // continue with the Request
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('STATUSCODE: ${response.statusCode} \n '
        'STATUSMESSAGE: ${response.statusMessage} \n'
        'HEADERS: ${response.headers} \n'
        'Data: ${response.data}'); // Debug log
    handler.next(response); // continue with the Response
  }
}
