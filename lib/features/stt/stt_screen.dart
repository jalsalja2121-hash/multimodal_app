import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'stt.dart';
import '../llm/llm_screen.dart';

class SttScreen extends ConsumerStatefulWidget {
  const SttScreen({super.key});

  @override
  ConsumerState<SttScreen> createState() => _SttScreenState();
}

class _SttScreenState extends ConsumerState<SttScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _available = await _speech.initialize();
      setState(() {});
    } catch (e) {
      debugPrint('STT 초기화 실패: $e');
    }
  }

  Future<void> _startListening() async {
    if (!_available) return;
    await _speech.listen(
      localeId: 'ko_KR',
      onResult: (result) {
        // ① 텍스트 창고에 넣기
        ref.read(speechTextProvider.notifier).state = result.recognizedWords;
      },
    );
    // ② 듣는 중 상태 창고에 넣기
    ref.read(isListeningProvider.notifier).state = true;
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    // ③ 멈춤 상태 창고에 넣기
    ref.read(isListeningProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    // ④ 창고에서 꺼내기
    final speechText = ref.watch(speechTextProvider);
    final isListening = ref.watch(isListeningProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('음성 입력')),
      body: SafeArea(
        top: false, // AppBar가 상단 처리
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ⑤ 텍스트 표시
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                speechText.isEmpty ? '마이크 버튼을 눌러보세요' : speechText,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            // ⑥ 버튼 — Wrap으로 가로 모드에서도 줄바꿈
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: isListening ? _stopListening : _startListening,
                    child: Text(isListening ? '듣는 중... (탭하여 중지)' : '마이크 시작'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LlmScreen()),
                      );
                    },
                    child: const Text('분석 화면으로 이동'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
