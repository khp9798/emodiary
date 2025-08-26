import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// AI 챗봇 화면
///
/// 학생들이 감정을 털어놓을 수 있는 공감형 AI 챗봇과 대화하는 화면
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 초기 메시지 추가
    _messages.add(
      ChatMessage(
        text: '안녕하세요! 저는 여러분의 감정 친구에요. 오늘 하루는 어땠나요?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 친구와 대화하기'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          // 채팅 메시지 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // 메시지 입력 영역
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.psychology, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 사용자 메시지 추가
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });

    _messageController.clear();
    _scrollToBottom();

    // AI 응답 시뮬레이션
    Future.delayed(const Duration(seconds: 1), () {
      _addAIResponse(text);
    });
  }

  void _addAIResponse(String userMessage) {
    String aiResponse = _generateAIResponse(userMessage);

    setState(() {
      _messages.add(
        ChatMessage(text: aiResponse, isUser: false, timestamp: DateTime.now()),
      );
    });

    _scrollToBottom();
  }

  /// AI 응답 생성 (현재는 간단한 키워드 매칭)
  ///
  /// [userMessage] - 사용자 메시지
  /// 실제 구현 시에는 AI API를 사용하여 더 정교한 응답 생성
  String _generateAIResponse(String userMessage) {
    // 간단한 AI 응답 로직 (실제로는 AI API를 사용해야 함)
    if (userMessage.contains('행복') || userMessage.contains('기쁘')) {
      return '와! 행복한 일이 있었군요! 그런 기분을 느낄 수 있어서 정말 좋아요. 더 자세히 들려주세요! 😊';
    } else if (userMessage.contains('슬프') || userMessage.contains('우울')) {
      return '슬픈 일이 있었군요. 그런 감정을 느끼는 것은 자연스러워요. 제가 들어드릴게요. 어떤 일이 있었나요? 🤗';
    } else if (userMessage.contains('화나') || userMessage.contains('짜증')) {
      return '화가 난 일이 있었군요. 그런 감정을 느끼는 것은 당연해요. 어떤 일이 화를 나게 했나요? 😤';
    } else if (userMessage.contains('걱정') || userMessage.contains('불안')) {
      return '걱정되는 일이 있나요? 걱정을 나누면 마음이 조금 나아질 수 있어요. 무엇이 걱정되나요? 🤔';
    } else {
      return '그런 일이 있었군요! 더 자세히 들려주세요. 제가 잘 들어드릴게요! 😊';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

/// 채팅 메시지 데이터 클래스
///
/// 채팅 화면에서 사용되는 메시지 정보를 담는 클래스
class ChatMessage {
  final String text; // 메시지 내용
  final bool isUser; // 사용자 메시지 여부 (true: 사용자, false: AI)
  final DateTime timestamp; // 메시지 전송 시간

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
