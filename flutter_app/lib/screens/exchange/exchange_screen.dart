import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exchange_provider.dart';
import '../../providers/transaction_provider.dart';
import 'payment_screen.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final _amountController = TextEditingController();
  double _convertedAmount = 0;
  double _appliedRate = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateExchange);
  }

  Future<void> _calculateExchange() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _convertedAmount = 0;
        _appliedRate = 0;
      });
      return;
    }

    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    
    // Quick calculation for instant feedback
    setState(() {
      _convertedAmount = exchangeProvider.quickCalculate(amount);
      _appliedRate = exchangeProvider.baseRate;
    });
    
    // Then get accurate calculation from API
    final result = await exchangeProvider.calculateExchange(amount);
    if (result != null) {
      setState(() {
        _convertedAmount = double.parse(result['to_amount'].toString());
        _appliedRate = double.parse(result['exchange_rate'].toString());
      });
    }
  }

  void _proceedToPayment() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          fromAmount: amount,
          toAmount: _convertedAmount,
          exchangeRate: _appliedRate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final exchangeProvider = Provider.of<ExchangeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.phone ?? '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '৳${user?.balance.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'BDT Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.notifications, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),

              // Exchange Card
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exchange Rate (BDT → INR)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Next update in ${exchangeProvider.countdown}s',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  exchangeProvider.baseRate.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Base',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            Text('1 BDT = ₹${exchangeProvider.baseRate.toStringAsFixed(4)}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter BDT Amount',
                          prefixText: '৳ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Quick amount buttons
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildQuickAmountChip('1000'),
                          _buildQuickAmountChip('5000'),
                          _buildQuickAmountChip('10000'),
                          _buildQuickAmountChip('25000'),
                          _buildQuickAmountChip('50000'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_convertedAmount > 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('You will receive:'),
                              Text(
                                '₹${_convertedAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _proceedToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Exchange BDT to INR',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pricing Tiers
              if (exchangeProvider.pricingTiers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('BDT Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Rate (INR)', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        ...exchangeProvider.pricingTiers.map((tier) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('>=${tier['min_amount']} ${tier['max_amount'] != null ? 'and <${tier['max_amount']}' : ''}'),
                                Text('100+${tier['markup']}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(String amount) {
    return ActionChip(
      label: Text('৳$amount'),
      backgroundColor: Colors.blue.shade50,
      onPressed: () {
        _amountController.text = amount;
      },
    );
  }
}
