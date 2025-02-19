import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/chat.dart';
import 'package:my_project/data/source/chat_api_service.dart';
import 'package:my_project/domain/repository/chat.dart';
import '../../service_locator.dart';

class ChatRepositoryImpl implements ChatRepository {

  @override
  Future<Either<String, ChatBox>> getChats(String userId) async {
    try {
      final result = await sl<ChatApiService>().getChats(userId);
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}