import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 학생용 감정 사전 화면
///
/// 학생들이 감정에 대한 정의를 확인하고 새로운 정의를 제안할 수 있는 화면
class EmotionDictionaryScreen extends StatefulWidget {
  const EmotionDictionaryScreen({super.key});

  @override
  State<EmotionDictionaryScreen> createState() =>
      _EmotionDictionaryScreenState();
}

class _EmotionDictionaryScreenState extends State<EmotionDictionaryScreen> {
  final TextEditingController _definitionController = TextEditingController();
  String _selectedEmotion = '행복';

  // 감정별 기본 정의 - 아동 눈높이에 맞춘 설명
  final Map<String, String> _emotionDefinitions = {
    '행복': '마음이 기쁘고 웃고 싶은 느낌이에요',
    '슬픔': '마음이 아프고 울고 싶은 느낌이에요',
    '화남': '마음이 불편하고 화가 나는 느낌이에요',
    '설렘': '마음이 두근두근하고 기대되는 느낌이에요',
    '걱정': '마음이 불안하고 걱정되는 느낌이에요',
    '감사': '고마운 마음이 드는 느낌이에요',
  };

  final List<String> _emotions = ['행복', '슬픔', '화남', '설렘', '걱정', '감사'];

  @override
  void dispose() {
    _definitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      '우리 반만의 감정 사전을 만들어보세요!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '감정에 대해 우리 반 친구들과 함께 의미를 정해보세요.',
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
                          _definitionController.text =
                              _emotionDefinitions[emotion] ?? '';
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
                          '$_selectedEmotion의 뜻',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _emotionDefinitions[_selectedEmotion] ?? '',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 새로운 정의 입력
            Text(
              '새로운 의미를 제안해보세요',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _definitionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '$_selectedEmotion에 대한 새로운 의미를 적어보세요...',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // 제안 버튼
            ElevatedButton(
              onPressed: _submitDefinition,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '의미 제안하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // 다른 학생들의 제안 보기 버튼
            OutlinedButton(
              onPressed: _viewOtherSuggestions,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '다른 친구들의 제안 보기',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 새로운 감정 정의 제안
  ///
  /// 학생이 선택한 감정에 대한 새로운 정의를 제안하는 기능
  void _submitDefinition() {
    if (_definitionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('감정의 의미를 입력해주세요!')));
      return;
    }

    // TODO: 정의 제안 로직 구현 - 서버에 제안 내용 전송
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_selectedEmotion에 대한 의미를 제안했습니다!'),
        backgroundColor: Colors.green,
      ),
    );

    // 입력 필드 초기화
    _definitionController.clear();
  }

  void _viewOtherSuggestions() {
    // TODO: 다른 학생들의 제안 보기 화면으로 이동
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('준비 중입니다!')));
  }
}
