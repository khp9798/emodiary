import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/teacher/dashboard_screen.dart';
import 'screens/teacher/student_list_screen.dart';
import 'screens/teacher/emotion_dictionary_screen.dart';
import 'screens/teacher/statistics_screen.dart';

void main() {
  runApp(const ProviderScope(child: EmoDiaryTeacherApp()));
}

class EmoDiaryTeacherApp extends StatelessWidget {
  const EmoDiaryTeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EmoDiary - 교사용',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
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
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/students',
      builder: (context, state) => const StudentListScreen(),
    ),
    GoRoute(
      path: '/emotion-dictionary',
      builder: (context, state) => const EmotionDictionaryScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
  ],
);
