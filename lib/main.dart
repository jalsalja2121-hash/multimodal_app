import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart'; // 필요한 경우 주석 해제
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

void main() async {
  // 1. Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Hive(로컬 DB) 초기화
  await Hive.initFlutter();

  // 3. Firebase 초기화 
  // 윈도우/안드로이드 설정을 마치기 전까지는 앱 크래시 방지를 위해 주석 처리하거나 
  // 아래처럼 조건부 실행을 권장합니다.
  // await Firebase.initializeApp();

  // 4. ProviderScope로 감싸야 Riverpod을 사용할 수 있습니다.
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multimodal App',
      theme: ThemeData(
        // [수정] 최신 Flutter에서는 이미 기본값이므로 삭제하여 에러 해결
        colorSchemeSeed: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multimodal App'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Hello, Multimodal World!'),
      ),
    );
  }
}