import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io' show File;

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

  /// 웹용 파일 업로드 (바이트 데이터 사용)
  static Future<String?> uploadFileFromBytes(
    Uint8List fileBytes,
    String fileName,
    String user,
  ) async {
    try {
      final apiKey = _apiKey;
      if (apiKey.isEmpty) {
        print('❌ API Key is empty');
        return null;
      }

      final url = Uri.parse('$_baseUrl/files/upload');
      final headers = {'Authorization': 'Bearer $apiKey'};

      print('=== Dify Web File Upload ===');
      print('URL: $url');
      print('File Name: $fileName');
      print('File Size: ${fileBytes.length} bytes');
      print('User: $user');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // 바이트 데이터로부터 멀티파트 파일 생성
      final file = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType('audio', 'wav'),
      );
      request.files.add(file);
      request.fields['user'] = user;

      print('📤 Uploading file from bytes...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📥 Upload Response Status: ${response.statusCode}');
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
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Web file upload error: $e');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }

  /// 네이티브용 파일 업로드 (파일 경로 사용)
  static Future<String?> uploadFileFromPath(
    String filePath,
    String user,
  ) async {
    try {
      final apiKey = _apiKey;
      if (apiKey.isEmpty) {
        print('❌ API Key is empty');
        return null;
      }

      final url = Uri.parse('$_baseUrl/files/upload');
      final headers = {'Authorization': 'Bearer $apiKey'};

      print('=== Dify Native File Upload ===');
      print('URL: $url');
      print('File Path: $filePath');
      print('User: $user');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // 파일 경로에서 멀티파트 파일 생성
      final file = await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('audio', 'wav'),
      );
      request.files.add(file);
      request.fields['user'] = user;

      print('📤 Uploading file from path...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📥 Upload Response Status: ${response.statusCode}');
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
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Native file upload error: $e');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }

  /// 챗봇 API를 실행하는 함수
  static Future<String> runChatbot(
    String fileId,
    String user, {
    String responseMode = "blocking",
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/chat-messages');

      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        'inputs': {},
        'query': '음성 파일을 분석해주세요.',
        'files': [
          {
            'type': 'audio',
            'transfer_method': 'local_file',
            'upload_file_id': fileId,
          },
        ],
        'response_mode': responseMode,
        'conversation_id': '',
        'user': user,
      });

      print('=== Dify Chatbot Run ===');
      print('URL: $url');
      print('Headers: $headers');
      print('Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      print('Chatbot Response Status: ${response.statusCode}');
      print('Chatbot Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // 챗봇 응답에서 텍스트 추출
        if (responseData['answer'] != null) {
          return responseData['answer'].toString();
        } else if (responseData['data'] != null &&
            responseData['data']['answer'] != null) {
          return responseData['data']['answer'].toString();
        }

        // 기본적으로 전체 응답을 문자열로 반환
        return responseData.toString();
      } else {
        return 'Chatbot execution failed: ${response.statusCode}';
      }
    } catch (e) {
      print('Chatbot execution error: $e');
      return 'Chatbot execution error: $e';
    }
  }

  /// 챗봇 앱으로 실행하는 함수

  /// 완성형 앱으로 실행하는 함수
  static Future<String> runCompletion(
    String fileId,
    String user, {
    String responseMode = "blocking",
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/completion-messages');

      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        'inputs': {'audio_file': fileId},
        'query': '음성 파일을 분석해주세요.',
        'files': [
          {
            'type': 'audio',
            'transfer_method': 'local_file',
            'upload_file_id': fileId,
          },
        ],
        'response_mode': responseMode,
        'user': user,
      });

      print('=== Dify Completion Run ===');
      print('URL: $url');
      print('Headers: $headers');
      print('Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      print('Completion Response Status: ${response.statusCode}');
      print('Completion Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // 완성형 응답에서 텍스트 추출
        if (responseData['answer'] != null) {
          return responseData['answer'].toString();
        }

        // 기본적으로 전체 응답을 문자열로 반환
        return responseData.toString();
      } else {
        return 'Completion execution failed: ${response.statusCode}';
      }
    } catch (e) {
      print('Completion execution error: $e');
      return 'Completion execution error: $e';
    }
  }

  /// 웹용 오디오 처리 함수
  static Future<String> processAudioFileWeb(
    Uint8List audioBytes,
    String fileName, [
    String? user,
  ]) async {
    user ??= 'flutter-app-user';

    try {
      print('Processing audio file for web: $fileName');
      print('Audio data size: ${audioBytes.length} bytes');

      // 웹에서 바이트 데이터로 파일 업로드
      final fileId = await uploadFileFromBytes(audioBytes, fileName, user);

      if (fileId != null) {
        print('File uploaded successfully, proceeding to chatbot...');
        final result = await runChatbot(fileId, user);
        return result;
      } else {
        print('File upload failed, cannot proceed');
        return 'File upload failed - please check API key and file format';
      }
    } catch (e, stackTrace) {
      print('Web process error: $e');
      print('   Stack trace: $stackTrace');
      return 'Web process error: $e';
    }
  }

  /// 네이티브용 오디오 처리 함수
  static Future<String> processAudioFileNative(
    String filePath, [
    String? user,
  ]) async {
    user ??= 'flutter-app-user';

    try {
      print('📱 Processing audio file for native: $filePath');

      // 파일 존재 여부 확인
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ File does not exist: $filePath');
        return 'File does not exist';
      }

      final fileId = await uploadFileFromPath(filePath, user);

      if (fileId != null) {
        print('File uploaded successfully, proceeding to chatbot...');
        final result = await runChatbot(fileId, user);
        return result;
      } else {
        print('❌ File upload failed, cannot proceed');
        return 'File upload failed - please check API key and file format';
      }
    } catch (e, stackTrace) {
      print('❌ Native process error: $e');
      print('   Stack trace: $stackTrace');
      return 'Native process error: $e';
    }
  }

  /// 메인 처리 함수 - 플랫폼에 따라 자동 선택
  static Future<String> processAudioFile(
    dynamic audioData, [
    String? user,
  ]) async {
    user ??= 'flutter-app-user';

    if (kIsWeb) {
      // 웹에서는 audioData가 Uint8List이거나 파일명이어야 함
      if (audioData is Uint8List) {
        final fileName =
            'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        return processAudioFileWeb(audioData, fileName, user);
      } else if (audioData is String) {
        // 웹에서 문자열이 전달되면 현재는 더미 처리
        print('⚠️ Web environment: String path received, need Uint8List data');
        return 'Web environment: Audio bytes data required, not file path';
      }
      return 'Web environment: Invalid audio data type';
    } else {
      // 네이티브에서는 audioData가 파일 경로(String)이어야 함
      if (audioData is String) {
        return processAudioFileNative(audioData, user);
      }
      return 'Native environment: File path required';
    }
  }

  /// API 키 유효성 테스트 함수
  static Future<Map<String, dynamic>> testApiKey() async {
    try {
      print('🔍 Testing API key: ${_baseUrl}/apps');

      final url = Uri.parse('${_baseUrl}/apps');
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      print('📥 API Test Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {'valid': true, 'message': 'API key is valid'};
      } else {
        return {
          'valid': false,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ API Key test error: $e');
      return {'valid': false, 'error': e.toString()};
    }
  }
}
