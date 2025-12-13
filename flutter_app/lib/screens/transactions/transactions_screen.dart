import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/login_popup.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is logged in
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await LoginPopup.show(
          context,
          message: 'Login to view your transactions',
        );
      });
      return;
    }
    
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    if (authProvider.token != null) {
      await transactionProvider.fetchTransactions(authProvider.token!);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No transactions yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTransactions,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.transactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(transaction.status).withOpacity(0.2),
                      child: Icon(
                        Icons.currency_exchange,
                        color: _getStatusColor(transaction.status),
                      ),
                    ),
                    title: Text(transaction.transactionRef),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('৳${transaction.fromAmount} → ₹${transaction.toAmount}'),
                        Text(
                          DateFormat('MMM dd, yyyy HH:mm').format(transaction.createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(transaction.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
