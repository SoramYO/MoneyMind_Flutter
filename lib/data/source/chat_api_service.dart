import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/models/chat.dart';
import '../../core/constants/api_urls.dart';
import '../../core/network/dio_client.dart';
import '../../service_locator.dart';
abstract class ChatApiService {
  Future<Either<String, ChatBox>> getChats(
    String userId
    );
} 

class ChatApiServiceIml implements ChatApiService {
  @override
  Future<Either<String, ChatBox>> getChats(String userId) async {
    try {
      final response = await sl<DioClient>().get(
        '${ApiUrls.chat}/$userId',
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'];
        final chat = ChatBox.fromJson(data);
        return Right(chat);
      }
      
      return Left(response.data['message'] ?? 'Lỗi không xác định');
    } on DioException catch (e) {
      return Left(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối');
    }
  }
}