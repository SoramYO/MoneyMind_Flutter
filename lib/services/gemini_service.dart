import 'package:dio/dio.dart';
import 'dart:convert';

class GeminiService {
  final String apiKey;
  final Dio _dio = Dio();

  GeminiService(this.apiKey);

  Future<Map<String, dynamic>> analyzeMessage(String message) async {
    const String prompt = """
    Analyze this Vietnamese message and extract with personality:
    1. Amount of money spent (in VND, convert if needed - e.g., '15k' to 15000)
    2. Description of the transaction
    3. Generate a humorous criticism about the spending habit in Vietnamese
    
    Rules for the criticism:
    - Be a funny and sarcastic financial advisor
    - Use emojis to express emotions
    - Add Vietnamese internet slang when appropriate
    - If the amount is high, act shocked and dramatic
    - If the amount is low, be playfully condescending
    - If no amount found, be confused but still funny
    - Reference popular Vietnamese money-saving memes
    - Keep it friendly but slightly judgy
    - Use Vietnamese expressions and idioms
    
    Format the response as JSON:
    {
      "amount": number,
      "description": string,
      "criticism": string
    }
    
    Example criticisms:
    - "Chời ơi, 500k cho một ly trà sữa? Chắc ly này có ngọc trai thật chứ không phải trân châu rồi 😱"
    - "20k cho bánh mì? Thời buổi này giá cả leo thang như người yêu cũ leo lên xe hoa vậy 🥲"
    - "Ủa không thấy số tiền? Hay là chi tiêu nhiều quá nên không dám ghi ra ha? 👀"
    
    Only return the JSON object, no other text.
    """;

    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'contents': [{
            'parts': [{'text': '$prompt\nMessage: $message'}]
          }],
        },
        queryParameters: {'key': apiKey},
      );

      if (response.data['candidates'] == null || 
          response.data['candidates'].isEmpty) {
        throw Exception('No response from Gemini API');
      }

      final rawText = response.data['candidates'][0]['content']['parts'][0]['text'];
      // Remove markdown formatting if present
      final jsonText = rawText.replaceAll('```json\n', '').replaceAll('\n```', '');
      return Map<String, dynamic>.from(json.decode(jsonText));
    } catch (e) {
      throw Exception('Failed to analyze message: $e');
    }
  }
}