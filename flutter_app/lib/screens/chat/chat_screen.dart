import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimController;
  late AnimationController _pulseController;

  // Smart Bot Knowledge Base
  final Map<String, String> _botResponses = {
    'hello': 'Hello! Welcome to BDPayX Support. How can I help you today?',
    'hi': 'Hi there! I\'m your BDPayX assistant. What can I do for you?',
    'help': 'I\'m here to help! You can ask me about:\n\n- Exchange rates\n- Transaction status\n- KYC verification\n- Deposit & Withdrawal\n- Account issues\n\nJust type your question!',
    'exchange rate': 'Our current exchange rate is approximately 70 INR per 100 BDT. Rates are updated every 60 seconds based on market conditions. Check the home screen for live rates!',
    'rate': 'Our current exchange rate is approximately 70 INR per 100 BDT. Rates are updated every 60 seconds. Check the home screen for live rates!',
    'kyc': 'KYC (Know Your Customer) verification is required for higher transaction limits.\n\nRequired documents:\n- National ID / Passport\n- Selfie with ID\n- Address proof\n\nGo to Profile > KYC Verification to complete.',
    'verification': 'KYC verification typically takes 24-48 hours. Make sure your documents are clear and readable. You\'ll receive a notification once verified!',
    'deposit': 'To deposit BDT:\n\n1. Go to Wallet > Deposit\n2. Choose payment method\n3. Enter amount\n4. Complete payment\n5. Upload receipt\n\nDeposits are processed within 5-15 minutes.',
    'withdraw': 'To withdraw INR:\n\n1. Go to Wallet > Withdraw\n2. Enter amount\n3. Select bank account\n4. Confirm withdrawal\n\nWithdrawals are processed within 2-24 hours.',
    'transaction': 'To check your transaction status:\n\n1. Go to Transactions tab\n2. Find your transaction\n3. Tap to see details\n\n[Pending] - Being processed\n[Completed] - Successfully done\n[Failed] - Please contact support',
    'status': 'Transaction statuses:\n\n[Pending] - Being processed\n[Completed] - Successfully done\n[Failed] - Contact support\n\nMost transactions complete within 5-30 minutes.',
    'limit': 'Transaction limits:\n\nWithout KYC:\n- Daily: 10,000 BDT\n- Monthly: 50,000 BDT\n\nWith KYC:\n- Daily: 100,000 BDT\n- Monthly: 500,000 BDT',
    'fee': 'Our fees are transparent:\n\n- Exchange: 0% commission\n- Deposit: Free\n- Withdrawal: 10 INR per transaction\n\nNo hidden charges!',
    'fees': 'Our fees are transparent:\n\n- Exchange: 0% commission\n- Deposit: Free\n- Withdrawal: 10 INR per transaction\n\nNo hidden charges!',
    'time': 'Processing times:\n\n- Deposits: 5-15 minutes\n- Exchange: Instant\n- Withdrawals: 2-24 hours\n- KYC: 24-48 hours',
    'support': 'You can reach us through:\n\n- This chat (24/7)\n- Telegram: @bdpayx_support\n- Email: support@bdpayx.com\n\nWe\'re always here to help!',
    'contact': 'Contact us:\n\n- Live Chat: Available 24/7\n- Telegram: @bdpayx_support\n- Email: support@bdpayx.com',
    'safe': 'Your security is our priority!\n\n- Bank-level encryption\n- 2FA authentication\n- Secure payment gateways\n- Regular security audits',
    'secure': 'Your security is our priority!\n\n- Bank-level encryption\n- 2FA authentication\n- Secure payment gateways',
    'refund': 'Refund policy:\n\n- Failed transactions: Auto-refunded within 24 hours\n- Cancelled orders: Refunded within 48 hours\n- Disputes: Resolved within 7 days',
    'account': 'Account management:\n\n- Profile: Update personal info\n- Security: Change PIN, enable 2FA\n- Bank Cards: Add/remove payment methods\n- KYC: Verify identity',
    'bkash': 'bKash deposits:\n\n1. Select bKash as payment method\n2. Send to our bKash number\n3. Enter transaction ID\n4. Upload screenshot\n\nProcessed within 5-15 minutes!',
    'nagad': 'Nagad deposits:\n\n1. Select Nagad as payment method\n2. Send to our Nagad number\n3. Enter transaction ID\n4. Upload screenshot\n\nProcessed within 5-15 minutes!',
    'thank': 'You\'re welcome! Is there anything else I can help you with?',
    'thanks': 'You\'re welcome! Is there anything else I can help you with?',
    'bye': 'Goodbye! Thank you for using BDPayX. Have a great day!',
    'okay': 'Great! Let me know if you need anything else.',
    'ok': 'Perfect! Feel free to ask if you have more questions.',
  };

  final List<QuickQuestion> _quickQuestions = [
    QuickQuestion('Exchange Rate', Icons.currency_exchange_rounded, const Color(0xFF10B981)),
    QuickQuestion('KYC Process', Icons.verified_user_rounded, const Color(0xFF3B82F6)),
    QuickQuestion('Deposit', Icons.add_card_rounded, const Color(0xFF8B5CF6)),
    QuickQuestion('Withdraw', Icons.account_balance_rounded, const Color(0xFFEC4899)),
    QuickQuestion('Transaction', Icons.receipt_long_rounded, const Color(0xFFF59E0B)),
    QuickQuestion('Fees', Icons.payments_rounded, const Color(0xFF06B6D4)),
    QuickQuestion('Security', Icons.shield_rounded, const Color(0xFF6366F1)),
    QuickQuestion('Support', Icons.headset_mic_rounded, const Color(0xFFEF4444)),
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _addBotMessage('Hello! I\'m your BDPayX Assistant.\n\nHow can I help you today? You can tap the quick options below or type your question.');
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false, time: DateTime.now()));
    });
    _scrollToBottom();
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

  String _getBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase().trim();
    for (final entry in _botResponses.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'I\'m not sure about that.\n\nTry asking about:\n- Exchange rates\n- KYC verification\n- Deposits & Withdrawals\n- Transaction status\n\nOr tap "Support" to connect with our team.';
  }

  Future<void> _sendMessage([String? quickQuestion]) async {
    final text = quickQuestion ?? _messageController.text.trim();
    if (text.isEmpty) return;
    
    HapticFeedback.lightImpact();
    _messageController.clear();
    
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();
    
    await Future.delayed(Duration(milliseconds: 1000 + (text.length * 15)));
    
    final response = _getBotResponse(text);
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: response, isUser: false, time: DateTime.now()));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFEFF6FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: _messages.isEmpty
                    ? _buildWelcomeScreen(isDark)
                    : _buildMessageList(isDark),
              ),
              if (_isTyping) _buildTypingIndicator(isDark),
              _buildQuickQuestions(isDark),
              _buildInputArea(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1 + _pulseController.value * 0.1),
                      blurRadius: 10 + _pulseController.value * 5,
                      spreadRadius: _pulseController.value * 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BDPayX Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online • Ready to help',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
            ),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
    );
  }


  Widget _buildWelcomeScreen(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Animated Bot Avatar
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.all(24 + _pulseController.value * 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.15),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1 + _pulseController.value * 0.1),
                      blurRadius: 30 + _pulseController.value * 10,
                      spreadRadius: _pulseController.value * 5,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 48),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'How can I help you?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'I can answer questions about exchange rates,\ntransactions, KYC, and more!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Feature Cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard('24/7 Support', Icons.access_time_rounded, const Color(0xFF10B981), isDark),
              _buildFeatureCard('Instant Replies', Icons.flash_on_rounded, const Color(0xFFF59E0B), isDark),
              _buildFeatureCard('Smart AI', Icons.psychology_rounded, const Color(0xFF6366F1), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showAvatar = !message.isUser && (index == 0 || _messages[index - 1].isUser);
        final isLastInGroup = index == _messages.length - 1 || 
            _messages[index + 1].isUser != message.isUser;
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(message.isUser ? 20 * (1 - value) : -20 * (1 - value), 0),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: _buildMessageBubble(message, isDark, showAvatar, isLastInGroup),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark, bool showAvatar, bool isLastInGroup) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLastInGroup ? 16 : 4,
        left: message.isUser ? 60 : 0,
        right: message.isUser ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser && showAvatar) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ] else if (!message.isUser) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      )
                    : null,
                color: message.isUser ? null : isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 6),
                  bottomRight: Radius.circular(message.isUser ? 6 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: message.isUser ? Colors.white : isDark ? Colors.white : const Color(0xFF1E293B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.time),
                        style: TextStyle(
                          fontSize: 11,
                          color: message.isUser
                              ? Colors.white.withValues(alpha: 0.7)
                              : isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                      ),
                      if (message.isUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _typingAnimController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final value = ((_typingAnimController.value + delay) % 1.0);
                    final bounce = math.sin(value * math.pi);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      child: Transform.translate(
                        offset: Offset(0, -bounce * 6),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withValues(alpha: 0.4 + bounce * 0.6),
                                const Color(0xFF8B5CF6).withValues(alpha: 0.4 + bounce * 0.6),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Typing...',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestions(bool isDark) {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _quickQuestions.length,
        itemBuilder: (context, index) {
          final q = _quickQuestions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _sendMessage(q.text),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        q.color.withValues(alpha: isDark ? 0.25 : 0.15),
                        q.color.withValues(alpha: isDark ? 0.15 : 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: q.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(q.icon, color: q.color, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        q.text,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: q.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showAttachmentOptions(context, isDark),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.add_rounded,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showAttachmentOptions(BuildContext context, bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share with Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.photo_library_rounded,
                  'Gallery',
                  const Color(0xFF8B5CF6),
                  isDark,
                  () {
                    Navigator.pop(context);
                    _handleAttachment('gallery');
                  },
                ),
                _buildAttachmentOption(
                  Icons.camera_alt_rounded,
                  'Camera',
                  const Color(0xFF3B82F6),
                  isDark,
                  () {
                    Navigator.pop(context);
                    _handleAttachment('camera');
                  },
                ),
                _buildAttachmentOption(
                  Icons.insert_drive_file_rounded,
                  'Document',
                  const Color(0xFF10B981),
                  isDark,
                  () {
                    Navigator.pop(context);
                    _handleAttachment('document');
                  },
                ),
                _buildAttachmentOption(
                  Icons.receipt_long_rounded,
                  'Receipt',
                  const Color(0xFFF59E0B),
                  isDark,
                  () {
                    Navigator.pop(context);
                    _handleAttachment('receipt');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Share screenshots or documents to help us assist you better',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAttachment(String type) {
    // Show a message that this feature is coming soon
    // In a real app, you would use image_picker or file_picker packages
    String message;
    switch (type) {
      case 'gallery':
        message = 'Opening photo gallery...';
        break;
      case 'camera':
        message = 'Opening camera...';
        break;
      case 'document':
        message = 'Opening document picker...';
        break;
      case 'receipt':
        message = 'Opening receipt scanner...';
        break;
      default:
        message = 'Opening attachment picker...';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text('$message\n\nFile sharing will be available soon!'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              Icons.delete_outline_rounded,
              'Clear Chat',
              'Start a fresh conversation',
              const Color(0xFFEF4444),
              isDark,
              () {
                Navigator.pop(context);
                setState(() => _messages.clear());
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              Icons.person_outline_rounded,
              'Talk to Human',
              'Connect with support agent',
              const Color(0xFF6366F1),
              isDark,
              () {
                Navigator.pop(context);
                _addBotMessage('Connecting you to a human agent...\n\nOur support team will be with you shortly.\n\nTelegram: @bdpayx_support\nEmail: support@bdpayx.com');
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle, Color color, bool isDark, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser, required this.time});
}

class QuickQuestion {
  final String text;
  final IconData icon;
  final Color color;
  QuickQuestion(this.text, this.icon, this.color);
}
