import 'package:flutter/material.dart';
import 'package:my_project/data/source/transaction_api_service.dart';
import 'package:my_project/services/chat_transaction_service.dart';
import 'package:my_project/services/gemini_service.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/services/chat_storage_service.dart';
import 'package:my_project/data/models/chat_message.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  
  const ChatPage({Key? key, required this.userId}) : super(key: key);
  
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _chatHistory = [];
  bool _isProcessing = false;
  bool _isScrolling = false;
  late final ChatTransactionService _chatService;
  final _chatStorage = ChatStorageService();

  @override
  void initState() {
    super.initState();
    _chatService = ChatTransactionService(
      GeminiService("AIzaSyCgV3ESGRwgcUyzG9e1MF9GvI4sYJ81zps"),
      sl<TransactionApiService>(),
    );
    _loadChatHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isScrolling = true;
    });
    
    final messages = await _chatStorage.loadChatHistory(widget.userId);
    setState(() {
      _chatHistory = messages;
    });
    
    // Add delay to ensure ListView is built before scrolling
    await Future.delayed(const Duration(milliseconds: 100));
    await _scrollToBottom();
    
    setState(() {
      _isScrolling = false;
    });
  }

  Future<void> _scrollToBottom() async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _saveChatHistory() async {
    await _chatStorage.saveChatHistory(widget.userId, _chatHistory);
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final userMessage = ChatMessage(
      type: 'user',
      message: message,
    );

    setState(() {
      _isProcessing = true;
      _chatHistory.add(userMessage);
    });
    await _saveChatHistory();

    try {
      final result = await _chatService.processChat(message, widget.userId);
      
      final botMessage = ChatMessage(
        type: 'bot',
        message: result['criticism'],
        isError: !result['success'],
      );

      setState(() {
        _chatHistory.add(botMessage);
      });
      await _saveChatHistory();
      _scrollToBottom();

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu giao dịch thành công!')),
        );
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        type: 'bot',
        message: 'Error: $e',
        isError: true,
      );
      
      setState(() {
        _chatHistory.add(errorMessage);
      });
      await _saveChatHistory();
      _scrollToBottom();
    }

    setState(() => _isProcessing = false);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with MoneyMind'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final chat = _chatHistory[index];
                    return ChatBubble(
                      message: chat.message,
                      isUser: chat.type == 'user',
                      isError: chat.isError,
                    );
                  },
                ),
              ),
              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập chi tiêu của bạn...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _isProcessing ? null : _sendMessage,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isScrolling)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isError;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}