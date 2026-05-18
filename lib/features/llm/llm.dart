import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../input/input.dart';
import '../stt/stt.dart';

class GeminiAnalysisNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return '';
  }

  Future<void> analyze() async {
    final image = ref.read(imageProvider);
    final text = ref.read(speechTextProvider);

    state = const AsyncLoading();

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final List<Part> parts = [];

      // 사진 추가 (imageProvider가 Uint8List이므로 바로 사용)
      if (image != null) {
        parts.add(DataPart('image/jpeg', image));
      }

      // 음성 텍스트 추가 (없으면 기본 질문)
      if (text.isNotEmpty) {
        parts.add(TextPart(text));
      } else {
        parts.add(TextPart('이 사진에 대해 한국어로 설명해줘'));
      }

      final content = [Content.multi(parts)];
      final response = await model.generateContent(content);

      state = AsyncData(response.text ?? '응답이 없습니다.');
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final geminiAnalysisProvider =
    AsyncNotifierProvider<GeminiAnalysisNotifier, String>(
  GeminiAnalysisNotifier.new,
);
