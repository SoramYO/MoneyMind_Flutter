import 'dart:convert';

import 'package:my_project/data/models/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatStorageService {
  static const String _storageKey = 'chat_history';

  Future<void> saveChatHistory(String userId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_storageKey}_$userId';
    final jsonData = messages.map((msg) => msg.toJson()).toList();
    await prefs.setString(key, json.encode(jsonData));
  }

  Future<List<ChatMessage>> loadChatHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_storageKey}_$userId';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final jsonData = json.decode(jsonString) as List;
    return jsonData.map((item) => ChatMessage.fromJson(item)).toList();
  }

  Future<void> clearChatHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_storageKey}_$userId';
    await prefs.remove(key);
  }
} 