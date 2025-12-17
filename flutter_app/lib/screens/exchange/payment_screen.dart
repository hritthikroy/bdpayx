import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';

class PaymentScreen extends StatefulWidget {
  final double fromAmount;
  final double toAmount;
  final double exchangeRate;

  const PaymentScreen({
    super.key,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  // Payment method: 'upi' or 'bank_transfer'
  String _selectedPaymentMethod = 'upi';
  
  // Selected bank account for receiving INR
  Map<String, dynamic>? _selectedBankAccount;
  final List<Map<String, dynamic>> _savedBankAccounts = [];
  
  // UPI details
  String? _upiId;
  
  // Timer state
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(hours: 1);
  bool _canRemind = false;
  bool _reminderSent = false;
  
  // Transaction state
  String _transactionRef = '';
  bool _isSubmitting = false;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _timerPulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _timerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _generateTransactionRef();
    _loadSavedBankAccounts();
    _createTransaction();
    _startCountdownTimer();
    
    // Check for existing pending request after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingPendingRequest();
    });
  }
  
  void _checkExistingPendingRequest() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.hasPendingExchangeRequest) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pending_actions_rounded, color: Color(0xFFF59E0B), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Pending Request', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
          content: const Text(
            'You already have a pending exchange request. Please wait for it to be processed or cancel it from the History section before creating a new one.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Continue anyway - user can have multiple requests
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue Anyway'),
            ),
          ],
        ),
      );
    }
  }

  void _generateTransactionRef() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _transactionRef = 'TXN${timestamp.toString().substring(5)}';
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
          // Enable reminder after 30 minutes (30 minutes remaining)
          if (_remainingTime.inMinutes <= 30 && !_canRemind) {
            _canRemind = true;
            _timerPulseController.repeat(reverse: true);
          }
        });
      } else {
        timer.cancel();
        _showTimeExpiredDialog();
      }
    });
  }

  void _loadSavedBankAccounts() {
    // TODO: Load from API/SharedPreferences
    // Demo data - in production, fetch from backend
    setState(() {
      // Empty initially - user needs to add accounts
      _savedBankAccounts.clear();
    });
  }

  Future<void> _createTransaction() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    await transactionProvider.createTransaction(
      authProvider.token ?? '',
      widget.fromAmount,
      widget.toAmount,
      widget.exchangeRate,
      _selectedPaymentMethod,
    );
  }

  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.timer_off_rounded, color: Color(0xFFDC2626), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Time Expired'),
          ],
        ),
        content: const Text(
          'The payment window has expired. You can remind the admin to process your payment or start a new transaction.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel Transaction'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendReminder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Remind Admin'),
          ),
        ],
      ),
    );
  }

  void _sendReminder() {
    HapticFeedback.mediumImpact();
    setState(() => _reminderSent = true);
    
    // TODO: Send reminder to backend
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Reminder sent to admin! They will process your payment soon.'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _timerPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTimerCard(),
                    const SizedBox(height: 20),
                    _buildTransactionSummary(),
                    const SizedBox(height: 20),
                    _buildReceivingAccountSection(),
                    const SizedBox(height: 20),
                    _buildPaymentMethodSection(),
                    const SizedBox(height: 20),
                    _buildSecurityNotice(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => _showExitConfirmation(),
              ),
              const Expanded(
                child: Text(
                  'Secure Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Security badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Protected',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Transaction Reference
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_rounded, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Ref: $_transactionRef',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _transactionRef));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Reference copied!'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(Icons.copy_rounded, color: Colors.white70, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    final isUrgent = _remainingTime.inMinutes < 10;
    final timerColor = isUrgent ? const Color(0xFFDC2626) : const Color(0xFFF59E0B);
    
    return AnimatedBuilder(
      animation: _timerPulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isUrgent
                  ? [const Color(0xFFFEE2E2), const Color(0xFFFECACA)]
                  : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: timerColor.withValues(alpha: 0.3 + (_canRemind ? 0.2 * _timerPulseController.value : 0)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: timerColor.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: timerColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isUrgent ? Icons.warning_amber_rounded : Icons.timer_rounded,
                      color: timerColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUrgent ? 'Time Running Out!' : 'Payment Window',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUrgent ? const Color(0xFF991B1B) : const Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Admin will process your payment within this time',
                          style: TextStyle(
                            fontSize: 12,
                            color: isUrgent ? const Color(0xFFB91C1C) : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Timer Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeUnit(_remainingTime.inHours.toString().padLeft(2, '0'), 'HRS'),
                    _buildTimeSeparator(),
                    _buildTimeUnit(_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0'), 'MIN'),
                    _buildTimeSeparator(),
                    _buildTimeUnit(_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0'), 'SEC'),
                  ],
                ),
              ),
              // Reminder Button (appears after 30 minutes)
              if (_canRemind) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _reminderSent ? null : _sendReminder,
                    icon: Icon(_reminderSent ? Icons.check_circle_rounded : Icons.notifications_active_rounded),
                    label: Text(_reminderSent ? 'Reminder Sent' : 'Remind Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _reminderSent ? const Color(0xFF10B981) : timerColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    final isUrgent = _remainingTime.inMinutes < 10;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF1E293B),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF64748B),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _remainingTime.inMinutes < 10 ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF6366F1), size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Transaction Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('You Send', '৳${widget.fromAmount.toStringAsFixed(2)}', const Color(0xFFEF4444)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSummaryRow('You Receive', '₹${widget.toAmount.toStringAsFixed(2)}', const Color(0xFF10B981), isHighlight: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSummaryRow('Exchange Rate', '1 BDT = ${widget.exchangeRate.toStringAsFixed(4)} INR', const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 20 : 16,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildReceivingAccountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_rounded, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receiving Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'INR will be sent to this account',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Show linked accounts or add new
          if (_savedBankAccounts.isEmpty && _upiId == null)
            _buildAddAccountPlaceholder()
          else
            _buildLinkedAccounts(),
        ],
      ),
    );
  }

  Widget _buildAddAccountPlaceholder() {
    return GestureDetector(
      onTap: _showAddPaymentMethodSheet,
      child: CustomPaint(
        painter: DottedBorderPainter(
          color: const Color(0xFF6366F1),
          strokeWidth: 2,
          gap: 8,
          radius: 16,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF6366F1),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your UPI ID or Bank Account to receive INR payments',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedAccounts() {
    return Column(
      children: [
        // UPI Account if linked
        if (_upiId != null)
          _buildLinkedAccountCard(
            icon: Icons.qr_code_rounded,
            title: 'UPI',
            subtitle: _upiId!,
            color: const Color(0xFF8B5CF6),
            isSelected: _selectedPaymentMethod == 'upi',
            onTap: () => setState(() => _selectedPaymentMethod = 'upi'),
          ),
        
        // Bank Accounts
        ..._savedBankAccounts.map((account) => Padding(
          padding: EdgeInsets.only(top: _upiId != null || _savedBankAccounts.indexOf(account) > 0 ? 12 : 0),
          child: _buildLinkedAccountCard(
            icon: Icons.account_balance_rounded,
            title: account['bank_name'],
            subtitle: 'A/C: ****${account['account_number'].toString().substring(account['account_number'].toString().length - 4)}',
            color: const Color(0xFF3B82F6),
            isSelected: _selectedBankAccount?['id'] == account['id'],
            isPrimary: account['is_primary'] == true,
            onTap: () => setState(() {
              _selectedBankAccount = account;
              _selectedPaymentMethod = 'bank_transfer';
            }),
          ),
        )),
        
        const SizedBox(height: 16),
        // Add more button
        OutlinedButton.icon(
          onPressed: _showAddPaymentMethodSheet,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Add Another Account'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            side: const BorderSide(color: Color(0xFF6366F1)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedAccountCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Primary',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : const SizedBox(width: 16, height: 16),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payment_rounded, color: Color(0xFF8B5CF6), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How You\'ll Receive Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Choose your preferred method',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // UPI Option
          _buildPaymentMethodOption(
            icon: Icons.qr_code_2_rounded,
            title: 'UPI Payment',
            subtitle: 'Receive via UPI QR code or UPI ID',
            color: const Color(0xFF8B5CF6),
            isSelected: _selectedPaymentMethod == 'upi',
            onTap: () => setState(() => _selectedPaymentMethod = 'upi'),
            features: ['Instant transfer', 'QR code support', 'UPI ID payment'],
          ),
          const SizedBox(height: 12),
          // Bank Transfer Option
          _buildPaymentMethodOption(
            icon: Icons.account_balance_rounded,
            title: 'Bank Transfer',
            subtitle: 'Direct transfer to your bank account',
            color: const Color(0xFF3B82F6),
            isSelected: _selectedPaymentMethod == 'bank_transfer',
            onTap: () => setState(() => _selectedPaymentMethod = 'bank_transfer'),
            features: ['NEFT/IMPS/RTGS', 'All banks supported', 'Secure transfer'],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required List<String> features,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                      : const SizedBox(width: 16, height: 16),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.map((feature) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: color, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        feature,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.1),
            const Color(0xFF059669).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_rounded, color: Color(0xFF059669), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Secure Manual Payment',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSecurityItem(Icons.verified_user_rounded, 'Admin verified payment processing'),
          _buildSecurityItem(Icons.lock_rounded, 'End-to-end encrypted transactions'),
          _buildSecurityItem(Icons.support_agent_rounded, '24/7 support for any issues'),
          _buildSecurityItem(Icons.history_rounded, 'Full transaction history available'),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF065F46)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final hasPaymentMethod = _savedBankAccounts.isNotEmpty || _upiId != null;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasPaymentMethod && !_isSubmitting ? _submitPayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFF94A3B8),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_rounded, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Confirm Payment Request',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ),
        if (!hasPaymentMethod) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please add a payment method to receive your INR',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          hasPaymentMethod
              ? '₹${widget.toAmount.toStringAsFixed(2)} will be sent to your ${_selectedPaymentMethod == 'upi' ? 'UPI' : 'bank account'}'
              : 'Add payment method to proceed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: hasPaymentMethod ? const Color(0xFF10B981) : const Color(0xFF64748B),
            fontWeight: hasPaymentMethod ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _showAddPaymentMethodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how you want to receive your INR',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            // UPI Option
            _buildAddMethodOption(
              icon: Icons.qr_code_2_rounded,
              title: 'Add UPI ID',
              subtitle: 'Receive via UPI QR code or ID',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.pop(context);
                _showAddUpiDialog();
              },
            ),
            const SizedBox(height: 12),
            // Bank Account Option
            _buildAddMethodOption(
              icon: Icons.account_balance_rounded,
              title: 'Add Bank Account',
              subtitle: 'Direct bank transfer (NEFT/IMPS)',
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.pop(context);
                _showAddBankAccountDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMethodOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  void _showAddUpiDialog() {
    final upiController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF8B5CF6), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Add UPI ID'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your UPI ID to receive payments',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: upiController,
              decoration: InputDecoration(
                labelText: 'UPI ID',
                hintText: 'yourname@upi',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Admin will send INR directly to this UPI ID',
                      style: TextStyle(fontSize: 12, color: Color(0xFF065F46)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (upiController.text.isNotEmpty && upiController.text.contains('@')) {
                setState(() {
                  _upiId = upiController.text;
                  _selectedPaymentMethod = 'upi';
                });
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('UPI ID added successfully!'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a valid UPI ID'),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add UPI'),
          ),
        ],
      ),
    );
  }

  void _showAddBankAccountDialog() {
    final nameController = TextEditingController();
    final bankController = TextEditingController();
    final accountController = TextEditingController();
    final ifscController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_rounded, color: Color(0xFF3B82F6), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Add Bank Account'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add your Indian bank account to receive INR',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
                  prefixIcon: const Icon(Icons.person_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bankController,
                decoration: InputDecoration(
                  labelText: 'Bank Name',
                  hintText: 'e.g., HDFC Bank, ICICI Bank',
                  prefixIcon: const Icon(Icons.account_balance_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  prefixIcon: const Icon(Icons.numbers_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ifscController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'IFSC Code',
                  hintText: 'e.g., HDFC0001234',
                  prefixIcon: const Icon(Icons.code_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  bankController.text.isNotEmpty &&
                  accountController.text.isNotEmpty &&
                  ifscController.text.isNotEmpty) {
                final newAccount = {
                  'id': _savedBankAccounts.length + 1,
                  'account_holder_name': nameController.text,
                  'bank_name': bankController.text,
                  'account_number': accountController.text,
                  'ifsc_code': ifscController.text.toUpperCase(),
                  'is_primary': _savedBankAccounts.isEmpty,
                };
                setState(() {
                  _savedBankAccounts.add(newAccount);
                  _selectedBankAccount = newAccount;
                  _selectedPaymentMethod = 'bank_transfer';
                });
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Bank account added successfully!'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please fill all fields'),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Account'),
          ),
        ],
      ),
    );
  }

  void _submitPayment() {
    HapticFeedback.heavyImpact();
    setState(() => _isSubmitting = true);
    
    // Create exchange request in AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    authProvider.createExchangeRequest(
      transactionRef: _transactionRef,
      fromAmount: widget.fromAmount,
      toAmount: widget.toAmount,
      exchangeRate: widget.exchangeRate,
      paymentMethod: _selectedPaymentMethod,
      upiId: _upiId,
      bankAccount: _selectedBankAccount,
    );
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Request Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Admin will process your payment within 1 hour. You\'ll receive ₹${widget.toAmount.toStringAsFixed(2)} to your ${_selectedPaymentMethod == 'upi' ? 'UPI ID' : 'bank account'}.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSuccessDetailRow('Reference', _transactionRef),
                  const SizedBox(height: 8),
                  _buildSuccessDetailRow('Amount', '₹${widget.toAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildSuccessDetailRow('Status', 'Processing', valueColor: const Color(0xFFF59E0B)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // Navigate to transactions/history tab
                  // The main navigation will handle this
                },
                child: const Text(
                  'View in Transaction History',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel this payment? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Payment'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for dotted border
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    this.radius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    if (radius > 0) {
      path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));
    } else {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    // Create dashed path
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();
    
    for (final metric in pathMetrics) {
      double distance = 0;
      bool draw = true;
      
      while (distance < metric.length) {
        final length = draw ? gap : gap;
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
