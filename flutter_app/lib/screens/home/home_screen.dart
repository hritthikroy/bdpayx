import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exchange_provider.dart';
import '../../widgets/login_popup.dart';
import '../../widgets/amount_chip.dart';
import '../exchange/payment_screen.dart';
import '../wallet/deposit_screen.dart';
import '../wallet/withdraw_screen.dart';
import '../transactions/transactions_screen.dart';
import '../referral/referral_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  double _convertedAmount = 0;
  double _appliedRate = 0;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;
  int _currentUpdateIndex = 0;
  
  // Dynamic updates list
  final List<Map<String, dynamic>> _updates = [
    {
      'text': 'User exchanged ৳10,000 to ₹6,997 • Fast & Secure',
      'icon': Icons.check_circle,
      'color': Color(0xFF10B981),
    },
    {
      'text': 'New user from Dhaka joined • Welcome bonus active!',
      'icon': Icons.celebration,
      'color': Color(0xFFF59E0B),
    },
    {
      'text': '₹50,000 exchanged today • Join the community!',
      'icon': Icons.trending_up,
      'color': Color(0xFF6366F1),
    },
    {
      'text': 'Instant withdrawal processed • 2 mins ago',
      'icon': Icons.flash_on,
      'color': Color(0xFFEF4444),
    },
    {
      'text': 'Exchange rate improved • Best rates guaranteed!',
      'icon': Icons.star,
      'color': Color(0xFFFBBF24),
    },
    {
      'text': 'User from Chittagong exchanged ৳25,000 successfully',
      'icon': Icons.verified,
      'color': Color(0xFF10B981),
    },
    {
      'text': '100+ transactions completed today • Trusted platform',
      'icon': Icons.security,
      'color': Color(0xFF8B5CF6),
    },
    {
      'text': 'Referral bonus paid ৳500 • Invite friends now!',
      'icon': Icons.card_giftcard,
      'color': Color(0xFFEC4899),
    },
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateExchange);
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutBack,
    );
    _startUpdateRotation();
  }
  
  void _startUpdateRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentUpdateIndex = (_currentUpdateIndex + 1) % _updates.length;
        });
        _startUpdateRotation();
      }
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _calculateExchange() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _convertedAmount = 0;
        _appliedRate = 0;
      });
      _cardAnimationController.reverse();
      return;
    }

    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    
    setState(() {
      _convertedAmount = exchangeProvider.quickCalculate(amount);
      _appliedRate = exchangeProvider.baseRate;
    });
    
    _cardAnimationController.forward();
    
    final result = await exchangeProvider.calculateExchange(amount);
    if (result != null && mounted) {
      setState(() {
        _convertedAmount = double.parse(result['to_amount'].toString());
        _appliedRate = double.parse(result['exchange_rate'].toString());
      });
    }
  }

  Future<void> _proceedToPayment() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Check if user is logged in
    final isLoggedIn = await LoginPopup.show(
      context,
      message: 'Login to exchange BDT to INR',
    );
    
    if (!isLoggedIn) return;

    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    // Use listen: false to prevent unnecessary rebuilds
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF6366F1),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  // User Avatar - Professional with Cartoon Option
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: user?.photoUrl != null
                                          ? Image.network(
                                              user!.photoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                // Fallback to cartoon avatar
                                                return Image.network(
                                                  'https://api.dicebear.com/7.x/notionists/png?seed=${user.phone ?? user.id}&backgroundColor=6366f1,8b5cf6,a855f7',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, err, stack) {
                                                    // Final fallback to gradient
                                                    return Container(
                                                      decoration: const BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          colors: [
                                                            Color(0xFF6366F1),
                                                            Color(0xFF8B5CF6),
                                                            Color(0xFFA855F7),
                                                          ],
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          (user.fullName ?? 'U')[0].toUpperCase(),
                                                          style: const TextStyle(
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                            letterSpacing: 1,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            )
                                          : Image.network(
                                              'https://api.dicebear.com/7.x/notionists/png?seed=${user?.phone ?? user?.id ?? 'default'}&backgroundColor=6366f1,8b5cf6,a855f7',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                // Fallback to gradient
                                                return Container(
                                                  decoration: const BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFF6366F1),
                                                        Color(0xFF8B5CF6),
                                                        Color(0xFFA855F7),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      (user?.fullName ?? 'U')[0].toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello, ${user?.fullName?.split(' ').first ?? 'User'}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'BDPayX Exchange',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '1 BDT = ₹${exchangeProvider.baseRate.toStringAsFixed(4)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      value: exchangeProvider.countdown / 60,
                                      strokeWidth: 2,
                                      backgroundColor: Colors.white.withOpacity(0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        exchangeProvider.countdown > 10
                                            ? Colors.white
                                            : Colors.red.shade300,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${exchangeProvider.countdown}s',
                                    style: TextStyle(
                                      color: exchangeProvider.countdown > 10
                                          ? Colors.white
                                          : Colors.red.shade100,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Balance Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBalanceCard(
                        'BDT Balance',
                        '৳${user?.balance.toStringAsFixed(2) ?? '0.00'}',
                        const Color(0xFF10B981),
                        Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBalanceCard(
                        'INR Balance',
                        '₹0.00',
                        const Color(0xFF8B5CF6),
                        Icons.currency_rupee,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions (Deposit, Withdraw, Invite)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        'Deposit',
                        Icons.add_card,
                        const Color(0xFF10B981),
                        () async {
                          final isLoggedIn = await LoginPopup.show(
                            context,
                            message: 'Login to deposit BDT',
                          );
                          if (isLoggedIn && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DepositScreen()),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'Withdraw',
                        Icons.account_balance,
                        const Color(0xFF3B82F6),
                        () async {
                          final isLoggedIn = await LoginPopup.show(
                            context,
                            message: 'Login to withdraw funds',
                          );
                          if (isLoggedIn && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WithdrawScreen()),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'Invite',
                        Icons.card_giftcard,
                        const Color(0xFFF59E0B),
                        () async {
                          final isLoggedIn = await LoginPopup.show(
                            context,
                            message: 'Login to get your referral link',
                          );
                          if (isLoggedIn && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReferralScreen()),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Exchange Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Exchange BDT to INR',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Rate updates in ${exchangeProvider.countdown}s • Current: ${exchangeProvider.baseRate.toStringAsFixed(4)}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: exchangeProvider.countdown > 10
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        value: exchangeProvider.countdown / 60,
                                        strokeWidth: 2,
                                        backgroundColor: Colors.white.withOpacity(0.3),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${exchangeProvider.countdown}s',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Enter BDT Amount',
                            prefixText: '৳ ',
                            prefixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AmountChip(amount: '1,000', onTap: () => _amountController.text = '1000'),
                            AmountChip(amount: '5,000', onTap: () => _amountController.text = '5000'),
                            AmountChip(amount: '10,000', onTap: () => _amountController.text = '10000'),
                            AmountChip(amount: '25,000', onTap: () => _amountController.text = '25000'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Animated Result Card
                        ScaleTransition(
                          scale: _cardAnimation,
                          child: _convertedAmount > 0
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'You will receive',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '₹${_convertedAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rate: ${_appliedRate.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        
                        if (_convertedAmount > 0) const SizedBox(height: 20),
                        
                        ElevatedButton(
                          onPressed: _proceedToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue to Payment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Updates/Announcements Section (Dynamic)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Updates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_currentUpdateIndex),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _updates[_currentUpdateIndex]['color'].withOpacity(0.1),
                              _updates[_currentUpdateIndex]['color'].withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _updates[_currentUpdateIndex]['color'].withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _updates[_currentUpdateIndex]['color'].withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _updates[_currentUpdateIndex]['icon'],
                                color: _updates[_currentUpdateIndex]['color'],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _updates[_currentUpdateIndex]['text'],
                                style: TextStyle(
                                  color: _updates[_currentUpdateIndex]['color'].withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: _updates[_currentUpdateIndex]['color'],
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
