import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/security_provider.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({Key? key}) : super(key: key);

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final List<String> _oldPin = ['', '', '', ''];
  final List<String> _newPin = ['', '', '', ''];
  final List<String> _confirmPin = ['', '', '', ''];
  int _currentIndex = 0;
  int _step = 0; // 0: old PIN, 1: new PIN, 2: confirm PIN
  bool _isError = false;
  String _errorMessage = '';

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'Enter Current PIN';
      case 1:
        return 'Enter New PIN';
      case 2:
        return 'Confirm New PIN';
      default:
        return '';
    }
  }

  String get _stepSubtitle {
    switch (_step) {
      case 0:
        return 'Enter your current transaction PIN';
      case 1:
        return 'Create a new 4-digit PIN';
      case 2:
        return 'Re-enter your new PIN';
      default:
        return '';
    }
  }

  List<String> get _currentPin {
    switch (_step) {
      case 0:
        return _oldPin;
      case 1:
        return _newPin;
      case 2:
        return _confirmPin;
      default:
        return _oldPin;
    }
  }

  void _onNumberPressed(String number) {
    if (_currentIndex < 4) {
      setState(() {
        _currentPin[_currentIndex] = number;
        _currentIndex++;
        _isError = false;
        _errorMessage = '';
      });

      HapticFeedback.lightImpact();

      if (_currentIndex == 4) {
        _handleStepComplete();
      }
    }
  }

  void _onBackspace() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentPin[_currentIndex] = '';
        _isError = false;
        _errorMessage = '';
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _handleStepComplete() async {
    if (_step == 0) {
      // Verify old PIN
      final securityProvider = context.read<SecurityProvider>();
      final isValid = await securityProvider.verifyTransactionPin(_oldPin.join());
      
      if (isValid) {
        setState(() {
          _step = 1;
          _currentIndex = 0;
        });
      } else {
        _showError('Incorrect PIN. Please try again.');
      }
    } else if (_step == 1) {
      // Move to confirm step
      setState(() {
        _step = 2;
        _currentIndex = 0;
      });
    } else if (_step == 2) {
      // Verify and save new PIN
      await _changePin();
    }
  }

  Future<void> _changePin() async {
    final newPin = _newPin.join();
    final confirmPin = _confirmPin.join();

    if (newPin != confirmPin) {
      _showError('PINs do not match. Please try again.');
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _step = 1;
          _newPin.fillRange(0, 4, '');
          _confirmPin.fillRange(0, 4, '');
          _currentIndex = 0;
          _isError = false;
        });
      });
      return;
    }

    final securityProvider = context.read<SecurityProvider>();
    final success = await securityProvider.changeTransactionPin(
      _oldPin.join(),
      newPin,
    );

    if (success) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showError('Failed to change PIN. Please try again.');
    }
  }

  void _showError(String message) {
    setState(() {
      _isError = true;
      _errorMessage = message;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                _stepTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _stepSubtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 60),
              // PIN circles
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _PinCircle(
                        filled: _currentPin[index].isNotEmpty,
                        isError: _isError,
                      ),
                    );
                  }),
                ),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const Spacer(),
              // Number pad
              _buildNumberPad(),
              const SizedBox(height: 40),
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
