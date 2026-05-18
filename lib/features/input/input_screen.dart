import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'input.dart';
import '../stt/stt_screen.dart';

class InputScreen extends ConsumerWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ① 창고에서 꺼내기
    final imageBytes = ref.watch(imageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('입력')),
      body: SafeArea(
        top: false, // AppBar가 상단 처리
        child: Column(
          children: [
            // 이미지 영역
            Expanded(
              child: Container(
                color: Colors.grey[200],
                width: double.infinity,
                child: imageBytes != null
                    ? Image.memory(imageBytes, fit: BoxFit.cover)
                    : const Center(child: Text('사진을 찍어보세요')),
              ),
            ),
            // 버튼 영역 — 가로/세로 모두 잘리지 않도록 Padding + Wrap 사용
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                      );
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        ref.read(imageProvider.notifier).state = bytes;
                      }
                    },
                    child: const Text('카메라'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        ref.read(imageProvider.notifier).state = bytes;
                      }
                    },
                    child: const Text('갤러리'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SttScreen()),
                      );
                    },
                    child: const Text('음성 입력으로 이동'),
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
