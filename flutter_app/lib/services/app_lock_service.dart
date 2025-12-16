import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockService with WidgetsBindingObserver {
  static final AppLockService _instance = AppLockService._internal();
  factory AppLockService() => _instance;
  AppLockService._internal();

  bool _isLocked = false;
  DateTime? _lastPausedTime;
  VoidCallback? _onLockRequired;

  bool get isLocked => _isLocked;

  void initialize(VoidCallback onLockRequired) {
    _onLockRequired = onLockRequired;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background
        _lastPausedTime = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        // App coming back to foreground
        _checkIfLockRequired();
        break;
      default:
        break;
    }
  }

  Future<void> _checkIfLockRequired() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPinSet = prefs.getString('transaction_pin') != null;

    if (!hasPinSet) {
      // No PIN set, don't lock
      return;
    }

    // Check if app was in background for more than 30 seconds
    if (_lastPausedTime != null) {
      final duration = DateTime.now().difference(_lastPausedTime!);
      if (duration.inSeconds > 30) {
        _isLocked = true;
        _onLockRequired?.call();
      }
    }
  }

  void unlock() {
    _isLocked = false;
    _lastPausedTime = null;
  }

  Future<bool> shouldShowPinSetup() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPinSet = prefs.getString('transaction_pin') != null;
    final hasShownSetup = prefs.getBool('has_shown_pin_setup') ?? false;
    
    return !hasPinSet && !hasShownSetup;
  }

  Future<void> markPinSetupShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_shown_pin_setup', true);
  }
}
