import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userInput = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late GenerativeModel model;
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: "AIzaSyDWk3RNJgPcNYDzx-xIYlxgDIgtu-nHTb4",
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final message = _userInput.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final content = [Content.text(message)];
      final responseStream = model.generateContentStream(content);

      String aiResponse = "";
      await for (final chunk in responseStream) {
        setState(() {
          aiResponse += chunk.text ?? "";
        });
      }

      setState(() {
        _messages.add(Message(isUser: false, message: aiResponse, date: DateTime.now()));
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(isUser: false, message: "Error: ${e.toString()}", date: DateTime.now()));
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                child: Text(
                  "No messages yet. Start a conversation!",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return const TypingIndicator();
                  }
                  final message = _messages[index];
                  return Messages(
                    isUser: message.isUser,
                    message: message.message,
                    date: DateFormat('HH:mm').format(message.date),
                  );
                },
              ),
            ),

            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 15,
            child: TextFormField(
              controller: _userInput,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha(50),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withAlpha(100),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                color: Colors.deepPurple,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({super.key, required this.isUser, required this.message, required this.date});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey.shade800,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 16, color: isUser ? Colors.white : Colors.white70),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                date,
                style: TextStyle(fontSize: 10, color: isUser ? Colors.white70 : Colors.white60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(),
            const SizedBox(width: 4),
            _dot(delay: 200),
            const SizedBox(width: 4),
            _dot(delay: 400),
          ],
        ),
      ),
    );
  }

  Widget _dot({int delay = 0}) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
