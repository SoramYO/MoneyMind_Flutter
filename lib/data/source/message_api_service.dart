import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/message.dart';
import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';
abstract class MessageApiService {
  Future<Either<String, List<Message>>> getMessages(
    String userId,{
    Map<String, String>? queryParams,
    });
} 

class MessageApiServiceIml implements MessageApiService {
  @override
  Future<Either<String, List<Message>>> getMessages(String userId,{
    Map<String, String>? queryParams,
    }) async {
    try {
      final response = await sl<DioClient>().get(
        '${ApiUrls.message}/$userId',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['data'];
        print("data: $data");
        final messages = data
            .map((json) => Message.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(messages);
      }
      
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }

}
