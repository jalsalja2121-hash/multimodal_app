import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../input/input.dart';
import 'llm.dart';

class LlmScreen extends ConsumerStatefulWidget {
  const LlmScreen({super.key});

  @override
  ConsumerState<LlmScreen> createState() => _LlmScreenState();
}

class _LlmScreenState extends ConsumerState<LlmScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 자동으로 Gemini 분석 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(geminiAnalysisProvider.notifier).analyze();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 창고에서 꺼내기
    final analysisAsync = ref.watch(geminiAnalysisProvider);
    final image = ref.watch(imageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('분석')),
      body: SafeArea(
        top: false, // AppBar가 상단 처리
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 선택된 이미지 미리보기
              if (image != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Image.memory(image, fit: BoxFit.cover),
                ),
              // Gemini 응답 영역
              Expanded(
                child: analysisAsync.when(
                  data: (text) => text.isEmpty
                      ? const Center(child: Text('분석 중...'))
                      : SingleChildScrollView(
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('오류: $e')),
                ),
              ),
              const SizedBox(height: 16),
              // 다시 분석 버튼
              ElevatedButton(
                onPressed: () =>
                    ref.read(geminiAnalysisProvider.notifier).analyze(),
                child: const Text('다시 분석'),
              ),
            ],
          ),
        ), // Padding
      ), // SafeArea
    );
  }
}
