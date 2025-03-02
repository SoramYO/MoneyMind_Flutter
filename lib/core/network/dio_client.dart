import 'package:dio/dio.dart';
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

  // Getter public để truy cập đối tượng Dio bên trong
  Dio get dio => _dio;

  Future<Options?> _getAuthOptions(String url, [Options? options]) async {
    // Skip authentication for auth-related endpoints
    if (url.contains('Authentications')) {
      return options;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null) {
      return Options(
        headers: {
          ...options?.headers ?? {},
          'Authorization': 'Bearer $token',
        },
      );
    }
    return options;
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
