// Production API Configuration
// Replace api_config.dart with this file for production builds

class ApiConfig {
  // Production API Base URL
  static const String baseUrl = 'https://api.bdpayx.com/api';
  
  // Authentication Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String profile = '$baseUrl/auth/profile';
  static const String updateProfile = '$baseUrl/auth/profile';
  
  // Exchange Endpoints
  static const String exchangeRate = '$baseUrl/exchange/rate';
  static const String calculateExchange = '$baseUrl/exchange/calculate';
  static const String createExchange = '$baseUrl/exchange/create';
  static const String exchangeHistory = '$baseUrl/exchange/history';
  
  // Transaction Endpoints
  static const String transactions = '$baseUrl/transactions';
  static const String transactionDetails = '$baseUrl/transactions';
  
  // Wallet Endpoints
  static const String wallet = '$baseUrl/wallet';
  static const String walletBalance = '$baseUrl/wallet/balance';
  static const String walletDeposit = '$baseUrl/wallet/deposit';
  static const String walletWithdraw = '$baseUrl/wallet/withdraw';
  
  // Admin Endpoints
  static const String adminDashboard = '$baseUrl/admin/dashboard';
  static const String adminTransactions = '$baseUrl/admin/transactions';
  static const String adminUsers = '$baseUrl/admin/users';
  
  // Configuration
  static const int timeoutSeconds = 30;
  static const int maxRetries = 3;
  
  // App Version
  static const String appVersion = '1.0.0';
  static const String appName = 'BDPayX';
}
