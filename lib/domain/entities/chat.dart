class ChatEntity{
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime lastMessageTime;
  final DateTime createAt;

  ChatEntity({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.lastMessageTime,
    required this.createAt,
  });
}