import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = '주간';
  final List<String> _periods = ['일간', '주간', '월간'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('감정 통계'),
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
            // 기간 선택
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '통계 기간',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _periods.map((period) {
                        final isSelected = _selectedPeriod == period;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPeriod = period;
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
                              child: Text(period),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 요약 통계
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    '평균 감정 점수',
                    '8.2',
                    '/10',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    '일기 작성률',
                    '72',
                    '%',
                    Icons.edit_note,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    '가장 많은 감정',
                    '행복',
                    '',
                    Icons.emoji_emotions,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    '관심 필요한 학생',
                    '3',
                    '명',
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 감정 분포 차트
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_selectedPeriod 감정 분포',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEmotionChart(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 감정 변화 추이
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '감정 변화 추이',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTrendChart(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 상세 통계 버튼
            ElevatedButton.icon(
              onPressed: _showDetailedStats,
              icon: const Icon(Icons.analytics),
              label: const Text('상세 통계 보기'),
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

  Widget _buildSummaryCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: color),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionChart() {
    final emotions = [
      {'name': '행복', 'count': 8, 'color': Colors.green},
      {'name': '슬픔', 'count': 3, 'color': Colors.blue},
      {'name': '화남', 'count': 2, 'color': Colors.red},
      {'name': '설렘', 'count': 5, 'color': Colors.orange},
      {'name': '걱정', 'count': 4, 'color': Colors.yellow.shade700},
      {'name': '감사', 'count': 3, 'color': Colors.purple},
    ];

    return Column(
      children: emotions.map((emotion) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  emotion['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: (emotion['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (emotion['count'] as int) / 10, // 최대값을 10으로 가정
                    child: Container(
                      decoration: BoxDecoration(
                        color: emotion['color'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${emotion['count']}명'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendChart() {
    // 간단한 트렌드 차트 (실제로는 차트 라이브러리 사용)
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedPeriod 평균 감정 점수 변화',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTrendBar('월', 7.5),
                const SizedBox(width: 8),
                _buildTrendBar('화', 8.2),
                const SizedBox(width: 8),
                _buildTrendBar('수', 7.8),
                const SizedBox(width: 8),
                _buildTrendBar('목', 8.5),
                const SizedBox(width: 8),
                _buildTrendBar('금', 8.2),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('7.0', style: Theme.of(context).textTheme.bodySmall),
              Text('10.0', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBar(String day, double score) {
    final height = (score / 10) * 120; // 최대 높이 120
    final color = score >= 8
        ? Colors.green
        : score >= 6
        ? Colors.orange
        : Colors.red;

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 20,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(day, style: Theme.of(context).textTheme.bodySmall),
          Text(
            score.toStringAsFixed(1),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showDetailedStats() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '상세 통계',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 상세 통계 내용
            Expanded(
              child: ListView(
                children: [
                  _buildDetailCard(
                    '학생별 감정 분석',
                    '각 학생의 감정 패턴을 분석하여 개별 맞춤 지원 방안을 제시합니다.',
                    Icons.person_search,
                  ),
                  _buildDetailCard(
                    '감정 사전 활용도',
                    '학급 감정 사전의 활용 빈도와 효과를 분석합니다.',
                    Icons.book,
                  ),
                  _buildDetailCard(
                    '일기 작성 패턴',
                    '학생들의 일기 작성 시간대와 내용 패턴을 분석합니다.',
                    Icons.schedule,
                  ),
                  _buildDetailCard(
                    '감정 변화 요인',
                    '학생들의 감정 변화에 영향을 주는 요인들을 분석합니다.',
                    Icons.psychology,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 상세 통계 화면으로 이동
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('준비 중입니다!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('전체 상세 통계 보기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: 각 상세 통계 화면으로 이동
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$title 준비 중입니다!')));
        },
      ),
    );
  }
}
