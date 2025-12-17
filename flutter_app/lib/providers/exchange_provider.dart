import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';

class ExchangeProvider with ChangeNotifier {
  double _baseRate = 0.70;
  double _currentRate = 0.70;
  List<Map<String, dynamic>> _pricingTiers = [];
  Timer? _refreshTimer;
  Timer? _countdownTimer;
  int _countdown = 60;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  final List<double> _rateHistory = [0.70, 0.698, 0.702, 0.699, 0.701, 0.70];

  double get baseRate => _baseRate;
  double get currentRate => _currentRate;
  List<Map<String, dynamic>> get pricingTiers => _pricingTiers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get countdown => _countdown;
  List<double> get rateHistory => _rateHistory;

  ExchangeProvider() {
    // Initialize with default rate immediately
    _baseRate = 0.70;
    _currentRate = 0.70;
    // Don't auto-initialize - wait for explicit call from splash screen
  }
  
  // Explicit initialization method called from splash screen
  void initialize() {
    if (_isInitialized) return; // Prevent double initialization
    
    _isInitialized = true;
    fetchExchangeRate();
    fetchPricingTiers();
    startAutoRefresh();
  }

  void startAutoRefresh() {
    _countdown = 60;

    // Countdown timer - only notify every 5 seconds to reduce rebuilds
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown > 0) {
        _countdown--;
        // Only notify every 5 seconds or at key moments (10, 5, 0)
        if (_countdown % 5 == 0 || _countdown <= 5) {
          notifyListeners();
        }
      } else {
        _countdown = 60;
        notifyListeners();
      }
    });

    // Refresh timer (fetches new rate every 60 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _error = null; // Clear any previous error before attempting refresh
      notifyListeners(); // Notify that we're starting a fetch
      fetchExchangeRate();
      _countdown = 60;
    });
  }

  Future<void> fetchExchangeRate() async {
    _error = null; // Clear previous error before attempting fetch
    if (_isInitialized) {
      notifyListeners(); // Notify that loading/error state has changed
    }

    try {
      final response = await http.get(Uri.parse(ApiConfig.exchangeRate)).timeout(
        const Duration(seconds: 10), // Increase timeout to 10 seconds
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newRate = double.parse(data['base_rate'].toString());

        // Only notify if rate actually changed and initialized
        if (newRate != _baseRate && _isInitialized) {
          _baseRate = newRate;
          _updateRateHistory(newRate);
          _error = null;
          notifyListeners();
        } else {
          _baseRate = newRate;
          _error = null;
        }
      } else {
        // Only show error if we've successfully initialized before
        if (_isInitialized) {
          _error = 'Failed to fetch exchange rate: Server returned ${response.statusCode}';
          print('Fetch rate error: Server returned ${response.statusCode}');
          notifyListeners();
        }
      }
    } catch (e) {
      // Only show error if we've successfully initialized before
      if (_isInitialized) {
        _error = 'Network error: ${e.toString().split('(').first.trim()}'; // Simplify error message
        print('Fetch rate error: $e');
        notifyListeners();
      }
    }
  }

  Future<void> fetchPricingTiers() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.pricingTiers));
      if (response.statusCode == 200) {
        _pricingTiers = List<Map<String, dynamic>>.from(json.decode(response.body));
        // Only notify if initialized
        if (_isInitialized) {
          notifyListeners();
        }
      }
    } catch (e) {
      print('Fetch tiers error: $e');
    }
  }

  Future<Map<String, dynamic>?> calculateExchange(double amount) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.calculate),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': amount}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Calculate error: $e');
    }
    return null;
  }
  
  // Quick calculation without API call for instant feedback
  double quickCalculate(double amount) {
    return amount * _baseRate;
  }

  void _updateRateHistory(double newRate) {
    _rateHistory.add(newRate);
    if (_rateHistory.length > 10) {
      _rateHistory.removeAt(0);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
