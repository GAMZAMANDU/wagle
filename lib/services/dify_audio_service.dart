import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DifyAudioService {
  static const String baseUrl = 'https://api.dify.ai/v1';

  // 환경변수에서 API 키 가져오기
  static String? get apiKey => dotenv.env['DIFY_API_KEY'];

  // 파일 업로드 함수
  static Future<String?> uploadFile(String filePath, String user) async {
    if (apiKey == null) {
      print('❌ API 키가 설정되지 않았습니다.');
      return null;
    }

    try {
      final uri = Uri.parse('$baseUrl/files/upload');
      final request = http.MultipartRequest('POST', uri);

      // 헤더 설정
      request.headers['Authorization'] = 'Bearer $apiKey';

      // 필드와 파일 추가
      request.fields['user'] = user;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      print('📤 파일 업로드 중: $filePath');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 업로드 응답 상태: ${response.statusCode}');
      print('📋 업로드 응답 내용: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final fileId = responseData['id'];
        print('✅ 파일 업로드 성공! File ID: $fileId');
        return fileId;
      } else {
        print('❌ 파일 업로드 실패: ${response.statusCode}');
        print('❌ 오류 내용: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ 파일 업로드 중 오류 발생: $e');
      return null;
    }
  }

  // Chat App 실행 함수
  static Future<String?> runChatApp(String fileId, String user) async {
    if (apiKey == null) {
      print('❌ API 키가 설정되지 않았습니다.');
      return null;
    }

    try {
      final uri = Uri.parse('$baseUrl/chat-messages');

      final payload = {
        'inputs': {'audio_file': fileId},
        'query': '', // 빈 쿼리 (파이썬 코드와 동일)
        'user': user,
        'response_mode': 'blocking',
      };

      print('📤 Chat App 실행 중...');
      print('📋 요청 데이터: ${json.encode(payload)}');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      print('📊 Chat App 응답 상태: ${response.statusCode}');
      print('📋 Chat App 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final answer = responseData['answer'];
        print('✅ Chat App 실행 성공!');
        return answer;
      } else {
        print('❌ Chat App 실행 실패: ${response.statusCode}');
        print('❌ 오류 내용: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Chat App 실행 중 오류 발생: $e');
      return null;
    }
  }

  // 전체 프로세스 실행 (파이썬의 main 함수와 동일)
  static Future<String?> processAudioFile(String filePath, String user) async {
    print('🎵 음성 파일 처리 시작: $filePath');

    // 1단계: 파일 업로드
    final fileId = await uploadFile(filePath, user);
    if (fileId == null) {
      return '파일 업로드에 실패했습니다.';
    }

    // 2단계: Chat App 실행
    final result = await runChatApp(fileId, user);
    if (result == null) {
      return 'Chat App 실행에 실패했습니다.';
    }

    print('🎉 전체 프로세스 완료!');
    return result;
  }

  // API 키 유효성을 테스트하는 함수
  static Future<Map<String, dynamic>> testApiKey() async {
    try {
      final key = apiKey;
      if (key == null || key.isEmpty) {
        print('❌ API Key test failed: Key is empty');
        return {'valid': false, 'error': 'API key is empty'};
      }

      // 간단한 API 키 테스트 - apps 엔드포인트 호출
      final url = Uri.parse('$baseUrl/apps');
      final headers = {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      };

      print('🔍 Testing API key: $url');

      final response = await http.get(url, headers: headers);

      print('🔍 API Key test response:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ API Key is valid');
        return {'valid': true, 'response': response.body};
      } else {
        print('❌ API Key test failed with status: ${response.statusCode}');
        return {'valid': false, 'error': 'Status: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ API Key test error: $e');
      return {'valid': false, 'error': e.toString()};
    }
  }
}
