import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  
  // Real balance getters - no demo data
  double get bdtBalance => _user?.balance ?? 0.0;
  double get inrBalance => _user?.inrBalance ?? 0.0;
  
  // Check if user has any transaction history
  bool get hasTransactions => 
      _withdrawalRequests.isNotEmpty || 
      _exchangeRequests.isNotEmpty || 
      _depositRequests.isNotEmpty;

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone, 'password': password}),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = User.fromJson(data['user']);
        _token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user_data', json.encode(data['user']));
        
        // Load user-specific data after login
        await loadUserData();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('Login failed: Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String phone, String email, String password, String fullName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = User.fromJson(data['user']);
        _token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user_data', json.encode(data['user']));
        
        // New user - no data to load, but initialize empty lists
        _withdrawalRequests.clear();
        _exchangeRequests.clear();
        _depositRequests.clear();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('Register failed: Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    // Clear in-memory data
    _withdrawalRequests.clear();
    _exchangeRequests.clear();
    _depositRequests.clear();
    
    _user = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
    // Note: We keep user-specific data in storage for when they log back in
    
    notifyListeners();
  }
  
  // Get user-specific storage key
  String _getUserKey(String baseKey) {
    final userId = _user?.id ?? 'anonymous';
    return '${baseKey}_$userId';
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    
    // Try to load cached user data first
    final cachedUserData = prefs.getString('user_data');
    if (cachedUserData != null) {
      try {
        _user = User.fromJson(json.decode(cachedUserData));
        
        // Load user-specific data after user is loaded
        await loadUserData();
      } catch (e) {
        print('Error loading cached user data: $e');
      }
    }
    
    // Fetch fresh profile data in background without notifying
    if (_token != null) {
      fetchProfile(); // Don't await - let it run in background
    }
    
    // Only notify once after initial load
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profile),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final newUser = User.fromJson(json.decode(response.body));
        // Only notify if user data actually changed
        if (_user == null || _user!.id != newUser.id || _user!.balance != newUser.balance) {
          _user = newUser;

          // Save updated user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', json.encode(newUser.toJson()));

          notifyListeners();
        } else {
          _user = newUser;
        }
      } else {
        print('Fetch profile failed: Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch profile error: $e');
    }
  }

  Future<void> loginWithGoogle(String token, Map<String, dynamic> userData) async {
    _token = token;
    _user = User.fromJson(userData);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    
    // Also save user data for offline access
    await prefs.setString('user_data', json.encode(userData));
    
    // Load user-specific data after login
    await loadUserData();
    
    notifyListeners();
  }

  // Withdrawal requests storage
  final List<WithdrawalRequest> _withdrawalRequests = [];
  List<WithdrawalRequest> get withdrawalRequests => _withdrawalRequests;
  List<WithdrawalRequest> get pendingWithdrawals => 
      _withdrawalRequests.where((r) => r.status == 'pending').toList();

  // Create withdrawal request and deduct balance
  void createWithdrawalRequest({
    required String withdrawalId,
    required double amount,
    required double charge,
    required String bkashNumber,
  }) {
    if (_user == null) return;
    
    final totalDeduction = amount + charge;
    
    // Deduct from balance
    _user = _user!.copyWith(balance: _user!.balance - totalDeduction);
    
    // Create request
    final request = WithdrawalRequest(
      id: withdrawalId,
      amount: amount,
      charge: charge,
      totalDeduction: totalDeduction,
      bkashNumber: bkashNumber,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    
    _withdrawalRequests.insert(0, request);
    notifyListeners();
    
    // Save to local storage
    _saveWithdrawalRequests();
  }

  // Cancel withdrawal request and refund balance
  void cancelWithdrawalRequest(String withdrawalId) {
    final index = _withdrawalRequests.indexWhere((r) => r.id == withdrawalId);
    if (index == -1) return;
    
    final request = _withdrawalRequests[index];
    if (request.status != 'pending') return;
    
    // Refund balance
    _user = _user!.copyWith(balance: _user!.balance + request.totalDeduction);
    
    // Update status
    _withdrawalRequests[index] = request.copyWith(status: 'cancelled');
    notifyListeners();
    
    // Save to local storage
    _saveWithdrawalRequests();
  }

  Future<void> _saveWithdrawalRequests() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = _withdrawalRequests.map((r) => r.toJson()).toList();
    await prefs.setString(_getUserKey('withdrawal_requests'), json.encode(data));
  }

  Future<void> loadWithdrawalRequests() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_getUserKey('withdrawal_requests'));
    _withdrawalRequests.clear();
    if (data != null) {
      final list = json.decode(data) as List;
      _withdrawalRequests.addAll(list.map((e) => WithdrawalRequest.fromJson(e)));
    }
  }

  // Exchange requests storage
  final List<ExchangeRequest> _exchangeRequests = [];
  List<ExchangeRequest> get exchangeRequests => _exchangeRequests;
  List<ExchangeRequest> get pendingExchangeRequests => 
      _exchangeRequests.where((r) => r.status == 'pending' || r.status == 'processing').toList();

  // Check if user has pending exchange request
  bool get hasPendingExchangeRequest => 
      _exchangeRequests.any((r) => r.status == 'pending' || r.status == 'processing');

  // Create exchange request
  ExchangeRequest createExchangeRequest({
    required String transactionRef,
    required double fromAmount,
    required double toAmount,
    required double exchangeRate,
    required String paymentMethod,
    String? upiId,
    Map<String, dynamic>? bankAccount,
  }) {
    final request = ExchangeRequest(
      id: transactionRef,
      fromAmount: fromAmount,
      toAmount: toAmount,
      exchangeRate: exchangeRate,
      paymentMethod: paymentMethod,
      upiId: upiId,
      bankAccount: bankAccount,
      status: 'pending',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    
    _exchangeRequests.insert(0, request);
    notifyListeners();
    
    // Save to local storage
    _saveExchangeRequests();
    
    return request;
  }

  // Cancel exchange request
  void cancelExchangeRequest(String requestId) {
    final index = _exchangeRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;
    
    final request = _exchangeRequests[index];
    if (request.status != 'pending' && request.status != 'processing') return;
    
    // Update status
    _exchangeRequests[index] = request.copyWith(status: 'cancelled');
    notifyListeners();
    
    // Save to local storage
    _saveExchangeRequests();
  }

  // Send reminder for exchange request
  void sendExchangeReminder(String requestId) {
    // TODO: Send reminder to backend
    // For now, just show that reminder was sent
  }

  Future<void> _saveExchangeRequests() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = _exchangeRequests.map((r) => r.toJson()).toList();
    await prefs.setString(_getUserKey('exchange_requests'), json.encode(data));
  }

  Future<void> loadExchangeRequests() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_getUserKey('exchange_requests'));
    _exchangeRequests.clear();
    if (data != null) {
      final list = json.decode(data) as List;
      _exchangeRequests.addAll(list.map((e) => ExchangeRequest.fromJson(e)));
    }
  }

  // Deposit requests storage
  final List<DepositRequest> _depositRequests = [];
  List<DepositRequest> get depositRequests => _depositRequests;
  List<DepositRequest> get pendingDepositRequests => 
      _depositRequests.where((r) => r.status == 'pending').toList();

  // Check if user has pending deposit request
  bool get hasPendingDepositRequest => 
      _depositRequests.any((r) => r.status == 'pending');

  // Create deposit request
  DepositRequest createDepositRequest({
    required String depositRef,
    required double amount,
    required double fee,
    required String paymentMethod,
    String? screenshotPath,
  }) {
    final request = DepositRequest(
      id: depositRef,
      amount: amount,
      fee: fee,
      totalSent: amount + fee,
      paymentMethod: paymentMethod,
      screenshotPath: screenshotPath,
      status: 'pending',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    
    _depositRequests.insert(0, request);
    notifyListeners();
    
    // Save to local storage
    _saveDepositRequests();
    
    return request;
  }

  // Cancel deposit request
  void cancelDepositRequest(String requestId) {
    final index = _depositRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;
    
    final request = _depositRequests[index];
    if (request.status != 'pending') return;
    
    // Update status
    _depositRequests[index] = request.copyWith(status: 'cancelled');
    notifyListeners();
    
    // Save to local storage
    _saveDepositRequests();
  }

  Future<void> _saveDepositRequests() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = _depositRequests.map((r) => r.toJson()).toList();
    await prefs.setString(_getUserKey('deposit_requests'), json.encode(data));
  }

  Future<void> loadDepositRequests() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_getUserKey('deposit_requests'));
    _depositRequests.clear();
    if (data != null) {
      final list = json.decode(data) as List;
      _depositRequests.addAll(list.map((e) => DepositRequest.fromJson(e)));
    }
  }
  
  // Load all user-specific data after login
  Future<void> loadUserData() async {
    if (_user == null) return;
    
    // Clear existing data first
    _withdrawalRequests.clear();
    _exchangeRequests.clear();
    _depositRequests.clear();
    
    // Load user-specific data
    await loadWithdrawalRequests();
    await loadExchangeRequests();
    await loadDepositRequests();
    
    notifyListeners();
  }
}

// Exchange Transaction Request Model
class ExchangeRequest {
  final String id;
  final double fromAmount;
  final double toAmount;
  final double exchangeRate;
  final String paymentMethod; // 'upi' or 'bank_transfer'
  final String? upiId;
  final Map<String, dynamic>? bankAccount;
  final String status; // pending, processing, completed, cancelled
  final DateTime createdAt;
  final DateTime expiresAt;

  ExchangeRequest({
    required this.id,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
    required this.paymentMethod,
    this.upiId,
    this.bankAccount,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  ExchangeRequest copyWith({String? status}) {
    return ExchangeRequest(
      id: id,
      fromAmount: fromAmount,
      toAmount: toAmount,
      exchangeRate: exchangeRate,
      paymentMethod: paymentMethod,
      upiId: upiId,
      bankAccount: bankAccount,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromAmount': fromAmount,
    'toAmount': toAmount,
    'exchangeRate': exchangeRate,
    'paymentMethod': paymentMethod,
    'upiId': upiId,
    'bankAccount': bankAccount,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory ExchangeRequest.fromJson(Map<String, dynamic> json) => ExchangeRequest(
    id: json['id'],
    fromAmount: json['fromAmount'].toDouble(),
    toAmount: json['toAmount'].toDouble(),
    exchangeRate: json['exchangeRate'].toDouble(),
    paymentMethod: json['paymentMethod'],
    upiId: json['upiId'],
    bankAccount: json['bankAccount'],
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: DateTime.parse(json['expiresAt']),
  );

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get remainingTime => expiresAt.difference(DateTime.now());
}

// Deposit Request Model
class DepositRequest {
  final String id;
  final double amount;
  final double fee;
  final double totalSent;
  final String paymentMethod; // 'bkash', 'nagad', 'bank'
  final String? screenshotPath;
  final String status; // pending, approved, rejected, cancelled
  final DateTime createdAt;
  final DateTime expiresAt;

  DepositRequest({
    required this.id,
    required this.amount,
    required this.fee,
    required this.totalSent,
    required this.paymentMethod,
    this.screenshotPath,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  DepositRequest copyWith({String? status}) {
    return DepositRequest(
      id: id,
      amount: amount,
      fee: fee,
      totalSent: totalSent,
      paymentMethod: paymentMethod,
      screenshotPath: screenshotPath,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'fee': fee,
    'totalSent': totalSent,
    'paymentMethod': paymentMethod,
    'screenshotPath': screenshotPath,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory DepositRequest.fromJson(Map<String, dynamic> json) => DepositRequest(
    id: json['id'],
    amount: json['amount'].toDouble(),
    fee: json['fee'].toDouble(),
    totalSent: json['totalSent'].toDouble(),
    paymentMethod: json['paymentMethod'],
    screenshotPath: json['screenshotPath'],
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: DateTime.parse(json['expiresAt']),
  );

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get remainingTime => expiresAt.difference(DateTime.now());
}

// Withdrawal Request Model
class WithdrawalRequest {
  final String id;
  final double amount;
  final double charge;
  final double totalDeduction;
  final String bkashNumber;
  final String status; // pending, completed, cancelled
  final DateTime createdAt;

  WithdrawalRequest({
    required this.id,
    required this.amount,
    required this.charge,
    required this.totalDeduction,
    required this.bkashNumber,
    required this.status,
    required this.createdAt,
  });

  WithdrawalRequest copyWith({String? status}) {
    return WithdrawalRequest(
      id: id,
      amount: amount,
      charge: charge,
      totalDeduction: totalDeduction,
      bkashNumber: bkashNumber,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'charge': charge,
    'totalDeduction': totalDeduction,
    'bkashNumber': bkashNumber,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) => WithdrawalRequest(
    id: json['id'],
    amount: json['amount'].toDouble(),
    charge: json['charge'].toDouble(),
    totalDeduction: json['totalDeduction'].toDouble(),
    bkashNumber: json['bkashNumber'],
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
