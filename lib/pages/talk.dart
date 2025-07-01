import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import '../services/dify_audio_service_new.dart';

class TalkPage extends StatefulWidget {
  const TalkPage({Key? key}) : super(key: key);

  @override
  State<TalkPage> createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  final FlutterTts flutterTts = FlutterTts();
  String displayText = "Hello, How are you?";
  bool isSpeaking = false;
  bool isProcessingDify = false;
  bool isListening = false;

  // 타이머 관련 변수들
  Timer? _timer;
  int _remainingSeconds = 300; // 5분 = 300초

  @override
  void initState() {
    super.initState();
    _initTts();
    _startTimer();
    _testDifyConnection(); // API 연결 테스트 추가
  }

  // API 연결 테스트 함수 추가
  Future<void> _testDifyConnection() async {
    if (kIsWeb) {
      print('Web environment: Skipping API connection test due to CORS');
      return;
    }

    print('🔗 Testing Dify API connection...');
    final result = await DifyAudioService.testApiKey();
    final isValid = result['valid'] == true;
    if (isValid) {
      print('✅ Dify API connection successful');
    } else {
      print('❌ Dify API connection failed: ${result['error']}');
    }
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    flutterTts.setStartHandler(() => setState(() => isSpeaking = true));
    flutterTts.setCompletionHandler(() => setState(() => isSpeaking = false));
    flutterTts.setErrorHandler((msg) => setState(() => isSpeaking = false));

    // initState에서 _speak 함수 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak();
    });
  }

  Future<void> _speak() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      await flutterTts.speak(displayText);
    }
  }

  Future<void> _updateTextAndSpeak(String newText) async {
    setState(() {
      displayText = newText;
      isProcessingDify = false;
    });

    // 새로운 텍스트를 TTS로 읽어주기
    await Future.delayed(const Duration(milliseconds: 500)); // 약간의 지연
    await flutterTts.speak(newText);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          // 5분이 지나면 홈으로 이동
          _timer?.cancel();
          Navigator.of(context).pop();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    flutterTts.stop();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackground(),
            _buildTextAndSpeakerButton(),
            _buildTimer(),
            _buildMicButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D1B69), Color(0xFF1E1E2E)],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/place/cafe2.png"),
            fit: BoxFit.cover,
            onError: null, // 이미지 로딩 실패 시 그라데이션 배경 유지
          ),
        ),
      ),
    );
  }

  Widget _buildTextAndSpeakerButton() {
    return Positioned(
      top: 20, // SafeArea 내에서 적절한 여백
      left: 32,
      right: 32,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _speak,
              child: Stack(
                children: [
                  Text(
                    displayText,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.8,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (isProcessingDify)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'AI가 답변 중...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isListening && !isProcessingDify)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic, color: Colors.white, size: 12),
                            SizedBox(width: 6),
                            Text(
                              '듣고 있어요...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _speak,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSpeaking ? Icons.stop : Icons.volume_up,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    bool isWarning = _remainingSeconds <= 60;
    bool isCritical = _remainingSeconds <= 30;

    return Positioned(
      bottom: 220, // 마이크 버튼 위쪽에 위치
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isCritical
                    ? Colors.red.withOpacity(0.9)
                    : isWarning
                    ? Colors.orange.withOpacity(0.9)
                    : Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            boxShadow:
                isCritical
                    ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: MicButton(
        onDifyResponse: _updateTextAndSpeak,
        onProcessingChange: (processing) {
          setState(() {
            isProcessingDify = processing;
          });
        },
        onListeningChange: (listening) {
          setState(() {
            isListening = listening;
          });
        },
      ),
    );
  }
}

class MicButton extends StatefulWidget {
  final Function(String) onDifyResponse;
  final Function(bool) onProcessingChange;
  final Function(bool) onListeningChange;

  const MicButton({
    Key? key,
    required this.onDifyResponse,
    required this.onProcessingChange,
    required this.onListeningChange,
  }) : super(key: key);

  @override
  _MicButtonState createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  double _buttonSize = 80.0;
  final double _maxButtonSize = 90.0;
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  // 녹음을 위한 Record 인스턴스
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _sizeAnimation = Tween<double>(
      begin: _buttonSize,
      end: _maxButtonSize,
    ).animate(_animationController)..addListener(() {
      setState(() {
        _buttonSize = _sizeAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<String> _getRecordingPath() async {
    if (kIsWeb) {
      // 웹에서는 임시 경로 사용
      return 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    } else {
      // 모바일/데스크톱에서는 실제 경로 사용
      final directory = await getTemporaryDirectory();
      return '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    }
  }

  Future<void> _startRecording() async {
    try {
      // 마이크 권한 확인
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        print('Microphone permission denied');
        return;
      }

      final path = await _getRecordingPath();

      setState(() => _isRecording = true);
      widget.onListeningChange(true);
      _animationController.forward();

      print('=== Recording Started ===');
      print('Recording to: $path');

      // 녹음 시작
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav, // .wav 형식으로 녹음
          sampleRate: 16000, // 16kHz 샘플링 레이트
          bitRate: 128000, // 128kbps 비트레이트
        ),
        path: path,
      );

      print('Recording started successfully');
    } catch (e) {
      print('Failed to start recording: $e');
      _stopRecording();
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() => _isRecording = false);
      widget.onListeningChange(false);
      _animationController.reverse();

      if (await _audioRecorder.isRecording()) {
        final path = await _audioRecorder.stop();
        print('=== Recording Stopped ===');
        print('Recording saved to: $path');

        if (path != null && path.isNotEmpty) {
          // 녹음된 파일을 Dify API로 전송
          await _processRecordedFile(path);
        }
      }

      print('Recording stopped');
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  Future<void> _processRecordedFile(String filePath) async {
    try {
      print('=== Processing Recorded File ===');
      print('📁 File path: $filePath');

      widget.onProcessingChange(true);

      String result;

      if (kIsWeb) {
        // 웹에서는 Blob URL을 처리할 수 없으므로 녹음 데이터를 바이트로 가져와야 함      print('Web environment detected');

        // Record 패키지에서 웹 녹음 데이터를 바이트로 가져오기 시도
        try {
          final webAudioBytes = await _getWebRecordingBytes();

          if (webAudioBytes != null) {
            result = await DifyAudioService.processAudioFile(
              webAudioBytes,
              'user-123',
            );
          } else {
            result = '웹에서 오디오 데이터를 가져오는 데 실패했습니다.';
          }
        } catch (e) {
          print('Web audio processing error: $e');
          result = '웹에서 오디오 처리 중 오류가 발생했습니다: $e';
        }
      } else {
        // 네이티브에서는 파일 경로 사용
        final file = File(filePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          print('✅ File exists, size: ${fileSize} bytes');
        } else {
          print('❌ File does not exist!');
          widget.onDifyResponse('녹음 파일이 생성되지 않았습니다.');
          return;
        }

        result = await DifyAudioService.processAudioFile(filePath, 'user-123');

        // 임시 파일 삭제
        if (file.existsSync()) {
          await file.delete();
          print('🗑️ Temporary file deleted: $filePath');
        }
      }

      print('=== Dify Processing Result ===');
      print('📤 Result: $result');
      print('================================');

      // 콜백을 통해 UI 업데이트 및 TTS 실행
      widget.onDifyResponse(result);
    } catch (e, stackTrace) {
      print('❌ Error processing recorded file: $e');
      print('   Stack trace: $stackTrace');
      widget.onDifyResponse('파일 처리 중 오류가 발생했습니다: $e');
    } finally {
      widget.onProcessingChange(false);
    }
  }

  // 웹에서 녹음된 데이터를 바이트로 가져오는 함수
  Future<Uint8List?> _getWebRecordingBytes() async {
    if (!kIsWeb) return null;

    try {
      // 웹에서는 Record 패키지가 내부적으로 MediaRecorder API를 사용함
      // 현재 Record 패키지의 웹 구현에서는 직접 바이트 데이터에 접근하기 어려움
      // 임시 해결책: 더미 WAV 헤더가 포함된 바이트 데이터 생성

      print('Generating dummy audio bytes for web test');

      // 간단한 WAV 헤더 + 더미 오디오 데이터
      final List<int> wavHeader = [
        // RIFF 헤더
        0x52, 0x49, 0x46, 0x46, // "RIFF"
        0x24, 0x08, 0x00, 0x00, // 파일 크기 - 8
        0x57, 0x41, 0x56, 0x45, // "WAVE"
        // fmt 청크
        0x66, 0x6D, 0x74, 0x20, // "fmt "
        0x10, 0x00, 0x00, 0x00, // fmt 청크 크기
        0x01, 0x00, // 오디오 포맷 (PCM)
        0x01, 0x00, // 채널 수 (모노)
        0x40, 0x1F, 0x00, 0x00, // 샘플링 레이트 (8000Hz)
        0x80, 0x3E, 0x00, 0x00, // 바이트 레이트
        0x02, 0x00, // 블록 정렬
        0x10, 0x00, // 비트 깊이 (16비트)
        // data 청크
        0x64, 0x61, 0x74, 0x61, // "data"
        0x00, 0x08, 0x00, 0x00, // 데이터 크기
      ];

      // 더미 오디오 데이터 (사인파)
      final List<int> audioData =
          List.generate(2048, (i) {
            final double t = i / 8000.0;
            final double sample = (32767 * 0.5 * (1 + sin(t * 440 * 2 * pi)));
            final int sampleInt = sample.clamp(-32768, 32767).round();
            return [sampleInt & 0xFF, (sampleInt >> 8) & 0xFF];
          }).expand((x) => x).toList();

      final allBytes = [...wavHeader, ...audioData];
      return Uint8List.fromList(allBytes);
    } catch (e) {
      print('Error getting web recording bytes: $e');
      return null;
    }
  }

  void _onButtonPressed() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _onButtonPressed,
        onTapDown: (_) {
          _animationController.forward();
        },
        onTapUp: (_) {
          _animationController.reverse();
        },
        onTapCancel: () {
          _animationController.reverse();
        },
        child: Container(
          width: _buttonSize,
          height: _buttonSize,
          decoration: BoxDecoration(
            color: _isRecording ? Colors.red.withOpacity(0.8) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            Icons.mic,
            color: _isRecording ? Colors.white : Colors.black54,
            size: 32,
          ),
        ),
      ),
    );
  }
}
