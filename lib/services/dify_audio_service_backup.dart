import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io' if (dart.library.html) 'dart:html' as html;

class DifyAudioService {
  static const String _baseUrl = 'https://api.dify.ai/v1';

  static String get _apiKey {
    final apiKey = dotenv.env['DIFY_API_KEY'] ?? '';
    print('API Key loaded: ${apiKey.isNotEmpty ? "✓ Valid" : "✗ Missing"}');
    if (apiKey.isEmpty) {
      print('Warning: DIFY_API_KEY not found in .env file');
    }
    return apiKey;
  }

  /// 파일을 Dify API에 업로드하는 함수
  static Future<String?> uploadFile(String filePath, String user) async {
    try {
      final apiKey = _apiKey;
      if (apiKey.isEmpty) {
        print('❌ API Key is empty');
        return null;
      }

      final url = Uri.parse('$_baseUrl/files/upload');

      final headers = {'Authorization': 'Bearer $apiKey'};

      print('=== Dify File Upload ===');
      print('URL: $url');
      print('File Path: $filePath');
      print('User: $user');
      print('API Key: ${apiKey.substring(0, 10)}...');

      // Multipart request 생성
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // 파일 추가 - 웹과 네이티브 구분
      try {
        final file = await http.MultipartFile.fromPath(
          'file',
          filePath,
          // .wav 파일의 경우 audio/wav MIME 타입 사용
          contentType: MediaType('audio', 'wav'),
        );
        request.files.add(file);
        print('✓ File added to request');
      } catch (fileError) {
        print('❌ Error adding file to request: $fileError');
        return null;
      }

      // 추가 데이터 - Dify API 문서에 맞게 수정
      request.fields['user'] = user;

      print('📤 Uploading file...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📥 Upload Response Status: ${response.statusCode}');
      print('📥 Upload Response Headers: ${response.headers}');
      print('📥 Upload Response Body: $responseBody');

      if (response.statusCode == 201) {
        final responseData = json.decode(responseBody);
        final fileId = responseData['id'];
        print('✅ File uploaded successfully, ID: $fileId');
        return fileId;
      } else {
        print('❌ File upload failed');
        print('   Status code: ${response.statusCode}');
        print('   Response: $responseBody');

        // 응답에서 에러 메시지 추출 시도
        try {
          final errorData = json.decode(responseBody);
          if (errorData['message'] != null) {
            print('   Error message: ${errorData['message']}');
          }
        } catch (e) {
          // JSON 파싱 실패 시 무시
        }

        return null;
      }
    } catch (e, stackTrace) {
      print('❌ File upload error: $e');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }

  /// 워크플로우를 실행하는 함수
  static Future<String> runWorkflow(
    String fileId,
    String user, {
    String responseMode = "blocking",
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/workflows/run');

      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        'inputs': {
          'audio_file': {
            'transfer_method': 'local_file',
            'upload_file_id': fileId,
            'type': 'audio',
          },
        },
        'response_mode': responseMode,
        'user': user,
      });

      print('=== Dify Workflow Run ===');
      print('URL: $url');
      print('Headers: $headers');
      print('Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      print('Workflow Response Status: ${response.statusCode}');
      print('Workflow Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // 워크플로우 응답에서 텍스트 추출
        if (responseData['data'] != null &&
            responseData['data']['outputs'] != null) {
          final outputs = responseData['data']['outputs'];
          // 출력에서 텍스트를 찾아 반환
          if (outputs is Map && outputs.containsKey('text')) {
            return outputs['text'].toString();
          } else if (outputs is Map && outputs.containsKey('result')) {
            return outputs['result'].toString();
          }
        }

        // 기본적으로 전체 응답을 문자열로 반환
        return responseData.toString();
      } else {
        return 'Workflow execution failed: ${response.statusCode}';
      }
    } catch (e) {
      print('Workflow execution error: $e');
      return 'Workflow execution error: $e';
    }
  }

  /// 파일 업로드와 워크플로우 실행을 연결하는 메인 함수
  static Future<String> processAudioFile(String filePath) async {
    const user = 'flutter-app-user';

    try {
      print('🎵 Processing audio file: $filePath');

      // 1. 파일 업로드
      final fileId = await uploadFile(filePath, user);

      if (fileId != null) {
        print('✅ File uploaded successfully, proceeding to workflow...');
        // 2. 워크플로우 실행
        final result = await runWorkflow(fileId, user);
        return result;
      } else {
        print('❌ File upload failed, cannot proceed');
        return 'File upload failed - please check API key and file format';
      }
    } catch (e, stackTrace) {
      print('❌ Process error: $e');
      print('   Stack trace: $stackTrace');
      return 'Process error: $e';
    }
  }
}
