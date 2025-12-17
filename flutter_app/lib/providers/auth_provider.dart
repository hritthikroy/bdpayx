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

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = User.fromJson(data['user']);
        _token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        
        _isLoading = false;
        notifyListeners();
        return true;
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
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = User.fromJson(data['user']);
        _token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    
    // Try to load cached user data first
    final cachedUserData = prefs.getString('user_data');
    if (cachedUserData != null) {
      try {
        _user = User.fromJson(json.decode(cachedUserData));
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
      );

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
    
    notifyListeners();
  }
}
