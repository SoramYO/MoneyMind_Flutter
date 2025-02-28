import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const MessageInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.green.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Write your message',
                  hintStyle: TextStyle(color: Color.fromARGB(255, 88, 88, 88), fontSize: 16),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            isLoading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: onSend,
                      child: const Icon(
                        Icons.send,
                        color: Colors.green,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
