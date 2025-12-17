import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/auth_provider.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _bkashNumberController = TextEditingController();
  
  // Steps: 0=Enter Details, 1=Confirm, 2=Processing, 3=Success
  int _currentStep = 0;
  bool _isProcessing = false;
  String _withdrawalId = '';
  
  // Slide to confirm
  double _slidePosition = 0.0;
  bool _isSliding = false;
  
  late AnimationController _pulseController;
  late AnimationController _successController;

  // bKash withdrawal limits
  static const double _minWithdraw = 500;
  static const double _maxWithdraw = 25000;
  static const double _dailyLimit = 50000;
  
  // Charge: 2% fee (৳20 per ৳1000)
  static const double _feePercentage = 2.0;

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
    
    _generateWithdrawalId();
    
    // Listen to amount changes to update UI
    _amountController.addListener(() {
      setState(() {});
    });
  }

  void _generateWithdrawalId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(9999).toString().padLeft(4, '0');
    _withdrawalId = 'WD$timestamp$random';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bkashNumberController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  // Calculate withdrawal charge (2% fee)
  double _calculateCharge(double amount) {
    return (amount * _feePercentage / 100);
  }

  // Calculate total deduction
  double _getTotalDeduction() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return 0;
    return amount + _calculateCharge(amount);
  }

  // Get the amount user will receive
  double _getReceiveAmount() {
    return double.tryParse(_amountController.text) ?? 0;
  }

  void _proceedToConfirm() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final amount = double.tryParse(_amountController.text);
    
    // Validate amount
    if (amount == null || amount < _minWithdraw) {
      _showError('Minimum withdrawal is ৳500');
      return;
    }
    if (amount > _maxWithdraw) {
      _showError('Maximum withdrawal per request is ৳$_maxWithdraw');
      return;
    }
    
    final totalDeduction = _getTotalDeduction();
    if (totalDeduction > (user?.balance ?? 0)) {
      _showError('Insufficient balance (including ৳${_calculateCharge(amount).toStringAsFixed(0)} charge)');
      return;
    }
    
    // Validate bKash number
    final bkashNum = _bkashNumberController.text.trim();
    if (bkashNum.isEmpty) {
      _showError('Please enter your bKash number');
      return;
    }
    if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(bkashNum)) {
      _showError('Invalid bKash number format');
      return;
    }
    
    HapticFeedback.mediumImpact();
    setState(() => _currentStep = 1);
  }

  void _onSlideComplete() {
    HapticFeedback.heavyImpact();
    setState(() {
      _currentStep = 2;
      _isProcessing = true;
      _slidePosition = 0;
    });
    
    // Deduct balance and create pending order
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final totalDeduction = _getTotalDeduction();
    
    // Create withdrawal request
    authProvider.createWithdrawalRequest(
      withdrawalId: _withdrawalId,
      amount: _getReceiveAmount(),
      charge: _calculateCharge(_getReceiveAmount()),
      bkashNumber: _bkashNumberController.text.trim(),
    );
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _onWithdrawalSuccess();
      }
    });
  }

  void _onWithdrawalSuccess() {
    HapticFeedback.heavyImpact();
    _successController.forward();
    setState(() {
      _isProcessing = false;
      _currentStep = 3;
    });
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
          colors: [Color(0xFFE2136E), Color(0xFFD1105E)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () {
                  if (_currentStep > 0 && _currentStep < 3 && !_isProcessing) {
                    setState(() => _currentStep--);
                  } else if (!_isProcessing) {
                    Navigator.pop(context);
                  }
                },
              ),
              const Expanded(
                child: Text(
                  'Withdraw to bKash',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // bKash badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_android_rounded, color: Color(0xFFE2136E), size: 16),
                    SizedBox(width: 4),
                    Text(
                      'bKash',
                      style: TextStyle(
                        color: Color(0xFFE2136E),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    return Row(
      children: [
        _buildStepIndicator(0, 'Details'),
        _buildStepLine(0),
        _buildStepIndicator(1, 'Confirm'),
        _buildStepLine(1),
        _buildStepIndicator(2, 'Process'),
        _buildStepLine(2),
        _buildStepIndicator(3, 'Done'),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Center(
            child: isActive && _currentStep > step
                ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFFE2136E))
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFFE2136E) : Colors.white54,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.white : Colors.white54,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildDetailsStep();
      case 1:
        return _buildConfirmStep();
      case 2:
        return _buildProcessingStep();
      case 3:
        return _buildSuccessStep();
      default:
        return _buildDetailsStep();
    }
  }

  Widget _buildDetailsStep() {
    final user = Provider.of<AuthProvider>(context).user;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final charge = amount > 0 ? _calculateCharge(amount) : 0.0;
    final totalDeduction = amount > 0 ? amount + charge : 0.0;
    
    return SingleChildScrollView(
      key: const ValueKey('details'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Balance Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '৳${user?.balance.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // bKash Number Input
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
                        color: const Color(0xFFE2136E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.phone_android_rounded, color: Color(0xFFE2136E), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'bKash Personal Number',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          'Enter your registered bKash number',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bkashNumberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
                  decoration: InputDecoration(
                    hintText: '01XXXXXXXXX',
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
                      borderSide: const BorderSide(color: Color(0xFFE2136E), width: 2),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Text('+88', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Amount Input
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
                    Icon(Icons.payments_rounded, color: Color(0xFFE2136E), size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Withdrawal Amount',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Min: ৳$_minWithdraw  •  Max: ৳$_maxWithdraw per request',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
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
                          color: Color(0xFFE2136E),
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
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [500, 1000, 2000, 5000, 10000].map((amt) => _buildQuickAmountChip(amt)).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Charge Breakdown Card
          if (amount > 0)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2136E).withValues(alpha: 0.3)),
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
                          color: const Color(0xFFE2136E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFE2136E), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Charge Breakdown',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildChargeRow('Withdrawal Amount', '৳${amount.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildChargeRow('Service Charge ($_feePercentage%)', '৳${charge.toStringAsFixed(0)}', isCharge: true),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  _buildChargeRow('Total Deduction', '৳${totalDeduction.toStringAsFixed(0)}', isTotal: true),
                  const SizedBox(height: 8),
                  _buildChargeRow('You Will Receive', '৳${amount.toStringAsFixed(0)}', isReceive: true),
                ],
              ),
            ),
          const SizedBox(height: 20),
          
          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_rounded, color: Color(0xFFF59E0B), size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Important Information',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem(Icons.timer_rounded, 'Processing time: 1-24 hours'),
                _buildInfoItem(Icons.verified_user_rounded, 'Manual verification by admin'),
                _buildInfoItem(Icons.currency_exchange_rounded, 'Service fee: $_feePercentage%'),
                _buildInfoItem(Icons.cancel_rounded, 'Cancel anytime from history'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _proceedToConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2136E),
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

  Widget _buildChargeRow(String label, String value, {bool isCharge = false, bool isTotal = false, bool isReceive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal || isReceive ? 15 : 14,
            color: isCharge ? const Color(0xFFEF4444) : const Color(0xFF64748B),
            fontWeight: isTotal || isReceive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          isCharge ? '-$value' : value,
          style: TextStyle(
            fontSize: isTotal || isReceive ? 16 : 14,
            fontWeight: isTotal || isReceive ? FontWeight.bold : FontWeight.w600,
            color: isCharge 
                ? const Color(0xFFEF4444) 
                : isReceive 
                    ? const Color(0xFF10B981) 
                    : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF59E0B), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF92400E))),
          ),
        ],
      ),
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
          color: isSelected ? const Color(0xFFE2136E) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE2136E) : const Color(0xFFE2E8F0),
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


  Widget _buildConfirmStep() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final charge = _calculateCharge(amount);
    final totalDeduction = amount + charge;
    final bkashNumber = _bkashNumberController.text;
    
    return SingleChildScrollView(
      key: const ValueKey('confirm'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Confirmation Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2136E).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFE2136E), size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Confirm Withdrawal',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please review your withdrawal details',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Details Card
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
                _buildDetailRow('You Will Receive', '৳${amount.toStringAsFixed(0)}', isHighlight: true, valueColor: const Color(0xFF10B981)),
                const Divider(height: 24),
                _buildDetailRow('Service Charge ($_feePercentage%)', '৳${charge.toStringAsFixed(0)}', valueColor: const Color(0xFFEF4444)),
                const Divider(height: 24),
                _buildDetailRow('Total Deduction', '৳${totalDeduction.toStringAsFixed(0)}', isHighlight: true),
                const Divider(height: 24),
                _buildDetailRow('bKash Number', '+88$bkashNumber'),
                const Divider(height: 24),
                _buildDetailRow('Request ID', _withdrawalId),
                const Divider(height: 24),
                _buildDetailRow('Processing Time', '1-24 hours'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Amount will be deducted from your balance immediately. You can cancel from history if needed.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Slide to Confirm Button
          _buildSlideToConfirm(),
          
          const SizedBox(height: 16),
          
          // Back button
          TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Text('← Go Back & Edit', style: TextStyle(color: Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideToConfirm() {
    const double buttonWidth = 70;
    final double maxSlide = MediaQuery.of(context).size.width - 40 - buttonWidth - 8;
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFE2136E).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2136E).withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          // Background text
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 60),
                Text(
                  _slidePosition > maxSlide * 0.8 ? 'Release to Confirm' : 'Slide to Confirm',
                  style: TextStyle(
                    color: const Color(0xFFE2136E).withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: const Color(0xFFE2136E).withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
          // Sliding button
          Positioned(
            left: 4 + _slidePosition,
            top: 4,
            child: GestureDetector(
              onHorizontalDragStart: (_) {
                setState(() => _isSliding = true);
              },
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _slidePosition += details.delta.dx;
                  _slidePosition = _slidePosition.clamp(0.0, maxSlide);
                });
              },
              onHorizontalDragEnd: (_) {
                if (_slidePosition > maxSlide * 0.8) {
                  _onSlideComplete();
                } else {
                  setState(() {
                    _slidePosition = 0;
                    _isSliding = false;
                  });
                }
              },
              child: AnimatedContainer(
                duration: _isSliding ? Duration.zero : const Duration(milliseconds: 300),
                width: buttonWidth,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _slidePosition > maxSlide * 0.8
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [const Color(0xFFE2136E), const Color(0xFFD1105E)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE2136E).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _slidePosition > maxSlide * 0.8 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isHighlight ? const Color(0xFFE2136E) : const Color(0xFF1E293B)),
          ),
        ),
      ],
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
                    color: const Color(0xFFE2136E).withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE2136E).withValues(alpha: 0.2 * _pulseController.value),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE2136E)),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Submitting Request',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Deducting balance and creating request...',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStep() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final charge = _calculateCharge(amount);
    final totalDeduction = amount + charge;
    final bkashNumber = _bkashNumberController.text;
    
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
              'Request Submitted!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 12),
            Text(
              '৳${totalDeduction.toStringAsFixed(0)} deducted from your balance',
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
                  _buildDetailRow('You Will Receive', '৳${amount.toStringAsFixed(0)}', valueColor: const Color(0xFF10B981)),
                  const Divider(height: 24),
                  _buildDetailRow('bKash Number', '+88$bkashNumber'),
                  const Divider(height: 24),
                  _buildDetailRow('Request ID', _withdrawalId),
                  const Divider(height: 24),
                  _buildDetailRow('Status', 'Pending', valueColor: const Color(0xFFF59E0B)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Cancel Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can cancel this request from Transaction History. Balance will be refunded.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to history
                      Navigator.pop(context);
                      // TODO: Navigate to transaction history
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE2136E),
                      side: const BorderSide(color: Color(0xFFE2136E)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('View History', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2136E),
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
}
