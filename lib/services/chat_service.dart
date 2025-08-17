import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final String time;
  final String sender;

  ChatMessage({required this.text, required this.time, required this.sender});

  Map<String, String> toMap() {
    return {'text': text, 'time': time, 'sender': sender};
  }

  factory ChatMessage.fromMap(Map<String, String> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      time: map['time'] ?? '',
      sender: map['sender'] ?? '',
    );
  }
}

class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello! How can I help you today?',
      time: '06:43 PM',
      sender: 'support',
    ),
  ];

  bool _isInChatScreen = false;
  final ValueNotifier<int> _unreadCount = ValueNotifier<int>(0);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ValueNotifier<int> get unreadCount => _unreadCount;

  void enterChatScreen() {
    _isInChatScreen = true;
    _markAllAsRead();
  }

  void exitChatScreen() {
    _isInChatScreen = false;
  }

  void _markAllAsRead() {
    _unreadCount.value = 0;
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);

    // If it's a support message and user is not in chat screen, increment unread count
    if (message.sender == 'support' && !_isInChatScreen) {
      _unreadCount.value++;
    }

    notifyListeners();
  }

  void addUserMessage(String text, String time) {
    addMessage(ChatMessage(text: text, time: time, sender: 'user'));
  }

  void addSupportMessage(String text, String time) {
    addMessage(ChatMessage(text: text, time: time, sender: 'support'));
  }

  void clearMessages() {
    _messages.clear();
    _messages.add(
      ChatMessage(
        text: 'Hello! How can I help you today?',
        time: '06:43 PM',
        sender: 'support',
      ),
    );
    notifyListeners();
  }

  int get messageCount => _messages.length;
}
