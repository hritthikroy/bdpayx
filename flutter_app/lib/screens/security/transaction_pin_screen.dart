import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/security_provider.dart';

class TransactionPinScreen extends StatefulWidget {
  final String? userName;
  final String? phoneNumber;
  final VoidCallback? onSuccess;
  final bool canUseBiometric;

  const TransactionPinScreen({
    Key? key,
    this.userName,
    this.phoneNumber,
    this.onSuccess,
    this.canUseBiometric = true,
  }) : super(key: key);

  @override
  State<TransactionPinScreen> createState() => _TransactionPinScreenState();
}

class _TransactionPinScreenState extends State<TransactionPinScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _pin = ['', '', '', ''];
  int _currentIndex = 0;
  bool _isError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_currentIndex < 4) {
      setState(() {
        _pin[_currentIndex] = number;
        _currentIndex++;
        _isError = false;
      });

      // Haptic feedback
      HapticFeedback.lightImpact();

      // Auto verify when all 4 digits entered
      if (_currentIndex == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pin[_currentIndex] = '';
        _isError = false;
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _verifyPin() async {
    final enteredPin = _pin.join();
    final securityProvider = context.read<SecurityProvider>();

    final isValid = await securityProvider.verifyTransactionPin(enteredPin);

    if (isValid) {
      HapticFeedback.mediumImpact();
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.pop(context, true);
      }
    } else {
      _showError();
    }
  }

  void _showError() {
    setState(() {
      _isError = true;
    });
    _shakeController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _pin.fillRange(0, 4, '');
          _currentIndex = 0;
          _isError = false;
        });
      });
    });
    HapticFeedback.heavyImpact();
  }

  Future<void> _useBiometric() async {
    final securityProvider = context.read<SecurityProvider>();
    final success = await securityProvider.authenticateWithBiometric();

    if (success) {
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = widget.userName ?? authProvider.user?.fullName?.split(' ').first ?? 'User';
    final phoneNumber = widget.phoneNumber ?? authProvider.user?.phone ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Greeting
              Text(
                'Hi $userName',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              // Phone number
              Text(
                phoneNumber.isNotEmpty ? _maskPhoneNumber(phoneNumber) : '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              // Not you link
              GestureDetector(
                onTap: () {
                  // Handle switch user
                  Navigator.pop(context);
                },
                child: const Text(
                  'Not you?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // PIN circles
              Center(
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _isError
                          ? Offset(_shakeAnimation.value, 0)
                          : Offset.zero,
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _PinCircle(
                          filled: _pin[index].isNotEmpty,
                          isError: _isError,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Forgot PIN
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Handle forgot PIN
                    _showForgotPinDialog();
                  },
                  child: const Text(
                    'Forgot PIN?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Number pad
              _buildNumberPad(),
              const SizedBox(height: 20),
              // Biometric option
              if (widget.canUseBiometric)
                Center(
                  child: GestureDetector(
                    onTap: _useBiometric,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.1),
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.fingerprint,
                            color: Color(0xFF8B5CF6),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Use screen lock',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8B5CF6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildNumberRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildNumberRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildNumberRow(['', '0', 'back']),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }
        if (number == 'back') {
          return _NumberButton(
            onPressed: _onBackspace,
            child: const Icon(Icons.backspace_outlined, size: 24),
          );
        }
        return _NumberButton(
          onPressed: () => _onNumberPressed(number),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    final last4 = phone.substring(phone.length - 4);
    final masked = '*' * (phone.length - 4);
    return '+91 $masked$last4';
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot PIN?'),
        content: const Text(
          'To reset your transaction PIN, please contact support or verify your identity through OTP.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to reset PIN flow
            },
            child: const Text('Reset PIN'),
          ),
        ],
      ),
    );
  }
}

class _PinCircle extends StatelessWidget {
  final bool filled;
  final bool isError;

  const _PinCircle({
    required this.filled,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isError
              ? const Color(0xFFEF4444)
              : filled
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFFE2E8F0),
          width: 2.5,
        ),
        color: filled 
            ? const Color(0xFF8B5CF6).withOpacity(0.1) 
            : Colors.white,
        boxShadow: filled
            ? [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: filled
          ? Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isError
                      ? const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                ),
              ),
            )
          : null,
    );
  }
}

class _NumberButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _NumberButton({
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        splashColor: const Color(0xFF8B5CF6).withOpacity(0.2),
        highlightColor: const Color(0xFF8B5CF6).withOpacity(0.1),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
