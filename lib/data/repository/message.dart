import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/message.dart';
import 'package:my_project/data/source/message_api_service.dart';
import 'package:my_project/domain/repository/message.dart';
import '../../service_locator.dart';

class MessageRepositoryImpl implements MessageRepository {
  @override

  Future<Either<String, List<Message>>> getMessages(String userId,{
    Map<String, String>? queryParams,
  }) async {
    try {
      final result = await sl<MessageApiService>().getMessages(
        userId,
        queryParams: queryParams,
      );
      return result.fold(
        (error) => Left(error.toString()),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

}