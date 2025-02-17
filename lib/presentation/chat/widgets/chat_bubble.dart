import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/data/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.type == 'user' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.type == 'user' 
              ? Colors.green[100]
              : message.isError 
                  ? Colors.red[50]
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: message.isError 
              ? Border.all(color: Colors.red.withOpacity(0.5))
              : null,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: message.isError ? Colors.red[700] : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm dd/MM/yyyy').format(message.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 