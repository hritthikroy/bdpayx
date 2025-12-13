import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import '../referral/referral_screen.dart';
import '../../widgets/platform_advantages.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _bdtBalance = 0;
  double _inrBalance = 0;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    // TODO: Implement API calls
    setState(() {
      _bdtBalance = 0;
      _inrBalance = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with balances
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'My Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceCard(
                          'BDT Balance',
                          '৳${_bdtBalance.toStringAsFixed(2)}',
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBalanceCard(
                          'INR Balance',
                          '₹${_inrBalance.toStringAsFixed(2)}',
                          Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction(
                    icon: Icons.add_card,
                    label: 'Deposit',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DepositScreen()),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.money,
                    label: 'Withdraw',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WithdrawScreen()),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.card_giftcard,
                    label: 'Invite',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReferralScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Live Transaction Notification
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volume_up, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${DateFormat('HH:mm').format(DateTime.now())} User exchanged ৳5,000 to ₹3,500',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),

            // Transaction history
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _transactions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        return _buildTransactionItem(tx);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String label, String amount, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: const Color(0xFF1E3A8A)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tx['type'] == 'deposit'
              ? Colors.green.shade50
              : Colors.red.shade50,
          child: Icon(
            tx['type'] == 'deposit' ? Icons.add : Icons.remove,
            color: tx['type'] == 'deposit' ? Colors.green : Colors.red,
          ),
        ),
        title: Text(tx['description']),
        subtitle: Text(tx['date']),
        trailing: Text(
          '${tx['type'] == 'deposit' ? '+' : '-'}৳${tx['amount']}',
          style: TextStyle(
            color: tx['type'] == 'deposit' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
