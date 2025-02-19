class ChatBox{
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime lastMessageTime;
  final DateTime createdAt;

  ChatBox({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.lastMessageTime,
    required this.createdAt,
  });

  factory ChatBox.fromJson(Map<String, dynamic> json) {
    return ChatBox(
      id: json['id'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  @override
  String toString() {
    return 'ChatBox(id: $id, userId: $userId, startTime: $startTime, lastMessageTime: $lastMessageTime, createdAt: $createdAt)';
  }
}