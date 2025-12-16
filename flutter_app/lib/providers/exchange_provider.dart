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

  double get baseRate => _baseRate;
  double get currentRate => _currentRate;
  List<Map<String, dynamic>> get pricingTiers => _pricingTiers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get countdown => _countdown;

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
    
    // Countdown timer (updates every second) with smooth notifications
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown > 0) {
        _countdown--;
        // Notify listeners for smooth countdown animation
        notifyListeners();
      } else {
        _countdown = 60;
        notifyListeners();
      }
    });
    
    // Refresh timer (fetches new rate every 60 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      fetchExchangeRate();
      _countdown = 60;
      notifyListeners();
    });
  }

  Future<void> fetchExchangeRate() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.exchangeRate)).timeout(
        const Duration(seconds: 5),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newRate = double.parse(data['base_rate'].toString());
        
        // Only notify if rate actually changed and initialized
        if (newRate != _baseRate && _isInitialized) {
          _baseRate = newRate;
          _error = null;
          notifyListeners();
        } else {
          _baseRate = newRate;
          _error = null;
        }
      } else {
        if (_error == null && _isInitialized) {
          _error = 'Failed to fetch rate';
          notifyListeners();
        }
      }
    } catch (e) {
      if (_error == null && _isInitialized) {
        _error = 'Network error';
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

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
