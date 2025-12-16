import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exchange_provider.dart';
import '../../widgets/login_popup.dart';
import '../../widgets/amount_chip.dart';
import '../../widgets/rate_chart.dart';
import '../../widgets/animated_avatar.dart';
import '../../widgets/theme_icons.dart';
import '../../widgets/custom_icons.dart';

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
  double _lastKnownRate = 0.0;
  
  // System updates and notifications
  final List<Map<String, dynamic>> _updates = [
    {
      'text': 'Exchange rate updated • Current: 100 BDT = ₹69.97',
      'icon': '🔄', // sync
      'color': Color(0xFF6366F1),
    },
    {
      'text': 'System maintenance scheduled • Tonight 2:00 AM - 3:00 AM',
      'icon': '🔧', // build
      'color': Color(0xFFF59E0B),
    },
    {
      'text': 'New security features enabled • Enhanced account protection',
      'icon': '🔒', // security
      'color': Color(0xFF10B981),
    },
    {
      'text': 'Transaction processing time • Average: 2-5 minutes',
      'icon': '⏰', // schedule
      'color': Color(0xFF8B5CF6),
    },
    {
      'text': 'Daily transaction limit • Exchange up to ৳100,000',
      'icon': 'ℹ️', // info_outline
      'color': Color(0xFF06B6D4),
    },
    {
      'text': 'KYC verification required • Complete for higher limits',
      'icon': '🛡️', // verified_user
      'color': Color(0xFF10B981),
    },
    {
      'text': 'Customer support available • 24/7 live chat assistance',
      'icon': '🎧', // support_agent
      'color': Color(0xFFEC4899),
    },
    {
      'text': 'Payment methods • bKash, Nagad, Rocket accepted',
      'icon': '💰', // payment
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
      
      // Store the current rate to detect actual changes
      _lastKnownRate = exchangeProvider.baseRate;
      
      // Add listener to exchange provider for rate changes
      exchangeProvider.addListener(_onExchangeRateChanged);
    });
  }
  
  void _onExchangeRateChanged() {
    if (!mounted) return;
    
    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    
    // Only proceed if the rate actually changed (not just countdown updates)
    if ((exchangeProvider.baseRate - _lastKnownRate).abs() < 0.0001) {
      return; // No significant rate change, ignore this notification
    }
    
    _lastKnownRate = exchangeProvider.baseRate;
    final targetInrBalance = _demoBdtBalance * exchangeProvider.baseRate;
    
    // Also update the converted amount if user has entered an amount
    final enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount != null && enteredAmount > 0) {
      setState(() {
        _convertedAmount = exchangeProvider.quickCalculate(enteredAmount);
        _appliedRate = exchangeProvider.baseRate;
      });
    }
    
    // Only animate balance if there's a significant change and not already updating
    if ((targetInrBalance - _animatedInrBalance).abs() > 0.01 && !_isInrBalanceUpdating) {
      setState(() {
        _isInrBalanceUpdating = true;
      });
      
      // Add a small delay to prevent simultaneous loading with other elements
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        
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
        child: RepaintBoundary(
          child: CustomScrollView(
            // Super smooth scroll physics
            physics: const ClampingScrollPhysics(),
            cacheExtent: 1000, // Pre-render more content for smoother scroll
            slivers: [
            // Header Section - Clean Professional Design
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      children: [
                        // Top Row: Avatar + User Info + Actions
                        Row(
                          children: [
                            // Avatar
                            AnimatedAvatar(
                              size: 44,
                              userName: user?.fullName ?? user?.email ?? 'User',
                            ),
                            const SizedBox(width: 12),
                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${user?.fullName?.split(' ').first ?? 'User'} 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Welcome to BDPayX',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Action Buttons
                            _buildHeaderButton(
                              Icons.headset_mic_rounded,
                              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
                            ),
                            const SizedBox(width: 8),
                            _buildHeaderButton(
                              Icons.notifications_outlined,
                              () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('No new notifications'),
                                  backgroundColor: const Color(0xFF6366F1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Live Rate Chart Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Top Row: Rate + Live Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Rate Display
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹ ${(exchangeProvider.baseRate * 100).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Color(0xFF1E293B),
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 6, bottom: 4),
                                        child: Text(
                                          '/100 BDT',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Live Badge with Timer
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'LIVE • ${exchangeProvider.countdown}s',
                                          style: const TextStyle(
                                            color: Color(0xFF10B981),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Mini Chart - Professional Theme-Friendly Design
                              SizedBox(
                                height: 80,
                                width: double.infinity,
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                    isComplex: true,
                                    willChange: false,
                                    painter: _ProfessionalSparklinePainter(
                                      data: exchangeProvider.rateHistory.isNotEmpty
                                          ? exchangeProvider.rateHistory.map((e) => e * 100).toList()
                                          : [70.0, 69.8, 70.2, 69.9, 70.1, 70.0, 69.95, 70.05],
                                      primaryColor: const Color(0xFF6366F1),
                                      secondaryColor: const Color(0xFF8B5CF6),
                                    ),
                                    size: const Size(double.infinity, 80),
                                  ),
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
                                _isBalanceHidden 
                                  ? CustomIcons.visibilityOff(color: const Color(0xFF64748B), size: 16)
                                  : CustomIcons.visibility(color: const Color(0xFF64748B), size: 16),
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
                            _isBalanceHidden ? '৳ ****' : '৳ ${_demoBdtBalance.toStringAsFixed(2)}',
                            const Color(0xFF10B981),
                            null, // Use custom BDT symbol instead of icon
                            false,
                            showDemoBadge: true,
                            currencySymbol: '৳',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBalanceCard(
                            'INR Balance',
                            _isBalanceHidden ? '₹ ****' : '₹ ${_animatedInrBalance.toStringAsFixed(2)}',
                            const Color(0xFF8B5CF6),
                            null, // Will use currencySymbol instead
                            true,
                            showDemoBadge: false,
                            currencySymbol: '₹',
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
                        null, // We'll use custom icon
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
                        null, // We'll use custom icon
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
                        null, // We'll use custom icon
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
                                      CustomIcons.sync(color: const Color(0xFF10B981), size: 14),
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
              child: RepaintBoundary(
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
                            child: CustomIcons.showChart(
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
                            child: Row(
                              children: [
                                ThemeIcons.trendingUp(color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                const Text(
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
                              child: Text(
                                _updates[_currentUpdateIndex]['icon'],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: _updates[_currentUpdateIndex]['color'],
                                ),
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
                            CustomIcons.arrowForwardIos(
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
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color, IconData? icon, bool isAnimated, {bool showDemoBadge = false, String? currencySymbol}) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: currencySymbol != null 
                  ? Text(
                      currencySymbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 22),
              ),
              if (isAnimated)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isInrBalanceUpdating 
                        ? const Color(0xFF3B82F6).withOpacity(0.9)
                        : Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isInrBalanceUpdating)
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                        _isInrBalanceUpdating ? 'SYNC' : 'LIVE',
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
          const SizedBox(height: 18),
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

  Widget _buildQuickAction(String title, IconData? icon, Color color, VoidCallback onTap) {
    Widget iconWidget;
    
    // Use custom emoji icons based on title
    switch (title) {
      case 'Deposit':
        iconWidget = CustomIcons.addCard(color: color, size: 28);
        break;
      case 'Withdraw':
        iconWidget = CustomIcons.accountBalance(color: color, size: 28);
        break;
      case 'Invite':
        iconWidget = CustomIcons.cardGiftcard(color: color, size: 28);
        break;
      default:
        iconWidget = icon != null 
          ? Icon(icon, color: color, size: 28)
          : CustomIcons.info(color: color, size: 28);
    }
    
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
            iconWidget,
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

// Professional Sparkline Graph Painter with Theme Colors
class _ProfessionalSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color primaryColor;
  final Color secondaryColor;

  _ProfessionalSparklinePainter({
    required this.data,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final effectiveRange = range == 0 ? 1.0 : range;
    final padding = 8.0;

    // Calculate points with padding
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * (size.width - padding * 2);
      final normalizedY = (data[i] - minValue) / effectiveRange;
      final y = size.height - padding - (normalizedY * (size.height - padding * 2));
      points.add(Offset(x, y));
    }

    // Draw subtle grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    for (int i = 0; i <= 3; i++) {
      final y = padding + (i / 3) * (size.height - padding * 2);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Create smooth bezier curve path
    final curvePath = Path();
    curvePath.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      curvePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Draw gradient fill under curve
    final fillPath = Path.from(curvePath);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(points.first.dx, size.height);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withValues(alpha: 0.25),
        secondaryColor.withValues(alpha: 0.08),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw gradient line with glow effect
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(curvePath, glowPaint);

    // Draw main gradient line
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(curvePath, linePaint);

    // Draw data points
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isLast = i == points.length - 1;
      
      if (isLast) {
        // Animated pulse effect for last point
        final outerGlow = Paint()
          ..color = secondaryColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 8, outerGlow);
        
        final outerDot = Paint()
          ..color = secondaryColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 5, outerDot);
        
        final innerDot = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 2.5, innerDot);
      } else {
        // Small dots for other points
        final dotPaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 2, dotPaint);
      }
    }

    // Draw min/max labels
    final textStyle = TextStyle(
      color: const Color(0xFF94A3B8),
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );
    
    final maxTextPainter = TextPainter(
      text: TextSpan(text: maxValue.toStringAsFixed(2), style: textStyle),
      textDirection: TextDirection.ltr,
    );
    maxTextPainter.layout();
    maxTextPainter.paint(canvas, Offset(size.width - maxTextPainter.width - 4, padding - 2));
    
    final minTextPainter = TextPainter(
      text: TextSpan(text: minValue.toStringAsFixed(2), style: textStyle),
      textDirection: TextDirection.ltr,
    );
    minTextPainter.layout();
    minTextPainter.paint(canvas, Offset(size.width - minTextPainter.width - 4, size.height - padding - 8));
  }

  @override
  bool shouldRepaint(covariant _ProfessionalSparklinePainter oldDelegate) {
    return oldDelegate.data != data || 
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.secondaryColor != secondaryColor;
  }
}
