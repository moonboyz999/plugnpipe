import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';
import '../../services/chat_service.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chatService.addListener(_onChatUpdate);
    _chatService.enterChatScreen();
  }

  @override
  void dispose() {
    _chatService.removeListener(_onChatUpdate);
    _chatService.exitChatScreen();
    super.dispose();
  }

  void _onChatUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      // Add user message
      _chatService.addUserMessage(text, TimeOfDay.now().format(context));

      setState(() {
        _isLoading = true;
      });

      _controller.clear();

      try {
        // Get AI response
        final response = await GeminiService.getChatResponse(text);

        if (mounted) {
          _chatService.addSupportMessage(
            response,
            TimeOfDay.now().format(context),
          );

          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          _chatService.addSupportMessage(
            'Sorry, I\'m having trouble connecting right now. Please try again later.',
            TimeOfDay.now().format(context),
          );

          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildQuickReplyButton(String text) {
    return OutlinedButton(
      onPressed: () {
        _controller.text = text;
        _sendMessage();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.orange,
        side: const BorderSide(color: Colors.orange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Support Chat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      "We're here to help",
                      style: TextStyle(fontSize: 14, color: Colors.brown),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _chatService.messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _chatService.messages.length && _isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Typing...'),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _chatService.messages[index];
                final isUser = msg.sender == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.orange[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Text(
                          msg.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Quick reply buttons
          if (!_isLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickReplyButton('My fridge is not cooling'),
                    const SizedBox(width: 8),
                    _buildQuickReplyButton('Washing machine won\'t start'),
                    const SizedBox(width: 8),
                    _buildQuickReplyButton('Toilet is clogged'),
                    const SizedBox(width: 8),
                    _buildQuickReplyButton('Outlet not working'),
                    const SizedBox(width: 8),
                    _buildQuickReplyButton('Check booking status'),
                  ],
                ),
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
