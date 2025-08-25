import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/student/home_screen.dart';
import 'screens/student/diary_write_screen.dart';
import 'screens/student/emotion_dictionary_screen.dart';
import 'screens/student/chatbot_screen.dart';

void main() {
  runApp(const ProviderScope(child: EmoDiaryStudentApp()));
}

class EmoDiaryStudentApp extends StatelessWidget {
  const EmoDiaryStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EmoDiary - 학생용',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/diary-write',
      builder: (context, state) => const DiaryWriteScreen(),
    ),
    GoRoute(
      path: '/emotion-dictionary',
      builder: (context, state) => const EmotionDictionaryScreen(),
    ),
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const ChatbotScreen(),
    ),
  ],
);
