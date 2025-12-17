import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';

class PaymentScreen extends StatefulWidget {
  final double fromAmount;
  final double toAmount;
  final double exchangeRate;

  const PaymentScreen({
    super.key,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'bank_transfer';
  String? _proofPath;
  int? _transactionId;
  Map<String, dynamic>? _selectedBankAccount;
  final List<Map<String, dynamic>> _savedBankAccounts = [];

  Future<void> _createTransaction() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    final transaction = await transactionProvider.createTransaction(
      authProvider.token!,
      widget.fromAmount,
      widget.toAmount,
      widget.exchangeRate,
      _selectedMethod,
    );

    if (transaction != null) {
      setState(() => _transactionId = transaction.id);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _proofPath = image.path);
    }
  }

  Future<void> _uploadProof() async {
    if (_proofPath == null || _transactionId == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    final success = await transactionProvider.uploadPaymentProof(
      authProvider.token!,
      _transactionId!,
      _proofPath!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment proof uploaded successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _createTransaction();
    _loadSavedBankAccounts();
  }

  void _loadSavedBankAccounts() {
    // TODO: Load from API/SharedPreferences
    // For now, using dummy data
    setState(() {
      _savedBankAccounts.addAll([
        {
          'id': 1,
          'account_holder_name': 'John Doe',
          'bank_name': 'HDFC Bank',
          'account_number': '1234567890',
          'ifsc_code': 'HDFC0001234',
          'is_primary': true,
        },
      ]);
      if (_savedBankAccounts.isNotEmpty) {
        _selectedBankAccount = _savedBankAccounts.firstWhere(
          (acc) => acc['is_primary'] == true,
          orElse: () => _savedBankAccounts.first,
        );
      }
    });
  }

  void _showBankAccountSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Bank Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._savedBankAccounts.map((account) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: Text(account['bank_name']),
                  subtitle: Text('${account['account_holder_name']}\nA/C: ****${account['account_number'].toString().substring(account['account_number'].toString().length - 4)}'),
                  trailing: _selectedBankAccount?['id'] == account['id']
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() => _selectedBankAccount = account);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showAddBankAccountDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Account'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBankAccountDialog() {
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
              const Text(
                'Add your Indian bank account to receive INR payments',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bankController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  hintText: 'e.g., HDFC Bank, ICICI Bank',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
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
                  final newAccount = {
                    'id': _savedBankAccounts.length + 1,
                    'account_holder_name': nameController.text,
                    'bank_name': bankController.text,
                    'account_number': accountController.text,
                    'ifsc_code': ifscController.text.toUpperCase(),
                    'is_primary': _savedBankAccounts.isEmpty,
                  };
                  _savedBankAccounts.add(newAccount);
                  _selectedBankAccount = newAccount;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bank account added successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
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
                children: [
                  const Text('Transaction Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('You send:'),
                      Text('৳${widget.fromAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('You receive:'),
                      Text('₹${widget.toAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rate:'),
                      Text('${widget.exchangeRate.toStringAsFixed(4)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Your Indian Bank Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('INR will be sent to this account', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            if (_selectedBankAccount != null)
              Container(
                padding: const EdgeInsets.all(16),
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
                          _selectedBankAccount!['bank_name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () {
                            _showBankAccountSelector();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A/C: **** **** ${_selectedBankAccount!['account_number'].toString().substring(_selectedBankAccount!['account_number'].toString().length - 4)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedBankAccount!['account_holder_name'],
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'IFSC: ${_selectedBankAccount!['ifsc_code']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _showAddBankAccountDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Indian Bank Account'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            const SizedBox(height: 24),
            const Text('Payment Method (BDT)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('How will you pay BDT?', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            RadioListTile(
              title: const Text('bKash'),
              subtitle: const Text('Mobile banking'),
              value: 'bkash',
              groupValue: _selectedMethod,
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
            RadioListTile(
              title: const Text('Bank Transfer'),
              subtitle: const Text('Bangladesh bank transfer'),
              value: 'bank_transfer',
              groupValue: _selectedMethod,
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
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
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('Payment Instructions (BDT)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedMethod == 'bkash') ...[
                    const Text('bKash Number: 01712345678', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Account Type: Merchant'),
                    const SizedBox(height: 8),
                    Text('Amount to send: ৳${widget.fromAmount.toStringAsFixed(2)}', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  ] else ...[
                    const Text('Bank: Dutch-Bangla Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Account: 1234567890'),
                    const Text('Branch: Dhaka'),
                    const Text('Account Holder: BDPayX Ltd'),
                    const SizedBox(height: 8),
                    Text('Amount to transfer: ৳${widget.fromAmount.toStringAsFixed(2)}', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Text('1. Send exact BDT amount', style: TextStyle(fontSize: 12)),
                        const Text('2. Take screenshot of confirmation', style: TextStyle(fontSize: 12)),
                        const Text('3. Upload proof below', style: TextStyle(fontSize: 12)),
                        const Text('4. INR will be sent to your bank account', style: TextStyle(fontSize: 12, color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: Text(_proofPath == null ? 'Upload Payment Proof' : 'Proof Selected'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedBankAccount == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please add your Indian bank account to receive INR',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _proofPath != null && _selectedBankAccount != null ? _uploadProof : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text('Submit Payment Proof', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedBankAccount != null 
                ? '₹${widget.toAmount.toStringAsFixed(2)} will be sent to ${_selectedBankAccount!['bank_name']}'
                : 'Add bank account to proceed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: _selectedBankAccount != null ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
