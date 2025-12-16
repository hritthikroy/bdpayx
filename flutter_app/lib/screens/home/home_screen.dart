import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exchange_provider.dart';
import '../../widgets/login_popup.dart';
import '../../widgets/amount_chip.dart';
import '../../widgets/rate_chart.dart';
import '../../widgets/animated_avatar.dart';
import '../../widgets/animated_number.dart';
import '../exchange/payment_screen.dart';
import '../wallet/deposit_screen.dart';
import '../wallet/withdraw_screen.dart';
import '../referral/referral_screen.dart';
import '../chat/support_screen.dart';

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
  late AnimationController _inrBalanceAnimationController;
  late Animation<double> _inrBalanceAnimation;

  int _currentUpdateIndex = 0;
  final List<int> _shownUpdates = [];
  bool _isBalanceHidden = false;
  double _animatedInrBalance = 0.0;
  final double _demoBdtBalance = 100.0;
  bool _isInrBalanceUpdating = false;
  
  // System updates and notifications
  final List<Map<String, dynamic>> _updates = [
    {
      'text': 'Exchange rate updated • Current: 100 BDT = ₹69.97',
      'icon': Icons.sync,
      'color': Color(0xFF6366F1),
    },
    {
      'text': 'System maintenance scheduled • Tonight 2:00 AM - 3:00 AM',
      'icon': Icons.build,
      'color': Color(0xFFF59E0B),
    },
    {
      'text': 'New security features enabled • Enhanced account protection',
      'icon': Icons.security,
      'color': Color(0xFF10B981),
    },
    {
      'text': 'Transaction processing time • Average: 2-5 minutes',
      'icon': Icons.schedule,
      'color': Color(0xFF8B5CF6),
    },
    {
      'text': 'Daily transaction limit • Exchange up to ৳100,000',
      'icon': Icons.info_outline,
      'color': Color(0xFF06B6D4),
    },
    {
      'text': 'KYC verification required • Complete for higher limits',
      'icon': Icons.verified_user,
      'color': Color(0xFF10B981),
    },
    {
      'text': 'Customer support available • 24/7 live chat assistance',
      'icon': Icons.support_agent,
      'color': Color(0xFFEC4899),
    },
    {
      'text': 'Payment methods • bKash, Nagad, Rocket accepted',
      'icon': Icons.payment,
      'color': Color(0xFF8B5CF6),
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
    
    _inrBalanceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _startUpdateRotation();
    
    // Initialize INR balance and listen to exchange rate changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
      _animatedInrBalance = _demoBdtBalance * exchangeProvider.baseRate;
      
      // Add listener to exchange provider for rate changes
      exchangeProvider.addListener(_onExchangeRateChanged);
    });
  }
  
  void _onExchangeRateChanged() {
    if (!mounted) return;
    
    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    final targetInrBalance = _demoBdtBalance * exchangeProvider.baseRate;
    
    // Also update the converted amount if user has entered an amount
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount != null && enteredAmount > 0) {
      setState(() {
        _convertedAmount = exchangeProvider.quickCalculate(enteredAmount);
        _appliedRate = exchangeProvider.baseRate;
      });
    }
    
    // Only animate balance if there's a significant change
    if ((targetInrBalance - _animatedInrBalance).abs() > 0.01) {
      setState(() {
        _isInrBalanceUpdating = true;
      });
      
      // Animate the number counting - smooth and simple
      _inrBalanceAnimation = Tween<double>(
        begin: _animatedInrBalance,
        end: targetInrBalance,
      ).animate(CurvedAnimation(
        parent: _inrBalanceAnimationController,
        curve: Curves.easeInOutCubic,
      ))..addListener(() {
        if (mounted) {
          setState(() {
            _animatedInrBalance = _inrBalanceAnimation.value;
          });
        }
      });
      
      _inrBalanceAnimationController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _isInrBalanceUpdating = false;
          });
        }
      });
    }
  }
  

  
  void _startUpdateRotation() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          int nextIndex;
          do {
            nextIndex = DateTime.now().millisecondsSinceEpoch % _updates.length;
          } while (_shownUpdates.contains(nextIndex) && _shownUpdates.length < _updates.length);
          
          _currentUpdateIndex = nextIndex;
          _shownUpdates.add(nextIndex);
          
          if (_shownUpdates.length >= _updates.length) {
            _shownUpdates.clear();
          }
        });
        _startUpdateRotation();
      }
    });
  }

  @override
  void dispose() {
    // Remove listener from exchange provider
    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    exchangeProvider.removeListener(_onExchangeRateChanged);
    
    _cardAnimationController.dispose();
    _inrBalanceAnimationController.dispose();
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
    // Use Selector for minimal rebuilds - only rebuild when specific values change
    final user = context.select<AuthProvider, dynamic>((p) => p.user);
    final exchangeProvider = context.watch<ExchangeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          // Ultra-fast scroll physics for 120fps feel
          physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
          cacheExtent: 500, // Pre-render more content
          slivers: [
            // App Bar - More Compact and Gorgeous
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: false,
              backgroundColor: const Color(0xFF6366F1),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.03),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      // Animated Avatar with Blinking Eyes
                                      AnimatedAvatar(
                                        size: 50,
                                        userName: user?.fullName ?? user?.email ?? 'User',
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
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              'BDPayX Exchange',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const SupportScreen(),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.support_agent_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('No new notifications'),
                                            backgroundColor: const Color(0xFF6366F1),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.notifications_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.trending_up_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    '100 BDT = ₹${(exchangeProvider.baseRate * 100).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        TweenAnimationBuilder<double>(
                                          tween: Tween(
                                            begin: exchangeProvider.countdown / 60,
                                            end: exchangeProvider.countdown / 60,
                                          ),
                                          duration: const Duration(milliseconds: 800),
                                          curve: Curves.easeInOut,
                                          builder: (context, value, child) {
                                            return SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                value: value,
                                                strokeWidth: 2,
                                                backgroundColor: Colors.white.withOpacity(0.3),
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  exchangeProvider.countdown > 10
                                                      ? Colors.white
                                                      : const Color(0xFFEF4444),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 300),
                                          transitionBuilder: (child, animation) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: ScaleTransition(
                                                scale: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            '${exchangeProvider.countdown}s',
                                            key: ValueKey(exchangeProvider.countdown),
                                            style: TextStyle(
                                              color: exchangeProvider.countdown > 10
                                                  ? Colors.white
                                                  : const Color(0xFFFFCDD2),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Balance Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Balances',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isBalanceHidden = !_isBalanceHidden;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isBalanceHidden ? Icons.visibility_off : Icons.visibility,
                                  size: 16,
                                  color: const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isBalanceHidden ? 'Show' : 'Hide',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceCard(
                            'BDT Balance',
                            _isBalanceHidden ? '৳****' : '৳${_demoBdtBalance.toStringAsFixed(2)}',
                            const Color(0xFF10B981),
                            Icons.account_balance_wallet,
                            false,
                            showDemoBadge: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBalanceCard(
                            'INR Balance',
                            _isBalanceHidden ? '₹****' : '₹${_animatedInrBalance.toStringAsFixed(2)}',
                            const Color(0xFF8B5CF6),
                            Icons.currency_rupee,
                            true,
                            showDemoBadge: false,
                          ),
                        ),
                      ],
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
                        // Auto-updating rate info bar (no manual refresh needed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              // Auto-sync icon with animation
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(seconds: exchangeProvider.countdown),
                                builder: (context, value, child) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          value: 1 - (exchangeProvider.countdown / 60),
                                          strokeWidth: 2.5,
                                          backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                        ),
                                      ),
                                      const Icon(Icons.sync, color: Color(0xFF10B981), size: 14),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Live Rate • Auto Updates',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: Text(
                                        'Next update in ${exchangeProvider.countdown}s',
                                        key: ValueKey(exchangeProvider.countdown),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Live indicator
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.5),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        fontSize: 10,
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B), // Darker color for better visibility
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter BDT Amount',
                            labelStyle: const TextStyle(
                              color: Color(0x991E293B), // Semi-transparent dark color
                            ),
                            prefixText: '৳ ',
                            prefixStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B), // Darker color for better visibility
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF), // Pure white background for contrast
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
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

            // Rate Chart Section - Eye-Catching Design
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                            Color(0xFFA855F7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.show_chart_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Live Rate Analytics',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '24-hour trend visualization',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.trending_up, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    RateChart(currentRate: exchangeProvider.baseRate),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Live Updates Section
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

            // Bottom padding to prevent overlap with bottom navigation
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color, IconData icon, bool isAnimated, {bool showDemoBadge = false}) {
    Widget cardContent = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              if (isAnimated)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isInrBalanceUpdating 
                        ? const Color(0xFF10B981).withOpacity(0.9)
                        : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isInrBalanceUpdating)
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        _isInrBalanceUpdating ? 'UPDATING' : 'LIVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              if (showDemoBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    return cardContent;
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
