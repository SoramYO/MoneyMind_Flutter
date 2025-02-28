import 'package:flutter/material.dart';
import 'package:my_project/data/models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBot = message.isBotResponse;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Align(
        alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            // Nếu là tin nhắn từ bot thì nền xanh, ngược lại nền trắng với border xanh
            color: isBot ? Colors.green : Colors.white,
            borderRadius: isBot
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
            border: isBot ? null : Border.all(color: Colors.green, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Text(
            message.messageContent,
            style: TextStyle(
              // Text trắng trên nền xanh và xanh đậm trên nền trắng
              color: isBot ? Colors.white : Colors.green[800],
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
