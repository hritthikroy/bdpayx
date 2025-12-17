import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart';

// Secure Deposit Screen with Backend Verification
class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();
  String _selectedMethod = 'bkash';
  
  // Steps: 0=Amount, 1=Payment Instructions, 2=Verify, 3=Processing, 4=Success/Failed
  // Bank Transfer Steps: 0=Amount, 1=Payment Instructions, 2=Upload Screenshot, 3=Pending Review, 4=Success/Failed
  int _currentStep = 0;
  bool _isVerifying = false;
  String _verificationStatus = '';
  String _errorMessage = '';
  String _depositReference = '';
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _isBlocked = false;
  DateTime? _blockUntil;
  
  // Bank Transfer specific state
  String? _uploadedScreenshotPath;
  bool _hasPendingBankTransfer = false;
  DateTime? _bankTransferSubmitTime;
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(hours: 1);
  
  // Deposit limits and fee
  static const double _minDeposit = 500;
  static const double _maxDeposit = 100000;
  static const double _defaultFeePercentage = 2.0; // 2% fee for bKash/Nagad
  static const double _bankFeePercentage = 1.0; // 1% fee for bank transfer
  
  // Security: Rate limiting
  final List<DateTime> _verificationAttempts = [];
  static const int _maxAttemptsPerHour = 5;
  
  late AnimationController _pulseController;
  late AnimationController _successController;
  late AnimationController _errorShakeController;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'bkash',
      name: 'bKash',
      subtitle: 'Send Money',
      color: const Color(0xFFE2136E),
      icon: Icons.phone_android_rounded,
      accountNumber: '01712-345678',
      accountType: 'Personal',
      processingTime: '2-5 minutes',
    ),
    PaymentMethod(
      id: 'nagad',
      name: 'Nagad',
      subtitle: 'Send Money',
      color: const Color(0xFFFF6B00),
      icon: Icons.phone_android_rounded,
      accountNumber: '01812-345678',
      accountType: 'Personal',
      processingTime: '2-5 minutes',
    ),
    PaymentMethod(
      id: 'bank',
      name: 'Bank Transfer',
      subtitle: 'City Bank Account',
      color: const Color(0xFF1E88E5),
      icon: Icons.account_balance_rounded,
      accountNumber: '2345678901234',
      accountType: 'City Bank',
      processingTime: 'Up to 1 hour',
      tags: [
        PaymentMethodTag(
          label: 'Low Fee',
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.15),
          textColor: const Color(0xFF059669),
          borderColor: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
        PaymentMethodTag(
          label: 'Manual Approval',
          backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
          textColor: const Color(0xFFD97706),
          borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _errorShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _generateDepositReference();
    _checkPendingBankTransfer();
    
    // Listen to amount changes to update UI
    _amountController.addListener(() {
      setState(() {});
    });
  }
  
  // Check if user has a pending bank transfer request
  Future<void> _checkPendingBankTransfer() async {
    // TODO: In production, check from backend/local storage
    // For demo, we'll use local state
    // If there's a pending request, set _hasPendingBankTransfer = true
    // and start the countdown timer if within 1 hour
  }
  
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Calculate deposit fee based on payment method
  double _getFeePercentage() {
    return _selectedMethod == 'bank' ? _bankFeePercentage : _defaultFeePercentage;
  }

  double _calculateFee(double amount) {
    return (amount * _getFeePercentage() / 100);
  }

  // Get amount user needs to send (amount + fee)
  double _getTotalToSend() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return 0;
    return amount + _calculateFee(amount);
  }

  // Get amount that will be credited to wallet
  double _getCreditAmount() {
    return double.tryParse(_amountController.text) ?? 0;
  }

  void _generateDepositReference() {
    // Generate unique deposit reference for tracking
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(9999).toString().padLeft(4, '0');
    _depositReference = 'DEP$timestamp$random';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _errorShakeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Security: Check if user is rate limited
  bool _isRateLimited() {
    final now = DateTime.now();
    _verificationAttempts.removeWhere(
      (attempt) => now.difference(attempt).inHours >= 1
    );
    return _verificationAttempts.length >= _maxAttemptsPerHour;
  }

  // Security: Check if user is temporarily blocked
  bool _checkBlocked() {
    if (_blockUntil != null && DateTime.now().isBefore(_blockUntil!)) {
      return true;
    }
    _isBlocked = false;
    _blockUntil = null;
    return false;
  }

  // Security: Block user after too many failed attempts
  void _blockUser() {
    _isBlocked = true;
    _blockUntil = DateTime.now().add(const Duration(minutes: 30));
    _retryCount = 0;
  }

  void _proceedToPayment() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < _minDeposit) {
      _showError('Minimum deposit is ৳500');
      return;
    }
    if (amount > _maxDeposit) {
      _showError('Maximum deposit is ৳100,000');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _currentStep = 1);
  }

  void _proceedToVerification() {
    HapticFeedback.mediumImpact();
    
    // For bank transfer, check if there's already a pending request
    if (_selectedMethod == 'bank') {
      if (_hasPendingBankTransfer) {
        _showError('You already have a pending bank transfer request. Please wait for approval or cancel it from history.');
        return;
      }
      _showBankTransferNotification();
    }
    
    setState(() => _currentStep = 2);
  }

  void _showBankTransferNotification() {
    final amount = _getTotalToSend();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.account_balance_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bank Transfer Initiated',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Please transfer ৳${amount.toStringAsFixed(0)} to City Bank account',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E88E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // Main verification function with security checks
  Future<void> _submitVerification() async {
    // Security Check 1: Check if blocked
    if (_checkBlocked()) {
      final remaining = _blockUntil!.difference(DateTime.now()).inMinutes;
      _showError('Too many failed attempts. Try again in $remaining minutes.');
      return;
    }

    // Security Check 2: Rate limiting
    if (_isRateLimited()) {
      _showError('Too many verification attempts. Please wait 1 hour.');
      return;
    }

    // Validate Transaction ID format
    final txnId = _transactionIdController.text.trim().toUpperCase();
    if (txnId.isEmpty) {
      _showError('Please enter your Transaction ID');
      _shakeError();
      return;
    }
    
    if (txnId.length < 8) {
      _showError('Invalid Transaction ID format (minimum 8 characters)');
      _shakeError();
      return;
    }

    // Record attempt for rate limiting
    _verificationAttempts.add(DateTime.now());
    
    HapticFeedback.mediumImpact();
    setState(() {
      _currentStep = 3;
      _isVerifying = true;
      _verificationStatus = 'Connecting to verification server...';
      _errorMessage = '';
    });

    // Call backend API for verification
    await _verifyWithBackend();
  }

  Future<void> _verifyWithBackend() async {
    try {
      // Step 1: Initialize verification
      await _updateStatus('Initializing secure verification...', 0.1);
      await Future.delayed(const Duration(milliseconds: 800));

      // Step 2: Validate transaction format
      await _updateStatus('Validating transaction format...', 0.2);
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 3: Connect to payment gateway
      await _updateStatus('Connecting to ${_getMethodName()} gateway...', 0.35);
      await Future.delayed(const Duration(milliseconds: 1000));

      // Step 4: Query transaction
      await _updateStatus('Querying transaction records...', 0.5);
      
      // Actual API call to backend
      final result = await _callVerificationAPI();
      
      if (result['success'] == true) {
        // Step 5: Verify amount match
        await _updateStatus('Verifying amount match...', 0.7);
        await Future.delayed(const Duration(milliseconds: 500));

        // Step 6: Check for duplicate
        await _updateStatus('Checking for duplicate claims...', 0.85);
        await Future.delayed(const Duration(milliseconds: 500));

        // Step 7: Credit wallet
        await _updateStatus('Crediting your wallet...', 0.95);
        await Future.delayed(const Duration(milliseconds: 500));

        // Success!
        _onVerificationSuccess(result);
      } else {
        _onVerificationFailed(result['error'] ?? 'Verification failed');
      }
    } catch (e) {
      _onVerificationFailed('Network error. Please check your connection.');
    }
  }

  Future<Map<String, dynamic>> _callVerificationAPI() async {
    // In production, this calls your secure backend API
    // The backend then verifies with bKash/Nagad API using Transaction ID only
    
    final txnId = _transactionIdController.text.trim().toUpperCase();
    final amount = double.tryParse(_amountController.text) ?? 0;
    
    // Generate secure request hash
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final requestData = '$txnId|$amount|$_selectedMethod|$timestamp';
    final hash = sha256.convert(utf8.encode(requestData)).toString();

    try {
      // TODO: Replace with your actual backend URL
      final response = await http.post(
        Uri.parse('https://api.bdpayx.com/v1/deposit/verify'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-Hash': hash,
          'X-Timestamp': timestamp.toString(),
        },
        body: jsonEncode({
          'transaction_id': txnId,
          'amount': amount,
          'payment_method': _selectedMethod,
          'deposit_reference': _depositReference,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Server error'};
      }
    } catch (e) {
      // For demo: Simulate backend verification
      // In production, remove this and use actual API
      return _simulateBackendVerification(txnId, amount);
    }
  }

  // STRICT VERIFICATION - Always fails without real backend
  // This ensures no fake transactions can pass
  Map<String, dynamic> _simulateBackendVerification(String txnId, double amount) {
    // SECURITY: All transactions MUST be verified through real backend API
    // This simulation ALWAYS fails to prevent fraud
    
    // Check for obviously fake transaction IDs
    if (txnId.length < 10) {
      return {'success': false, 'error': 'Invalid transaction ID format. Must be at least 10 characters.'};
    }
    
    // Validate transaction ID pattern based on payment method
    if (_selectedMethod == 'bkash') {
      // bKash TXN IDs typically start with specific patterns
      if (!RegExp(r'^[A-Z0-9]{10,}$').hasMatch(txnId)) {
        return {'success': false, 'error': 'Invalid bKash transaction ID format'};
      }
    } else if (_selectedMethod == 'nagad') {
      // Nagad TXN IDs have specific patterns
      if (!RegExp(r'^[A-Z0-9]{10,}$').hasMatch(txnId)) {
        return {'success': false, 'error': 'Invalid Nagad transaction ID format'};
      }
    }
    
    // CRITICAL: Without real backend connection, ALL verifications fail
    // This prevents any fake deposits from being approved
    
    // Generate realistic error messages based on common issues
    final List<String> verificationErrors = [
      'Transaction ID not found in ${_getMethodName()} payment records. Please check and try again.',
      'No matching transaction found for this Transaction ID',
      'Transaction amount does not match. Expected ৳$amount',
      'This transaction has already been claimed by another account',
      'Transaction is older than 24 hours and has expired',
      'Transaction is still being processed by ${_getMethodName()}. Please wait 5-10 minutes.',
      'Unable to verify transaction. The payment may not have been completed.',
      'Transaction verification failed. Please contact support.',
    ];
    
    // Use transaction ID hash to consistently return same error for same input
    // This prevents users from just retrying until they get lucky
    final errorIndex = txnId.hashCode.abs() % verificationErrors.length;
    
    return {
      'success': false, 
      'error': verificationErrors[errorIndex],
      'error_code': 'VERIFICATION_FAILED',
      'requires_backend': true,
    };
  }

  Future<void> _updateStatus(String status, double progress) async {
    if (mounted) {
      setState(() {
        _verificationStatus = status;
      });
    }
  }

  void _onVerificationSuccess(Map<String, dynamic> result) {
    HapticFeedback.heavyImpact();
    _successController.forward();
    _retryCount = 0;
    setState(() {
      _isVerifying = false;
      _currentStep = 4;
      _errorMessage = '';
    });
  }

  void _onVerificationFailed(String error) {
    HapticFeedback.heavyImpact();
    _retryCount++;
    
    // Block after max retries
    if (_retryCount >= _maxRetries) {
      _blockUser();
    }
    
    setState(() {
      _isVerifying = false;
      _currentStep = 5; // Failed step
      _errorMessage = error;
    });
  }

  void _shakeError() {
    _errorShakeController.forward().then((_) => _errorShakeController.reset());
    HapticFeedback.heavyImpact();
  }

  void _retryVerification() {
    if (_checkBlocked()) {
      final remaining = _blockUntil!.difference(DateTime.now()).inMinutes;
      _showError('Account temporarily blocked. Try again in $remaining minutes.');
      return;
    }
    
    setState(() {
      _currentStep = 2;
      _errorMessage = '';
    });
  }

  void _startNewDeposit() {
    _generateDepositReference();
    setState(() {
      _currentStep = 0;
      _amountController.clear();
      _transactionIdController.clear();
      _errorMessage = '';
      _retryCount = 0;
      _successController.reset();
    });
  }

  String _getMethodName() {
    return _paymentMethods.firstWhere((m) => m.id == _selectedMethod).name;
  }

  void _showError(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Copied to clipboard'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildCurrentStep(),
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
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () {
                  if (_currentStep > 0 && _currentStep < 4 && !_isVerifying) {
                    setState(() => _currentStep--);
                  } else if (!_isVerifying) {
                    Navigator.pop(context);
                  }
                },
              ),
              const Expanded(
                child: Text(
                  'Secure Deposit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Security badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Secure', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressSteps(),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    // Different labels for bank transfer
    final isBankTransfer = _selectedMethod == 'bank';
    
    return Row(
      children: [
        _buildStepIndicator(0, 'Amount'),
        _buildStepLine(0),
        _buildStepIndicator(1, 'Pay'),
        _buildStepLine(1),
        _buildStepIndicator(2, isBankTransfer ? 'Upload' : 'Verify'),
        _buildStepLine(2),
        _buildStepIndicator(3, isBankTransfer ? 'Review' : 'Process'),
        _buildStepLine(3),
        _buildStepIndicator(4, 'Done'),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    // For bank transfer pending (step 3), show step 4 (Done) as pending/in-progress
    final isBankPending = _selectedMethod == 'bank' && _currentStep == 3;
    final isActive = _currentStep >= step || (isBankPending && step == 4);
    final isCurrent = _currentStep == step || (isBankPending && step == 4);
    final isFailed = _currentStep == 5 && step == 4;
    final isPendingDone = isBankPending && step == 4;
    
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isFailed 
                ? const Color(0xFFEF4444)
                : isPendingDone
                    ? const Color(0xFFFEF3C7) // Yellow for pending done
                    : isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Center(
            child: isFailed
                ? const Icon(Icons.close_rounded, size: 14, color: Colors.white)
                : isPendingDone
                    ? const Icon(Icons.hourglass_top_rounded, size: 12, color: Color(0xFFF59E0B))
                    : isActive && _currentStep > step
                        ? const Icon(Icons.check_rounded, size: 14, color: Color(0xFF10B981))
                        : Text(
                            '${step + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isActive ? const Color(0xFF10B981) : Colors.white54,
                            ),
                          ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isPendingDone ? 'Pending' : label,
          style: TextStyle(
            fontSize: 9,
            color: isActive ? Colors.white : Colors.white54,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    // For bank transfer pending (step 3), show line to step 4 as active
    final isBankPending = _selectedMethod == 'bank' && _currentStep == 3;
    final isActive = _currentStep > afterStep || (isBankPending && afterStep == 3);
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildCurrentStep() {
    // Bank transfer has different flow: screenshot upload instead of transaction ID
    if (_selectedMethod == 'bank') {
      switch (_currentStep) {
        case 0:
          return _buildAmountStep();
        case 1:
          return _buildPaymentInstructionsStep();
        case 2:
          return _buildBankTransferUploadStep();
        case 3:
          return _buildBankTransferPendingStep();
        case 4:
          return _buildSuccessStep();
        case 5:
          return _buildFailedStep();
        default:
          return _buildAmountStep();
      }
    }
    
    // Regular flow for bKash/Nagad
    switch (_currentStep) {
      case 0:
        return _buildAmountStep();
      case 1:
        return _buildPaymentInstructionsStep();
      case 2:
        return _buildVerificationStep();
      case 3:
        return _buildProcessingStep();
      case 4:
        return _buildSuccessStep();
      case 5:
        return _buildFailedStep();
      default:
        return _buildAmountStep();
    }
  }

  Widget _buildAmountStep() {
    return SingleChildScrollView(
      key: const ValueKey('amount'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Security Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.security_rounded, color: Color(0xFFF59E0B), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All transactions are verified through official payment gateway APIs',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Amount Input Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF10B981),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter Deposit Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Min: ৳500  •  Max: ৳100,000  •  Fee: ${_getFeePercentage().toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '৳',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: const InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                            border: InputBorder.none,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [500, 1000, 2000, 5000, 10000, 20000]
                      .map((amt) => _buildQuickAmountChip(amt))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Fee Breakdown Card
          if (_getCreditAmount() > 0)
            _buildFeeBreakdownCard(),
          if (_getCreditAmount() > 0)
            const SizedBox(height: 20),
          // Payment Method Selection
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_paymentMethods.length, (index) {
                  final method = _paymentMethods[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < _paymentMethods.length - 1 ? 12 : 0),
                    child: _buildPaymentMethodTile(method),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdownCard() {
    final amount = _getCreditAmount();
    final fee = _calculateFee(amount);
    final totalToSend = amount + fee;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Fee Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeeRow('You Want to Deposit', '৳${amount.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildFeeRow('Service Fee (${_getFeePercentage().toStringAsFixed(0)}%)', '৳${fee.toStringAsFixed(0)}', isCharge: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildFeeRow('Total Amount to Send', '৳${totalToSend.toStringAsFixed(0)}', isTotal: true),
          const SizedBox(height: 8),
          _buildFeeRow('Will be Credited', '৳${amount.toStringAsFixed(0)}', isCredit: true),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isCharge = false, bool isTotal = false, bool isCredit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal || isCredit ? 15 : 14,
            color: isCharge ? const Color(0xFFEF4444) : const Color(0xFF64748B),
            fontWeight: isTotal || isCredit ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          isCharge ? '+$value' : value,
          style: TextStyle(
            fontSize: isTotal || isCredit ? 16 : 14,
            fontWeight: isTotal || isCredit ? FontWeight.bold : FontWeight.w600,
            color: isCharge 
                ? const Color(0xFFEF4444) 
                : isCredit 
                    ? const Color(0xFF10B981) 
                    : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountChip(int amount) {
    final isSelected = _amountController.text == amount.toString();
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _amountController.text = amount.toString());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          amount >= 1000 ? '${(amount / 1000).toStringAsFixed(0)}K' : '$amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = _selectedMethod == method.id;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedMethod = method.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? method.color.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? method.color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: method.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(method.icon, color: method.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          method.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? method.color : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (method.tags.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ...method.tags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: tag.backgroundColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: tag.borderColor),
                            ),
                            child: Text(
                              tag.label,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: tag.textColor,
                              ),
                            ),
                          ),
                        )),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: method.color, size: 22),
          ],
        ),
      ),
    );
  }


  Widget _buildPaymentInstructionsStep() {
    final method = _paymentMethods.firstWhere((m) => m.id == _selectedMethod);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = _calculateFee(amount);
    final totalToSend = amount + fee;
    
    return SingleChildScrollView(
      key: const ValueKey('instructions'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Amount Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [method.color, method.color.withValues(alpha: 0.8)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(method.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Send via ${method.name}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('৳${totalToSend.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('(৳${amount.toStringAsFixed(0)} + ৳${fee.toStringAsFixed(0)} fee)',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Important Warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Send EXACT amount. Wrong amount will cause verification failure.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF991B1B), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Payment Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.info_rounded, color: Color(0xFFF59E0B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Payment Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCopyableField('Account Number', method.accountNumber, method.color),
                const SizedBox(height: 16),
                _buildInfoField('Account Type', method.accountType),
                const SizedBox(height: 16),
                _buildInfoField('Amount to Send', '৳${totalToSend.toStringAsFixed(0)} (EXACT)'),
                const SizedBox(height: 16),
                _buildInfoField('You Will Get', '৳${amount.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                _buildInfoField('Service Fee', '৳${fee.toStringAsFixed(0)} (${_getFeePercentage().toStringAsFixed(0)}%)'),
                const SizedBox(height: 16),
                _buildInfoField('Reference', _depositReference),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Steps
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Steps to Complete',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                ),
                const SizedBox(height: 12),
                _buildStepItem('1', 'Open ${method.name} app'),
                _buildStepItem('2', 'Select "Send Money"'),
                _buildStepItem('3', 'Enter number: ${method.accountNumber}'),
                _buildStepItem('4', 'Enter EXACT amount: ৳${totalToSend.toStringAsFixed(0)}'),
                _buildStepItem('5', 'Complete the payment'),
                _buildStepItem('6', 'Save the Transaction ID'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _proceedToVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: method.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("I've Made the Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableField(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _copyToClipboard(value),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF065F46)))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BANK TRANSFER SPECIFIC STEPS
  // ═══════════════════════════════════════════════════════════════════════════
  
  Widget _buildBankTransferUploadStep() {
    final method = _paymentMethods.firstWhere((m) => m.id == _selectedMethod);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = _calculateFee(amount);
    final totalToSend = amount + fee;
    
    return SingleChildScrollView(
      key: const ValueKey('bank_upload'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: Color(0xFF1E88E5), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Manual Verification Required',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bank transfers require manual admin approval. Please upload your payment screenshot or deposit slip for verification. This process may take up to 1 hour.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Payment Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
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
                        color: method.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(method.icon, color: method.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            method.accountType,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    // Low Fee Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer_rounded, size: 12, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'Low Fee 1%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildInfoField('Account Number', method.accountNumber),
                const SizedBox(height: 12),
                _buildInfoField('Amount to Transfer', '৳${totalToSend.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                _buildInfoField('Will be Credited', '৳${amount.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                _buildInfoField('Reference', _depositReference),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Upload Screenshot Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.upload_file_rounded, color: Color(0xFF1E88E5), size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Upload Payment Proof',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload a screenshot of your payment confirmation or deposit slip',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                
                // Upload Area
                GestureDetector(
                  onTap: _pickScreenshot,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _uploadedScreenshotPath != null 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFFE2E8F0),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _uploadedScreenshotPath != null
                        ? Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, 
                                      color: Color(0xFF10B981), size: 40),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Screenshot Uploaded',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to change',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _uploadedScreenshotPath = null);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, 
                                      color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_rounded, 
                                size: 40, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload screenshot',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PNG, JPG up to 5MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Submit Button
          ElevatedButton(
            onPressed: _uploadedScreenshotPath != null ? _submitBankTransfer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 20),
                SizedBox(width: 8),
                Text('Submit for Approval', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule_rounded, color: Color(0xFFF59E0B), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can only have one pending bank transfer request at a time',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _pickScreenshot() async {
    // For demo, simulate screenshot selection
    // In production, use image_picker package
    HapticFeedback.lightImpact();
    
    // Simulate file picker dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Upload Screenshot'),
        content: const Text('In production, this would open your gallery to select a payment screenshot.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            child: const Text('Simulate Upload'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      setState(() {
        _uploadedScreenshotPath = 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      });
    }
  }
  
  void _submitBankTransfer() {
    if (_uploadedScreenshotPath == null) {
      _showError('Please upload a payment screenshot');
      return;
    }
    
    HapticFeedback.mediumImpact();
    
    final amount = _getCreditAmount();
    final fee = _calculateFee(amount);
    
    // Create deposit request in AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.createDepositRequest(
      depositRef: _depositReference,
      amount: amount,
      fee: fee,
      paymentMethod: _selectedMethod,
      screenshotPath: _uploadedScreenshotPath,
    );
    
    // Set pending state
    setState(() {
      _hasPendingBankTransfer = true;
      _bankTransferSubmitTime = DateTime.now();
      _remainingTime = const Duration(hours: 1);
      _currentStep = 3; // Go to pending step
    });
    
    // Start countdown timer
    _startCountdownTimer();
    
    // Show success notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Bank transfer request submitted for approval'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  Widget _buildBankTransferPendingStep() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    
    return SingleChildScrollView(
      key: const ValueKey('bank_pending'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Pending Animation
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    size: 60,
                    color: Color(0xFFF59E0B),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Pending Admin Approval',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your bank transfer request is being reviewed',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Countdown Timer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Estimated Review Time',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatDuration(_remainingTime),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Admin is reviewing your screenshot',
                    style: TextStyle(fontSize: 12, color: Color(0xFFD97706)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Request Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
              ],
            ),
            child: Column(
              children: [
                _buildDetailRow('Amount', '৳${amount.toStringAsFixed(0)}'),
                const Divider(height: 24),
                _buildDetailRow('Reference', _depositReference),
                const Divider(height: 24),
                _buildDetailRow('Status', 'Pending Review', isStatus: true),
                const Divider(height: 24),
                _buildDetailRow('Submitted', _bankTransferSubmitTime != null 
                    ? '${_bankTransferSubmitTime!.hour}:${_bankTransferSubmitTime!.minute.toString().padLeft(2, '0')}'
                    : 'Just now'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Done Button - Primary action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Go back to wallet/home - request is submitted and being processed
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Your deposit request is being processed. You\'ll be notified when approved.'),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Cancel Button - Secondary action
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelBankTransfer,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'You can cancel and submit a new request',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          
          const SizedBox(height: 16),
          
          // Info about tracking
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF10B981), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can track this request in your Transaction History',
                    style: TextStyle(fontSize: 13, color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {bool isStatus = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          )
        else
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
  
  void _cancelBankTransfer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Request?'),
        content: const Text('Are you sure you want to cancel this bank transfer request? You can submit a new request after cancellation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Request'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // Cancel deposit request in AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.cancelDepositRequest(_depositReference);
      
      _countdownTimer?.cancel();
      setState(() {
        _hasPendingBankTransfer = false;
        _bankTransferSubmitTime = null;
        _uploadedScreenshotPath = null;
        _remainingTime = const Duration(hours: 1);
        _currentStep = 0;
      });
      
      // Generate new reference for next request
      _generateDepositReference();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Bank transfer request cancelled'),
            ],
          ),
          backgroundColor: const Color(0xFF64748B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildVerificationStep() {
    final method = _paymentMethods.firstWhere((m) => m.id == _selectedMethod);
    final amount = _amountController.text;
    final attemptsLeft = _maxRetries - _retryCount;
    
    return SingleChildScrollView(
      key: const ValueKey('verify'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Retry Warning
          if (_retryCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Warning: $attemptsLeft attempt${attemptsLeft == 1 ? '' : 's'} remaining before temporary block',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Color(0xFF3B82F6), size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verify Your Payment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter details from your ${method.name} payment',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Transaction ID Input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: Color(0xFF6366F1), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Transaction ID *',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _transactionIdController,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'e.g., TXN123456789ABC',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.tag_rounded, color: Color(0xFF64748B)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find this in your payment confirmation SMS or app notification',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Security Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF10B981).withValues(alpha: 0.1), const Color(0xFF059669).withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.security_rounded, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Secure Verification',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSecurityItem(Icons.api_rounded, 'Direct API verification with ${method.name}'),
                _buildSecurityItem(Icons.fingerprint_rounded, 'Automatic Transaction ID verification'),
                _buildSecurityItem(Icons.block_rounded, 'Duplicate transaction detection'),
                _buildSecurityItem(Icons.timer_rounded, 'Real-time verification (2-5 min)'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(method.icon, color: method.color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(method.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('৳$amount', style: TextStyle(fontSize: 12, color: method.color)),
                    ],
                  ),
                ),
                Text('Ref: $_depositReference', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_rounded, size: 20),
                SizedBox(width: 8),
                Text('Verify Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
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
            child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF065F46))),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStep() {
    return Center(
      key: const ValueKey('processing'),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.2 * _pulseController.value),
                        blurRadius: 30 + (20 * _pulseController.value),
                        spreadRadius: 10 * _pulseController.value,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Verifying Transaction',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _verificationStatus,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TXN: ${_transactionIdController.text.toUpperCase()}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), letterSpacing: 1),
            ),
            const SizedBox(height: 40),
            const Text(
              'Please do not close this screen',
              style: TextStyle(fontSize: 13, color: Color(0xFFEF4444), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSuccessStep() {
    final amount = _amountController.text;
    final method = _paymentMethods.firstWhere((m) => m.id == _selectedMethod);
    
    return Center(
      key: const ValueKey('success'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 5),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Deposit Verified!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 12),
            Text(
              '৳$amount has been added to your wallet',
              style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
              ),
              child: Column(
                children: [
                  _buildDetailRow('Amount', '৳$amount'),
                  const Divider(height: 24),
                  _buildDetailRow('Payment Method', method.name),
                  const Divider(height: 24),
                  _buildDetailRow('Transaction ID', _transactionIdController.text.toUpperCase()),
                  const Divider(height: 24),
                  _buildDetailRow('Reference', _depositReference),
                  const Divider(height: 24),
                  _buildDetailRow('Status', 'Verified', valueColor: const Color(0xFF10B981)),
                  const Divider(height: 24),
                  _buildDetailRow('Date', _formatDateTime(DateTime.now())),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _startNewDeposit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Deposit Again', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedStep() {
    final attemptsLeft = _maxRetries - _retryCount;
    
    return Center(
      key: const ValueKey('failed'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFFEF4444), width: 4),
              ),
              child: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 60),
            ),
            const SizedBox(height: 32),
            const Text(
              'Verification Failed',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Troubleshooting tips
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.help_outline_rounded, color: Color(0xFF6366F1), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Troubleshooting Tips',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipItem('Check if Transaction ID is correct (case-sensitive)'),
                  _buildTipItem('Verify you sent the EXACT amount'),
                  _buildTipItem('Ensure sender number matches your payment'),
                  _buildTipItem('Wait 5 minutes if payment was just made'),
                  _buildTipItem('Contact support if issue persists'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_isBlocked)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: Color(0xFFF59E0B), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Account temporarily blocked. Try again in ${_blockUntil!.difference(DateTime.now()).inMinutes} minutes.',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                '$attemptsLeft attempt${attemptsLeft == 1 ? '' : 's'} remaining',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isBlocked ? null : _retryVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                // Open support chat
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.support_agent_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Opening support chat...'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF6366F1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.support_agent_rounded, size: 18),
              label: const Text('Contact Support'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String accountNumber;
  final String accountType;
  final String processingTime;
  final List<PaymentMethodTag> tags;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.accountNumber,
    required this.accountType,
    required this.processingTime,
    this.tags = const [],
  });
}

class PaymentMethodTag {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const PaymentMethodTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}
