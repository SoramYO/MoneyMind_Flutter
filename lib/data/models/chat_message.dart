import 'dart:convert';

class ChatMessage {
  final String type;
  final String message;
  final bool isError;
  final DateTime timestamp;

  ChatMessage({
    required this.type,
    required this.message,
    this.isError = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'isError': isError,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    type: json['type'],
    message: json['message'],
    isError: json['isError'] ?? false,
    timestamp: DateTime.parse(json['timestamp']),
  );
} 