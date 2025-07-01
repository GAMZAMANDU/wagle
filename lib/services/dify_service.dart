import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DifyService {
  static String get _baseUrl =>
      dotenv.env['DIFY_BASE_URL'] ?? 'https://api.dify.ai/v1';
  static String get _apiKey => dotenv.env['DIFY_API_KEY'] ?? '';

  static Future<String> sendMessage(String text) async {
    try {
      if (_apiKey.isEmpty) {
        return 'API 키가 설정되지 않았습니다. .env 파일을 확인해주세요.';
      }

      final url = Uri.parse('$_baseUrl/chat-messages');

      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        'inputs': {},
        'query': text,
        'response_mode': 'blocking',
        'conversation_id': '',
        'user': 'user-123',
      });

      print('=== Dify API Request ===');
      print('URL: $url');
      print('Headers: $headers');
      print('Body: $body');
      print('========================');

      final response = await http.post(url, headers: headers, body: body);

      print('=== Dify API Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=========================');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Dify API 응답 구조에 따라 메시지 추출
        if (responseData['answer'] != null) {
          return responseData['answer'];
        } else if (responseData['data'] != null &&
            responseData['data']['answer'] != null) {
          return responseData['data']['answer'];
        } else {
          return responseData.toString();
        }
      } else {
        print('Dify API Error: ${response.statusCode} - ${response.body}');
        return 'API 요청 실패: ${response.statusCode}';
      }
    } catch (e) {
      print('Dify API Exception: $e');
      return 'API 요청 중 오류 발생: $e';
    }
  }
}
