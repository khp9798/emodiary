import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({super.key});

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  final TextEditingController _diaryController = TextEditingController();
  bool _isRecording = false;
  String _currentEmotion = '';
  final List<String> _emotions = ['행복', '슬픔', '화남', '설렘', '걱정', '감사'];

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 쓰기'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 날짜 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTodayDate(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 감정 선택
            Text(
              '오늘의 감정을 선택해주세요',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 감정 버튼들
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emotions.map((emotion) {
                bool isSelected = _currentEmotion == emotion;
                return FilterChip(
                  label: Text(emotion),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _currentEmotion = selected ? emotion : '';
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 일기 입력 영역
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '오늘 있었던 일을 적어보세요',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 음성 녹음 버튼
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _toggleRecording,
                              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                              label: Text(_isRecording ? '녹음 중지' : '음성으로 입력'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRecording
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.secondary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 텍스트 입력 필드
                      Expanded(
                        child: TextField(
                          controller: _diaryController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            hintText:
                                '오늘 있었던 일을 자유롭게 적어보세요...\n\n예시:\n- 학교에서 친구와 재미있게 놀았어요\n- 수학 시험을 잘 봤어요\n- 엄마와 함께 맛있는 음식을 먹었어요',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 저장 버튼
            ElevatedButton(
              onPressed: _saveDiary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '일기 저장하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // TODO: 음성 녹음 시작
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('음성 녹음을 시작합니다...')));
    } else {
      // TODO: 음성 녹음 중지 및 STT 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음성 녹음을 중지하고 텍스트로 변환합니다...')),
      );
    }
  }

  void _saveDiary() {
    if (_diaryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('일기 내용을 입력해주세요!')));
      return;
    }

    if (_currentEmotion.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('오늘의 감정을 선택해주세요!')));
      return;
    }

    // TODO: 일기 저장 로직 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('일기가 저장되었습니다!')));

    // 홈 화면으로 돌아가기
    context.go('/');
  }
}
