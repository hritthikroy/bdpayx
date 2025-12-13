import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'bkash';
  String? _proofPath;
  bool _isSubmitting = false;

  final Map<String, Map<String, String>> _paymentMethods = {
    'bkash': {
      'name': 'bKash',
      'icon': '📱',
      'number': '01712345678',
      'type': 'Personal',
    },
    'bank_transfer': {
      'name': 'Bank Transfer',
      'icon': '🏦',
      'account': '1234567890',
      'bank': 'HDFC Bank',
      'ifsc': 'HDFC0001234',
    },
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _proofPath = image.path);
    }
  }

  Future<void> _submitDeposit() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount')),
      );
      return;
    }

    if (_proofPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload payment proof')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Implement API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deposit request submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit BDT'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Icon(Icons.account_balance_wallet, size: 48, color: Color(0xFF3B82F6)),
                  SizedBox(height: 12),
                  Text(
                    'Add Money to Wallet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Deposit BDT to your wallet for fast currency exchange',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount (BDT)',
                prefixText: '৳ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard('bkash'),
            const SizedBox(height: 12),
            _buildPaymentMethodCard('bank_transfer'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Payment Instructions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedMethod == 'bkash') ...[
                    Text('1. Open bKash app'),
                    Text('2. Send Money to: ${_paymentMethods['bkash']!['number']}'),
                    Text('3. Enter amount: ৳${_amountController.text.isEmpty ? '0' : _amountController.text}'),
                    Text('4. Complete payment'),
                    Text('5. Take screenshot of confirmation'),
                    Text('6. Upload screenshot below'),
                  ] else ...[
                    Text('Bank: ${_paymentMethods['bank_transfer']!['bank']}'),
                    Text('Account: ${_paymentMethods['bank_transfer']!['account']}'),
                    Text('IFSC: ${_paymentMethods['bank_transfer']!['ifsc']}'),
                    const SizedBox(height: 8),
                    const Text('Transfer the exact amount and upload payment proof'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: Icon(_proofPath != null ? Icons.check_circle : Icons.upload_file),
              label: Text(_proofPath != null ? 'Payment Proof Uploaded' : 'Upload Payment Proof'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: _proofPath != null ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitDeposit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Deposit Request', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(String method) {
    final info = _paymentMethods[method]!;
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Text(info['icon']!, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method == 'bkash'
                        ? info['number']!
                        : info['bank']!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF3B82F6)),
          ],
        ),
      ),
    );
  }
}
