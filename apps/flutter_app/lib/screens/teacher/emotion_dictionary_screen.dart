import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmotionDictionaryScreen extends StatefulWidget {
  const EmotionDictionaryScreen({super.key});

  @override
  State<EmotionDictionaryScreen> createState() =>
      _EmotionDictionaryScreenState();
}

class _EmotionDictionaryScreenState extends State<EmotionDictionaryScreen> {
  String _selectedEmotion = '행복';

  final Map<String, EmotionDefinition> _emotionDefinitions = {
    '행복': EmotionDefinition(
      emotion: '행복',
      currentDefinition: '마음이 기쁘고 웃고 싶은 느낌이에요',
      suggestions: [
        '친구와 재미있게 놀았을 때 느끼는 기분',
        '선생님께 칭찬받았을 때의 기분',
        '좋아하는 음식을 먹었을 때의 기분',
      ],
      voteCount: 15,
    ),
    '슬픔': EmotionDefinition(
      emotion: '슬픔',
      currentDefinition: '마음이 아프고 울고 싶은 느낌이에요',
      suggestions: ['친구와 다퉜을 때의 기분', '시험을 못 봤을 때의 기분', '좋아하는 장난감이 부서졌을 때의 기분'],
      voteCount: 8,
    ),
    '화남': EmotionDefinition(
      emotion: '화남',
      currentDefinition: '마음이 불편하고 화가 나는 느낌이에요',
      suggestions: [
        '친구가 내 물건을 망가뜨렸을 때의 기분',
        '누군가 나를 놀렸을 때의 기분',
        '게임에서 지고 싶지 않을 때의 기분',
      ],
      voteCount: 12,
    ),
    '설렘': EmotionDefinition(
      emotion: '설렘',
      currentDefinition: '마음이 두근두근하고 기대되는 느낌이에요',
      suggestions: ['소풍 가기 전날의 기분', '생일 파티를 기다릴 때의 기분', '새로운 친구를 만날 때의 기분'],
      voteCount: 10,
    ),
    '걱정': EmotionDefinition(
      emotion: '걱정',
      currentDefinition: '마음이 불안하고 걱정되는 느낌이에요',
      suggestions: ['시험을 앞두고 있을 때의 기분', '새로운 학교에 전학갈 때의 기분', '친구가 아플 때의 기분'],
      voteCount: 6,
    ),
    '감사': EmotionDefinition(
      emotion: '감사',
      currentDefinition: '고마운 마음이 드는 느낌이에요',
      suggestions: [
        '선생님이 도와주셨을 때의 기분',
        '친구가 생일 선물을 줬을 때의 기분',
        '엄마가 맛있는 음식을 해주셨을 때의 기분',
      ],
      voteCount: 9,
    ),
  };

  final List<String> _emotions = ['행복', '슬픔', '화남', '설렘', '걱정', '감사'];

  @override
  Widget build(BuildContext context) {
    final currentDefinition = _emotionDefinitions[_selectedEmotion]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('우리 반 감정 사전'),
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
            // 설명 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.book,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '우리 반만의 감정 사전',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '학생들과 함께 만든 감정 정의를 확인하고 관리하세요.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 감정 선택
            Text(
              '감정을 선택해주세요',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 감정 선택 버튼들
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _emotions.length,
                itemBuilder: (context, index) {
                  final emotion = _emotions[index];
                  final isSelected = _selectedEmotion == emotion;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedEmotion = emotion;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      child: Text(emotion),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 현재 정의 표시
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_emotions,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_selectedEmotion의 현재 정의',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentDefinition.currentDefinition,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${currentDefinition.voteCount}명이 선택',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 학생들의 제안 목록
            Text(
              '학생들의 제안',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: currentDefinition.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = currentDefinition.suggestions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(suggestion),
                      subtitle: Text('학생 제안'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _approveSuggestion(suggestion),
                            icon: const Icon(Icons.check_circle_outline),
                            color: Colors.green,
                          ),
                          IconButton(
                            onPressed: () => _rejectSuggestion(suggestion),
                            icon: const Icon(Icons.cancel_outlined),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 관리 버튼
            ElevatedButton.icon(
              onPressed: _manageDictionary,
              icon: const Icon(Icons.settings),
              label: const Text('감정 사전 관리'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _approveSuggestion(String suggestion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정의 승인'),
        content: Text('"$suggestion"을 $_selectedEmotion의 새로운 정의로 승인하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 정의 승인 로직 구현
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$_selectedEmotion의 정의가 업데이트되었습니다!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('승인'),
          ),
        ],
      ),
    );
  }

  void _rejectSuggestion(String suggestion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('제안 거부'),
        content: Text('"$suggestion" 제안을 거부하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 제안 거부 로직 구현
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('제안이 거부되었습니다.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('거부'),
          ),
        ],
      ),
    );
  }

  void _manageDictionary() {
    // TODO: 감정 사전 관리 화면으로 이동
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('준비 중입니다!')));
  }
}

class EmotionDefinition {
  final String emotion;
  final String currentDefinition;
  final List<String> suggestions;
  final int voteCount;

  EmotionDefinition({
    required this.emotion,
    required this.currentDefinition,
    required this.suggestions,
    required this.voteCount,
  });
}
