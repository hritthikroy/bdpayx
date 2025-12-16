import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SecurityProvider with ChangeNotifier {
  String? _transactionPin;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  int _failedAttempts = 0;
  DateTime? _lockoutTime;

  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isLockedOut => _lockoutTime != null && DateTime.now().isBefore(_lockoutTime!);

  SecurityProvider() {
    _loadSettings();
    _checkBiometricAvailability();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _transactionPin = prefs.getString('transaction_pin');
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _failedAttempts = prefs.getInt('failed_attempts') ?? 0;
    
    final lockoutTimestamp = prefs.getInt('lockout_time');
    if (lockoutTimestamp != null) {
      _lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
      if (DateTime.now().isAfter(_lockoutTime!)) {
        _lockoutTime = null;
        _failedAttempts = 0;
        await prefs.remove('lockout_time');
        await prefs.setInt('failed_attempts', 0);
      }
    }
    
    notifyListeners();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Check if device supports biometric authentication
      // This is a placeholder - you'd use local_auth package in production
      _isBiometricAvailable = true;
      notifyListeners();
    } catch (e) {
      _isBiometricAvailable = false;
    }
  }

  Future<bool> setTransactionPin(String pin) async {
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transaction_pin', pin);
    _transactionPin = pin;
    notifyListeners();
    return true;
  }

  Future<bool> verifyTransactionPin(String pin) async {
    if (isLockedOut) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('transaction_pin');

    if (storedPin == null) {
      // No PIN set yet
      return false;
    }

    if (storedPin == pin) {
      // Reset failed attempts on success
      _failedAttempts = 0;
      await prefs.setInt('failed_attempts', 0);
      await prefs.remove('lockout_time');
      _lockoutTime = null;
      notifyListeners();
      return true;
    } else {
      // Increment failed attempts
      _failedAttempts++;
      await prefs.setInt('failed_attempts', _failedAttempts);

      // Lock out after 5 failed attempts
      if (_failedAttempts >= 5) {
        _lockoutTime = DateTime.now().add(const Duration(minutes: 5));
        await prefs.setInt('lockout_time', _lockoutTime!.millisecondsSinceEpoch);
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> changeTransactionPin(String oldPin, String newPin) async {
    final isValid = await verifyTransactionPin(oldPin);
    if (!isValid) {
      return false;
    }

    return await setTransactionPin(newPin);
  }

  Future<bool> authenticateWithBiometric() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) {
      return false;
    }

    try {
      // Placeholder for biometric authentication
      // In production, use local_auth package:
      // final auth = LocalAuthentication();
      // return await auth.authenticate(
      //   localizedReason: 'Authenticate to proceed with transaction',
      //   options: const AuthenticationOptions(
      //     stickyAuth: true,
      //     biometricOnly: true,
      //   ),
      // );
      
      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> enableBiometric(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enable);
    _isBiometricEnabled = enable;
    notifyListeners();
  }

  Future<void> resetPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transaction_pin');
    await prefs.remove('failed_attempts');
    await prefs.remove('lockout_time');
    _transactionPin = null;
    _failedAttempts = 0;
    _lockoutTime = null;
    notifyListeners();
  }

  int get remainingAttempts => 5 - _failedAttempts;
  
  Duration? get lockoutDuration {
    if (_lockoutTime == null) return null;
    final remaining = _lockoutTime!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
}
