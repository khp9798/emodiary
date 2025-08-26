// 파일 시스템 접근을 위한 라이브러리 (파일 생성, 삭제, 읽기 등)
import 'dart:io';

// Flutter의 기본 UI 라이브러리 (버튼, 텍스트, 카드 등 모든 UI 요소)
import 'package:flutter/material.dart';

// 화면 간 이동을 위한 라우팅 라이브러리
import 'package:go_router/go_router.dart';

// 마이크 권한 요청을 위한 라이브러리
import 'package:permission_handler/permission_handler.dart';

// 음성 녹음 기능을 위한 라이브러리
import 'package:flutter_sound/flutter_sound.dart';

// 앱의 문서 폴더 경로를 가져오기 위한 라이브러리
import 'package:path_provider/path_provider.dart';

/// 일기 작성 화면 위젯
///
/// StatefulWidget은 상태가 변할 수 있는 위젯입니다.
/// 사용자가 텍스트를 입력하거나 녹음할 때 화면이 업데이트되어야 하므로 StatefulWidget을 사용합니다.
class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({super.key});

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

/// 일기 작성 화면의 상태를 관리하는 클래스
///
/// State 클래스는 위젯의 상태(데이터)를 저장하고 관리합니다.
/// 사용자가 입력한 텍스트, 선택한 감정, 녹음 상태 등을 여기서 관리합니다.
class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  // 텍스트 입력 컨트롤러 - 사용자가 입력한 텍스트를 관리
  // TextEditingController는 텍스트 필드의 내용을 읽고 쓸 수 있게 해줍니다
  final TextEditingController _diaryController = TextEditingController();

  // 녹음 관련 상태 변수들
  bool _isRecording = false; // 현재 녹음 중인지 여부
  bool _busy = false; // 중복 클릭 방지용 플래그 (사용자가 버튼을 여러 번 누르는 것을 막음)
  bool _recorderOpened = false; // 녹음기가 초기화되었는지 여부
  String? _recordingPath; // 녹음된 파일의 저장 경로 (null일 수 있음)
  String _currentEmotion = ''; // 사용자가 선택한 감정

  // 감정 옵션 리스트 - 사용자가 선택할 수 있는 감정들
  final List<String> _emotions = ['행복', '슬픔', '화남', '설렘', '걱정', '감사'];

  // Flutter Sound 녹음기 인스턴스 - 실제 녹음 기능을 담당
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  /// 위젯이 처음 생성될 때 호출되는 메서드
  ///
  /// 화면이 처음 나타날 때 한 번만 실행됩니다.
  /// 여기서는 녹음기를 초기화합니다.
  @override
  void initState() {
    super.initState(); // 부모 클래스의 initState 호출 (필수)
    _safeInitRecorder(); // 녹음기 안전 초기화
  }

  /// 위젯이 파괴될 때 호출되는 메서드
  ///
  /// 화면을 떠날 때 실행됩니다.
  /// 메모리 누수를 방지하기 위해 사용한 리소스들을 정리합니다.
  @override
  void dispose() {
    _diaryController.dispose(); // 텍스트 컨트롤러 정리
    // 화면을 떠날 때 안전하게 정리
    _safeDisposeRecorder(); // 녹음기 정리
    super.dispose(); // 부모 클래스의 dispose 호출 (필수)
  }

  // --- 생명주기 관리 메서드들 -----------------------------------------------------

  /// 녹음기를 안전하게 초기화하는 메서드
  ///
  /// async/await: 비동기 작업을 처리합니다 (권한 요청, 녹음기 초기화 등)
  /// Future<void>: 이 메서드가 완료될 때까지 기다려야 함을 의미합니다
  Future<void> _safeInitRecorder() async {
    try {
      // 1단계: 마이크 권한 요청
      // 사용자가 앱에서 마이크를 사용할 수 있는 권한을 허용했는지 확인
      final granted = await _requestMicrophonePermission();
      if (!granted) {
        // 권한이 없으면 화면이 아직 존재하는지 확인 후 메시지 표시
        if (!mounted) return; // 화면이 이미 사라졌으면 아무것도 하지 않음
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마이크 권한이 필요합니다! 설정에서 허용해주세요.')),
        );
        return; // 권한이 없으면 더 이상 진행하지 않음
      }

      // 2단계: 녹음기 초기화 (이미 열려있으면 건너뜀)
      if (_recorderOpened) return; // 중복 초기화 방지
      await _recorder.openRecorder(); // 녹음기 열기
      _recorderOpened = true; // 초기화 완료 표시

      // 3단계: 코덱 지원 여부 확인 (기기 호환성 체크)
      // AAC(MP4) 코덱을 지원하는지 확인 (더 좋은 음질, 작은 파일 크기)
      final codecOk = await _recorder.isEncoderSupported(Codec.aacMP4);
      if (!codecOk && mounted) {
        // 지원하지 않으면 사용자에게 알림 (WAV 코덱으로 대체됨)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기기에서 AAC(MP4) 코덱을 지원하지 않습니다.')),
        );
      }
    } catch (e) {
      // 오류 발생 시 처리
      if (!mounted) return; // 화면이 사라졌으면 오류 메시지 표시하지 않음
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('녹음 장치 초기화 실패: $e')));
    }
  }

  /// 녹음기를 안전하게 정리하는 메서드
  ///
  /// 화면을 떠날 때 호출되어 메모리 누수를 방지합니다.
  /// dispose 메서드는 async를 직접 사용할 수 없어서 즉시 실행 함수(IIFE)를 사용합니다.
  void _safeDisposeRecorder() {
    // 즉시 실행 함수 (IIFE) - async 작업을 동기적으로 시작
    // () async { ... }(); 형태로 함수를 정의하고 바로 실행
    () async {
      try {
        // 1단계: 녹음 중이면 중지
        if (_recorder.isRecording) {
          await _recorder.stopRecorder();
        }
      } catch (_) {
        // 오류가 발생해도 무시 (화면을 떠나는 중이므로)
      }
      try {
        // 2단계: 녹음기가 열려있으면 닫기
        if (_recorderOpened) {
          await _recorder.closeRecorder();
        }
      } catch (_) {
        // 오류가 발생해도 무시
      }
    }(); // 함수를 즉시 실행
  }

  // --- UI 구성 메서드들 --------------------------------------------------------------------

  /// 화면의 UI를 구성하는 메서드
  ///
  /// Flutter에서 화면을 그리는 핵심 메서드입니다.
  /// 사용자가 보는 모든 UI 요소들이 여기서 정의됩니다.
  @override
  Widget build(BuildContext context) {
    // 테마 정보 가져오기 (색상, 글꼴 등 앱의 디자인 설정)
    final theme = Theme.of(context);
    final cs = theme.colorScheme; // 색상 스키마 (primary, secondary 등)

    return Scaffold(
      // 앱바 (상단 네비게이션 바)
      appBar: AppBar(
        title: const Text('일기 쓰기'), // 앱바 제목
        backgroundColor: cs.inversePrimary, // 앱바 배경색 (테마에서 가져옴)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () => context.go('/'), // 홈 화면으로 이동
          tooltip: '뒤로가기', // 접근성을 위한 툴팁
        ),
      ),
      // 화면 본문 - SafeArea로 상태바 영역을 피해서 배치
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 날짜 표시 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // 카드 내부 여백
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: cs.primary), // 달력 아이콘
                      const SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                      Text(
                        _getTodayDate(), // 오늘 날짜를 가져오는 메서드 호출
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, // 굵은 글씨
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 감정 선택 섹션
              Text(
                '오늘의 감정을 선택해주세요',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8), // 제목과 버튼들 사이 간격
              // 감정 선택 버튼들 (Wrap으로 자동 줄바꿈)
              Wrap(
                spacing: 8, // 가로 간격
                runSpacing: 8, // 세로 간격 (줄바꿈 시)
                children: _emotions.map((emotion) {
                  // 현재 선택된 감정인지 확인
                  final isSelected = _currentEmotion == emotion;
                  return FilterChip(
                    label: Text(
                      emotion,
                      semanticsLabel: '$emotion 선택',
                    ), // 접근성 라벨
                    selected: isSelected, // 선택 상태
                    onSelected: (selected) {
                      // 선택 상태가 변경될 때 호출
                      setState(() => _currentEmotion = selected ? emotion : '');
                      // setState: 화면을 다시 그리도록 알림
                    },
                    selectedColor: cs.primaryContainer, // 선택된 상태의 배경색
                    checkmarkColor: cs.onPrimaryContainer, // 체크마크 색상
                  );
                }).toList(), // map의 결과를 리스트로 변환
              ),
              const SizedBox(height: 24),

              // 본문 입력 + 녹음 기능 영역
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // 자식 위젯들을 가로로 늘림
                      children: [
                        // 섹션 제목
                        Row(
                          children: [
                            Icon(Icons.edit_note, color: cs.primary), // 편집 아이콘
                            const SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                            Text(
                              '오늘 있었던 일을 적어보세요',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // 제목과 녹음 버튼 사이 간격
                        // 녹음 버튼 영역
                        Column(
                          children: [
                            // 녹음 시작/정지 버튼
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _busy
                                        ? null
                                        : _toggleRecording, // busy 상태면 버튼 비활성화
                                    icon: Icon(
                                      _isRecording
                                          ? Icons.stop
                                          : Icons
                                                .mic, // 녹음 중이면 정지 아이콘, 아니면 마이크 아이콘
                                    ),
                                    label: Text(
                                      _isRecording
                                          ? '⏹ 정지'
                                          : '🎙 녹음', // 버튼 텍스트도 상태에 따라 변경
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isRecording
                                          ? Colors
                                                .red // 녹음 중이면 빨간색
                                          : cs.secondary, // 아니면 테마 색상
                                      foregroundColor: Colors.white, // 텍스트 색상
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8), // 버튼들 사이 간격
                            // 업로드 버튼 (녹음 파일이 있을 때만 표시)
                            if (_recordingPath != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _busy
                                          ? null
                                          : _uploadRecording, // busy 상태면 비활성화
                                      icon: const Icon(Icons.upload), // 업로드 아이콘
                                      label: const Text('⬆ 업로드(모킹)'), // 모킹 표시
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange, // 주황색
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            // 녹음 파일 경로 표시 (녹음 파일이 있을 때만 표시)
                            if (_recordingPath != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100, // 연한 회색 배경
                                    borderRadius: BorderRadius.circular(
                                      4,
                                    ), // 둥근 모서리
                                  ),
                                  child: Text(
                                    '파일: $_recordingPath', // 파일 경로 표시
                                    style: theme.textTheme.bodySmall, // 작은 글씨
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16), // 녹음 버튼과 텍스트 입력 사이 간격
                        // 텍스트 입력 필드
                        Expanded(
                          child: TextField(
                            controller: _diaryController, // 텍스트 컨트롤러 연결
                            maxLines: null, // 줄 수 제한 없음
                            expands: true, // 남은 공간을 모두 차지
                            decoration: const InputDecoration(
                              hintText:
                                  '오늘 있었던 일을 자유롭게 적어보세요...\n\n예시:\n- 학교에서 친구와 재미있게 놀았어요\n- 수학 시험을 잘 봤어요\n- 엄마와 함께 맛있는 음식을 먹었어요',
                              border: OutlineInputBorder(), // 테두리 있는 입력 필드
                              alignLabelWithHint: true, // 힌트 텍스트 정렬
                            ),
                            textAlignVertical:
                                TextAlignVertical.top, // 텍스트를 위쪽부터 시작
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // 텍스트 입력과 저장 버튼 사이 간격
              // 저장 버튼
              ElevatedButton(
                onPressed: _saveDiary, // 저장 메서드 호출
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary, // 테마의 주 색상
                  foregroundColor: Colors.white, // 텍스트 색상
                  padding: const EdgeInsets.symmetric(vertical: 16), // 위아래 여백
                ),
                child: const Text(
                  '일기 저장하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ), // 큰 굵은 글씨
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 도우미 메서드들 ---------------------------------------------------------------

  /// 오늘 날짜를 한국어 형식으로 반환하는 메서드
  ///
  /// 예: "2024년 1월 15일"
  String _getTodayDate() {
    final now = DateTime.now(); // 현재 시간 가져오기
    return '${now.year}년 ${now.month}월 ${now.day}일'; // 한국어 형식으로 포맷팅
  }

  /// 마이크 권한을 요청하는 메서드
  ///
  /// 사용자에게 마이크 사용 권한을 요청하고, 허용 여부를 반환합니다.
  /// Future<bool>: 권한 허용 여부를 비동기적으로 반환
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request(); // 권한 요청
    return status == PermissionStatus.granted; // 허용되었는지 확인
  }

  /// 녹음 파일의 저장 경로를 생성하는 메서드
  ///
  /// 앱의 문서 폴더에 타임스탬프가 포함된 고유한 파일명으로 경로를 생성합니다.
  /// 예: "/data/app/.../diary_recording_1705123456789.m4a"
  Future<String> _getRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory(); // 앱 문서 폴더 경로
    final ts = DateTime.now().millisecondsSinceEpoch; // 현재 시간을 밀리초로 변환 (고유한 값)
    return '${directory.path}/diary_recording_$ts.m4a'; // 파일 경로 생성
  }

  /// 녹음 시작/정지를 토글하는 메서드
  ///
  /// 현재 녹음 상태에 따라 녹음을 시작하거나 정지합니다.
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording(); // 녹음 중이면 정지
    } else {
      await _startRecording(); // 녹음 중이 아니면 시작
    }
  }

  /// 녹음을 시작하는 메서드
  ///
  /// 권한 확인, 파일 경로 생성, 코덱 확인 후 녹음을 시작합니다.
  Future<void> _startRecording() async {
    if (_busy) return; // 이미 작업 중이면 무시
    _busy = true; // 작업 시작 표시

    try {
      // 1단계: 권한 체크 (안전상 재확인)
      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        if (!mounted) return; // 화면이 사라졌으면 무시
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('마이크 권한이 필요합니다!')));
        return; // 권한이 없으면 녹음 시작하지 않음
      }

      // 2단계: 녹음 파일 경로 생성
      final path = await _getRecordingPath();

      // 3단계: 코덱 호환성 확인 후 녹음 시작
      final codecOk = await _recorder.isEncoderSupported(
        Codec.aacMP4,
      ); // AAC 코덱 지원 여부
      final codec = codecOk
          ? Codec.aacMP4
          : Codec.pcm16WAV; // 지원하면 AAC, 아니면 WAV

      await _recorder.startRecorder(toFile: path, codec: codec); // 실제 녹음 시작

      // 4단계: UI 상태 업데이트
      if (!mounted) return; // 화면이 사라졌으면 상태 업데이트하지 않음
      setState(() {
        _isRecording = true; // 녹음 중 상태로 변경
        _recordingPath = path; // 파일 경로 저장
      });

      // 5단계: 사용자에게 알림
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🎙 녹음을 시작합니다...')));
    } catch (e) {
      // 오류 발생 시 처리
      if (!mounted) return; // 화면이 사라졌으면 오류 메시지 표시하지 않음
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('녹음 시작 실패: $e')));
    } finally {
      _busy = false; // 작업 완료 표시 (성공/실패 관계없이)
    }
  }

  /// 녹음을 정지하는 메서드
  ///
  /// 현재 진행 중인 녹음을 정지하고 파일을 저장합니다.
  Future<void> _stopRecording() async {
    if (_busy) return; // 이미 작업 중이면 무시
    _busy = true; // 작업 시작 표시

    try {
      // 1단계: 녹음 정지
      await _recorder.stopRecorder(); // 실제 녹음 정지

      // 2단계: UI 상태 업데이트
      if (!mounted) return; // 화면이 사라졌으면 상태 업데이트하지 않음
      setState(() => _isRecording = false); // 녹음 중이 아님 상태로 변경

      // 3단계: 사용자에게 알림
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('⏹ 녹음이 완료되었습니다!')));
    } catch (e) {
      // 오류 발생 시 처리
      if (!mounted) return; // 화면이 사라졌으면 오류 메시지 표시하지 않음
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('녹음 정지 실패: $e')));
    } finally {
      _busy = false; // 작업 완료 표시 (성공/실패 관계없이)
    }
  }

  /// 녹음 파일을 업로드하는 메서드 (현재는 모킹)
  ///
  /// 실제 구현 시에는 서버로 파일을 업로드하고 STT(음성-텍스트 변환)를 수행합니다.
  Future<void> _uploadRecording() async {
    // 1단계: 녹음 파일 존재 확인
    if (_recordingPath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('녹음 파일이 없습니다!')));
      return; // 녹음 파일이 없으면 업로드 불가
    }

    if (_busy) return; // 이미 작업 중이면 무시
    _busy = true; // 작업 시작 표시

    try {
      // 2단계: 파일 시스템에서 파일 존재 확인
      final file = File(_recordingPath!); // 파일 객체 생성
      final exists = await file.exists(); // 파일이 실제로 존재하는지 확인
      if (!exists) {
        if (!mounted) return; // 화면이 사라졌으면 무시
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('녹음 파일을 찾을 수 없습니다!')));
        return; // 파일이 없으면 업로드 불가
      }

      // 3단계: 파일 크기 확인
      final size = await file.length(); // 파일 크기 (바이트 단위)

      // 4단계: 콘솔 로그에 파일 정보 출력
      debugPrint('📁 업로드할 파일 정보:');
      debugPrint('   경로: $_recordingPath');
      debugPrint('   크기: $size bytes');

      // 5단계: 업로드 시작 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⬆ 업로드 중... (모킹)'),
          backgroundColor: Colors.orange, // 주황색 배경
        ),
      );

      // 6단계: 모킹 업로드 시뮬레이션 (실제 업로드 대신 2초 대기)
      await Future.delayed(const Duration(seconds: 2));

      // 7단계: 업로드 완료 알림
      if (!mounted) return; // 화면이 사라졌으면 알림 표시하지 않음
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 업로드 완료! (모킹)  크기: $size bytes'),
          backgroundColor: Colors.green, // 초록색 배경
        ),
      );

      // TODO: 실제 구현 시 추가할 내용들
      // TODO: 실제 Presigned URL PUT 업로드로 교체
      // TODO: 업로드 후 STT 파이프라인 트리거
      // TODO: STT 결과를 텍스트 필드에 자동 입력
    } catch (e) {
      // 오류 발생 시 처리
      if (!mounted) return; // 화면이 사라졌으면 오류 메시지 표시하지 않음
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('업로드 실패: $e')));
    } finally {
      _busy = false; // 작업 완료 표시 (성공/실패 관계없이)
    }
  }

  /// 일기를 저장하는 메서드
  ///
  /// 사용자가 입력한 텍스트와 선택한 감정을 검증하고 저장합니다.
  /// 현재는 모킹으로 성공 메시지만 표시합니다.
  void _saveDiary() {
    // 1단계: 일기 내용 검증
    if (_diaryController.text.trim().isEmpty) {
      // trim(): 앞뒤 공백 제거 후 빈 문자열인지 확인
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('일기 내용을 입력해주세요!')));
      return; // 내용이 없으면 저장하지 않음
    }

    // 2단계: 감정 선택 검증
    if (_currentEmotion.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('오늘의 감정을 선택해주세요!')));
      return; // 감정을 선택하지 않으면 저장하지 않음
    }

    // 3단계: 저장 성공 알림 (현재는 모킹)
    // TODO: 실제 구현 시 추가할 내용들
    // TODO: 일기 저장 로직 (서버 연동)
    // TODO: 감정 분석 결과와 함께 저장
    // TODO: 저장 성공/실패에 따른 처리
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('일기가 저장되었습니다!')));

    // 4단계: 홈 화면으로 이동
    context.go('/'); // go_router를 사용한 화면 이동
  }
}
