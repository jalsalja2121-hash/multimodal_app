import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../input/input.dart';
import '../stt/stt.dart';

class AnalysisSection {
  final String title;
  final String content;
  const AnalysisSection({required this.title, required this.content});
}

// 시스템 엔지니어링: 역할 부여
const _systemPrompt = '당신은 학교의 장비를 관리하는 조교입니다. '
    '장비의 수명과 교체시기를 분석하여'
    '명확하고 유익한 인사이트를 한국어로 제공합니다.';

// 지침 엔지니어링: 응답 형식 및 행동 지침
const _instructionPrompt = '다음 지침을 따라 응답해줘:\n'
    '1. 반드시 아래 JSON 형식으로만 응답해줘 (마크다운 코드블록 없이):\n'
    '{"sections":[{"title":"섹션 제목","content":"상세 내용"}]}\n'
    '2. 섹션은 반드시 아래 순서와 제목으로 구성해줘:\n'
    '   - 현재 상태: 이미지에서 보이는 현재 상태를 설명\n'
    '   - 카테고리: 사물 또는 상황의 분류\n'
    '   - 교체시기: 교체 또는 갱신이 필요한 시기\n'
    '   - 필요 조치: 즉시 또는 향후 필요한 조치\n'
    '   - 상세: 추가적인 상세 분석\n'
    '3. 현재 상태를 제외한 각 섹션의 content는 반드시 1~4단어 이내의 핵심 키워드로만 작성해줘. 문장 금지.';

class GeminiAnalysisNotifier extends AsyncNotifier<List<AnalysisSection>> {
  @override
  Future<List<AnalysisSection>> build() async {
    return [];
  }

  Future<void> analyze() async {
    final image = ref.read(imageProvider);
    final text = ref.read(speechTextProvider);

    state = const AsyncLoading();

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      final model = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(_systemPrompt),
      );

      final List<Part> parts = [];

      if (image != null) {
        parts.add(DataPart('image/jpeg', image));
      }

      final userQuery = text.isNotEmpty ? text : '이 사진을 한국어로 분석해줘.';
      parts.add(TextPart('$userQuery\n\n$_instructionPrompt'));

      final content = [Content.multi(parts)];
      final response = await model.generateContent(content);

      state = AsyncData(_parseSections(response.text ?? ''));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  List<AnalysisSection> _parseSections(String raw) {
    try {
      final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final sections = json['sections'] as List;
      return sections
          .map((s) => AnalysisSection(
                title: s['title'] as String,
                content: s['content'] as String,
              ))
          .toList();
    } catch (_) {
      return [AnalysisSection(title: '분석 결과', content: raw)];
    }
  }
}

final geminiAnalysisProvider =
    AsyncNotifierProvider<GeminiAnalysisNotifier, List<AnalysisSection>>(
  GeminiAnalysisNotifier.new,
);
