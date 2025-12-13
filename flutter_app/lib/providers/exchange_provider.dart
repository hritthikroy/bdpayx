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

  double get baseRate => _baseRate;
  double get currentRate => _currentRate;
  List<Map<String, dynamic>> get pricingTiers => _pricingTiers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get countdown => _countdown;

  ExchangeProvider() {
    fetchExchangeRate();
    fetchPricingTiers();
    startAutoRefresh();
  }

  void startAutoRefresh() {
    _countdown = 60;
    
    // Countdown timer (updates every second)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown > 0) {
        _countdown--;
        notifyListeners();
      } else {
        _countdown = 60;
      }
    });
    
    // Refresh timer (fetches new rate every 60 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      fetchExchangeRate();
      _countdown = 60;
    });
  }

  Future<void> fetchExchangeRate() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await http.get(Uri.parse(ApiConfig.exchangeRate)).timeout(
        const Duration(seconds: 5),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _baseRate = double.parse(data['base_rate'].toString());
        _error = null;
      } else {
        _error = 'Failed to fetch rate';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      print('Fetch rate error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPricingTiers() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.pricingTiers));
      if (response.statusCode == 200) {
        _pricingTiers = List<Map<String, dynamic>>.from(json.decode(response.body));
        notifyListeners();
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
