class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';
  
  // Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String profile = '$baseUrl/auth/profile';
  static const String exchangeRate = '$baseUrl/exchange/rate';
  static const String rateHistory = '$baseUrl/exchange/rate-history';
  static const String pricingTiers = '$baseUrl/exchange/pricing-tiers';
  static const String calculate = '$baseUrl/exchange/calculate';
  static const String paymentInstructions = '$baseUrl/exchange/payment-instructions';
  static const String transactions = '$baseUrl/transactions';
  static const String chatMessages = '$baseUrl/chat/messages';
  static const String notifications = '$baseUrl/chat/notifications';
}
