import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

final speechTextProvider = StateProvider<String>((ref) => '');
final isListeningProvider = StateProvider<bool>((ref) => false);
