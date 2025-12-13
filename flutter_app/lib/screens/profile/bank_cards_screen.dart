import 'package:flutter/material.dart';

class BankCardsScreen extends StatefulWidget {
  const BankCardsScreen({super.key});

  @override
  State<BankCardsScreen> createState() => _BankCardsScreenState();
}

class _BankCardsScreenState extends State<BankCardsScreen> {
  final List<Map<String, dynamic>> _cards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Bank Accounts'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: _cards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No Indian bank accounts added', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Add your Indian bank account to receive INR payments from exchanges',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddCardDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Indian Bank Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              card['bank_name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (card['is_primary'])
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'PRIMARY',
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '**** **** **** ${card['account_number'].substring(card['account_number'].length - 4)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          card['card_holder_name'],
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'IFSC: ${card['ifsc_code']}',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _cards.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddCardDialog,
              backgroundColor: const Color(0xFF3B82F6),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddCardDialog() {
    final nameController = TextEditingController();
    final bankController = TextEditingController();
    final accountController = TextEditingController();
    final ifscController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Indian Bank Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add your Indian bank account to receive INR payments',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bankController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  hintText: 'e.g., HDFC Bank, ICICI Bank, SBI',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ifscController,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                  hintText: 'e.g., HDFC0001234',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  bankController.text.isNotEmpty &&
                  accountController.text.isNotEmpty &&
                  ifscController.text.isNotEmpty) {
                setState(() {
                  _cards.add({
                    'card_holder_name': nameController.text,
                    'bank_name': bankController.text,
                    'account_number': accountController.text,
                    'ifsc_code': ifscController.text.toUpperCase(),
                    'is_primary': _cards.isEmpty,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Indian bank account added successfully! You can now receive INR payments.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Account'),
          ),
        ],
      ),
    );
  }
}
