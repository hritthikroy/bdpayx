import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../widgets/login_popup.dart';
import '../../config/api_config.dart';
import '../../config/supabase_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginAndLoadMessages();
    });
  }

  Future<void> _checkLoginAndLoadMessages() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      await LoginPopup.show(
        context,
        message: 'Login to chat with support',
      );
      return;
    }
    
    await _loadMessages();
    _subscribeToMessages();
  }

  Future<void> _loadMessages() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/messages'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages.clear();
          _messages.addAll(data.map((msg) => {
            'text': msg['message'],
            'isUser': msg['sender_type'] == 'user',
            'time': DateTime.parse(msg['created_at']),
          }).toList());
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  void _subscribeToMessages() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.user == null) return;
    
    // Subscribe to Supabase Realtime for new messages
    SupabaseConfig.client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('user_id', authProvider.user!['id'])
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty && mounted) {
            final latestMsg = data.last;
            setState(() {
              _messages.add({
                'text': latestMsg['message'],
                'isUser': latestMsg['sender_type'] == 'user',
                'time': DateTime.parse(latestMsg['created_at']),
              });
            });
          }
        });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      await LoginPopup.show(context, message: 'Please login to send messages');
      return;
    }

    final messageText = _messageController.text;
    _messageController.clear();
    
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
        body: json.encode({'message': messageText}),
      );

      if (response.statusCode == 200) {
        // Message will be added via Realtime subscription
      } else {
        _showError('Failed to send message');
      }
    } catch (e) {
      _showError('Network error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Support'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Start a conversation', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: message['isUser'] ? const Color(0xFF3B82F6) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color: message['isUser'] ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF3B82F6),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
