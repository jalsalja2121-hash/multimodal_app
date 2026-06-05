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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(geminiAnalysisProvider.notifier).analyze();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analysisAsync = ref.watch(geminiAnalysisProvider);
    final image = ref.watch(imageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('분석')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (image != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(image, fit: BoxFit.cover),
                  ),
                ),
              Expanded(
                child: analysisAsync.when(
                  data: (sections) {
                    if (sections.isEmpty) {
                      return const Center(child: Text('분석 중...'));
                    }

                    final status = sections
                        .where((s) => s.title == '현재 상태')
                        .firstOrNull;
                    final details = sections
                        .where((s) => s.title != '현재 상태')
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (status != null) ...[
                          _StatusCard(section: status),
                          const SizedBox(height: 12),
                        ],
                        Expanded(
                          child: ListView.separated(
                            itemCount: details.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) =>
                                _DetailRow(section: details[index]),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('오류: $e')),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(geminiAnalysisProvider.notifier).analyze(),
                child: const Text('다시 분석'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.section});
  final AnalysisSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              section.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    height: 1.6,
                  ),
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.section});
  final AnalysisSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                section.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
