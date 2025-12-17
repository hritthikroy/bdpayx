import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<Transaction?> createTransaction(
    String token,
    double fromAmount,
    double toAmount,
    double exchangeRate,
    String paymentMethod,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.transactions),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'from_amount': fromAmount,
          'to_amount': toAmount,
          'exchange_rate': exchangeRate,
          'payment_method': paymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        final transaction = Transaction.fromJson(json.decode(response.body));
        _transactions.insert(0, transaction);
        notifyListeners();
        return transaction;
      }
    } catch (e) {
      print('Create transaction error: $e');
    }
    return null;
  }

  Future<bool> uploadPaymentProof(String token, int transactionId, String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.transactions}/$transactionId/upload-proof'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('proof', filePath));

      final response = await request.send();
      
      if (response.statusCode == 200) {
        await fetchTransactions(token);
        return true;
      }
    } catch (e) {
      print('Upload proof error: $e');
    }
    return false;
  }

  Future<void> fetchTransactions(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.transactions),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _transactions = data.map((json) => Transaction.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch transactions error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
