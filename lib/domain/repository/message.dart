import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/message.dart';

abstract class MessageRepository {
  Future<Either<String, List<Message>>> getMessages(
    String userId,{
    Map<String, String>? queryParams,
    }
  );
} 