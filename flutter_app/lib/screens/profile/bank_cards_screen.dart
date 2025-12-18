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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Bank Accounts'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _cards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance, size: 64, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No Indian bank accounts added', 
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Add your Indian bank account to receive INR payments from exchanges',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddCardDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Indian Bank Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
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
                  color: colorScheme.surface,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark 
                            ? [colorScheme.primary.withOpacity(0.8), colorScheme.secondary.withOpacity(0.6)]
                            : [colorScheme.primary, colorScheme.secondary],
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
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Add Indian Bank Account',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark 
                      ? colorScheme.primary.withOpacity(0.1)
                      : colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add your Indian bank account to receive INR payments',
                        style: TextStyle(fontSize: 12, color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.person, color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bankController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Bank Name',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  hintText: 'e.g., HDFC Bank, ICICI Bank, SBI',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.account_balance, color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.numbers, color: colorScheme.onSurfaceVariant),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ifscController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'IFSC Code',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  hintText: 'e.g., HDFC0001234',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.code, color: colorScheme.onSurfaceVariant),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSurfaceVariant)),
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
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Add Account'),
          ),
        ],
      ),
    );
  }
}
