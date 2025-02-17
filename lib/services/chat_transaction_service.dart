// lib/services/chat_transaction_service.dart
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/data/source/transaction_api_service.dart';
import 'package:my_project/services/gemini_service.dart';

class ChatTransactionService {
  final GeminiService _geminiService;
  final TransactionApiService _transactionApi;

  ChatTransactionService(this._geminiService, this._transactionApi);

  Future<Map<String, dynamic>> processChat(String message, String userId) async {
    try {
      // Analyze message with Gemini
      final analysis = await _geminiService.analyzeMessage(message);
      
      if (analysis['amount'] == null) {
        return {
          'success': false,
          'description': analysis['description'] ?? 'Không thể xác định nội dung',
          'criticism': analysis['criticism'] ?? 'Bạn có thể nói rõ hơn về chi tiêu của bạn không?',
        };
      }

      // Create transaction with proper type conversion
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recipientName: 'Self',
        amount: (analysis['amount'] is int) 
            ? analysis['amount'].toDouble() 
            : analysis['amount'],
        description: analysis['description'],
        transactionDate: DateTime.now(),
        createAt: DateTime.now(),
        lastUpdateAt: DateTime.now(),
        userId: userId,
        tags: [], // Can be enhanced with tag detection
      );

      // Save to database
      final result = await _transactionApi.createTransaction(transaction);

      return {
        'transaction': transaction,
        'description': analysis['description'],
        'criticism': analysis['criticism'],
        'success': result.isRight(),
        'error': result.fold(
          (error) => error,
          (_) => null,
        ),
      };
    } catch (e) {
      // Log the error for debugging
      print('Error in processChat: $e');
      
      if (e.toString().contains('Failed to analyze message')) {
        return {
          'success': false,
          'description': 'Lỗi xử lý',
          'criticism': 'Xin lỗi, tôi đang gặp vấn đề khi phân tích tin nhắn. Bạn thử lại nhé! 🙏',
          'error': e.toString(),
        };
      }
      
      return {
        'success': false,
        'description': 'Lỗi xử lý',
        'criticism': e.toString(),
        'error': e.toString(),
      };
    }
  }
}