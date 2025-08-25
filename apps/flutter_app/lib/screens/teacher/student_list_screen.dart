import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final List<Student> _students = [
    Student(
      name: '김철수',
      number: 1,
      todayEmotion: '행복',
      hasWrittenDiary: true,
      lastDiaryDate: DateTime.now(),
    ),
    Student(
      name: '이영희',
      number: 2,
      todayEmotion: '설렘',
      hasWrittenDiary: true,
      lastDiaryDate: DateTime.now(),
    ),
    Student(
      name: '박민수',
      number: 3,
      todayEmotion: '걱정',
      hasWrittenDiary: false,
      lastDiaryDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Student(
      name: '최지영',
      number: 4,
      todayEmotion: '행복',
      hasWrittenDiary: true,
      lastDiaryDate: DateTime.now(),
    ),
    Student(
      name: '정현우',
      number: 5,
      todayEmotion: '슬픔',
      hasWrittenDiary: true,
      lastDiaryDate: DateTime.now(),
    ),
    Student(
      name: '한소희',
      number: 6,
      todayEmotion: '화남',
      hasWrittenDiary: false,
      lastDiaryDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  String _filterEmotion = '전체';
  final List<String> _emotions = ['전체', '행복', '슬픔', '화남', '설렘', '걱정', '감사'];

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _filterStudents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('학생 목록'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          // 필터 및 통계
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 필터 버튼들
                Row(
                  children: [
                    Text(
                      '감정별 필터: ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _emotions.map((emotion) {
                            final isSelected = _filterEmotion == emotion;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(emotion),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _filterEmotion = selected ? emotion : '전체';
                                  });
                                },
                                selectedColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                checkmarkColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 통계 정보
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '총 학생',
                        '${_students.length}명',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        '오늘 작성',
                        '${_students.where((s) => s.hasWrittenDiary).length}명',
                        Icons.edit_note,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        '미작성',
                        '${_students.where((s) => !s.hasWrittenDiary).length}명',
                        Icons.warning,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 학생 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return _buildStudentCard(student);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Student> _filterStudents() {
    if (_filterEmotion == '전체') {
      return _students;
    }
    return _students
        .where((student) => student.todayEmotion == _filterEmotion)
        .toList();
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEmotionColor(student.todayEmotion),
          child: Text(
            student.number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘 감정: ${student.todayEmotion}'),
            Text(
              student.hasWrittenDiary
                  ? '오늘 일기 작성 완료'
                  : '마지막 작성: ${_formatDate(student.lastDiaryDate)}',
              style: TextStyle(
                color: student.hasWrittenDiary ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              student.hasWrittenDiary ? Icons.check_circle : Icons.schedule,
              color: student.hasWrittenDiary ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () => _showStudentDetail(student),
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case '행복':
        return Colors.green;
      case '슬픔':
        return Colors.blue;
      case '화남':
        return Colors.red;
      case '설렘':
        return Colors.orange;
      case '걱정':
        return Colors.yellow.shade700;
      case '감사':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else {
      return '$difference일 전';
    }
  }

  void _showStudentDetail(Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getEmotionColor(student.todayEmotion),
                  child: Text(
                    student.number.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '번호: ${student.number}번',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 오늘의 감정
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 감정',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_emotions,
                          color: _getEmotionColor(student.todayEmotion),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          student.todayEmotion,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 일기 작성 상태
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '일기 작성 상태',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          student.hasWrittenDiary
                              ? Icons.check_circle
                              : Icons.schedule,
                          color: student.hasWrittenDiary
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          student.hasWrittenDiary
                              ? '오늘 일기 작성 완료'
                              : '마지막 작성: ${_formatDate(student.lastDiaryDate)}',
                          style: TextStyle(
                            color: student.hasWrittenDiary
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: 학생 일기 보기 화면으로 이동
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('준비 중입니다!')));
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('일기 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: 학생과 대화하기 화면으로 이동
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('준비 중입니다!')));
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('대화하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Student {
  final String name;
  final int number;
  final String todayEmotion;
  final bool hasWrittenDiary;
  final DateTime lastDiaryDate;

  Student({
    required this.name,
    required this.number,
    required this.todayEmotion,
    required this.hasWrittenDiary,
    required this.lastDiaryDate,
  });
}
