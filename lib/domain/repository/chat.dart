import 'package:dartz/dartz.dart';
import 'package:my_project/data/models/chat.dart';

abstract class ChatRepository {
  Future<Either<String, ChatBox>> getChats(
    String userId
    );
} 