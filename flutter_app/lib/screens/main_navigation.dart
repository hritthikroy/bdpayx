import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/animated_nav_icons.dart';
import '../services/app_lock_service.dart';
import 'home/home_screen.dart';
import 'transactions/transactions_screen.dart';
import 'chat/support_screen.dart';
import 'profile/profile_screen.dart';
import 'alerts/rate_alerts_screen.dart';
import 'security/app_lock_screen.dart';
import 'security/setup_pin_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 2; // Start with Home (center button)
  final List<GlobalKey> _navKeys = List.generate(5, (_) => GlobalKey());
  late AnimationController _waveController;
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;
  late List<Animation<double>> _bounceAnimations;
  bool _isLocked = false;
  final AppLockService _appLockService = AppLockService();

  // Cache screens for instant switching - no rebuild
  late final List<Widget> _screens = [
    const TransactionsScreen(),
    const SupportScreen(),
    const HomeScreen(),
    const RateAlertsScreen(),
    const ProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.history_rounded, label: 'History', color: Color(0xFF10B981)),
    NavItem(icon: Icons.support_agent_rounded, label: 'Support', color: Color(0xFF06B6D4)),
    NavItem(icon: Icons.home_rounded, label: 'Home', color: Color(0xFF6366F1)), // Center button - Home
    NavItem(icon: Icons.notifications_rounded, label: 'Alerts', color: Color(0xFFF59E0B)),
    NavItem(icon: Icons.account_circle_rounded, label: 'Profile', color: Color(0xFFEC4899)),
  ];

  @override
  void initState() {
    super.initState();
    
    // Minimal sync initialization - only what's needed for first frame
    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    // Fast animation controller setup
    _iconControllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400), // Faster animations
        vsync: this,
      ),
    );

    // Simplified scale animations
    _scaleAnimations = _iconControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      );
    }).toList();

    // Simplified rotation animations
    _rotationAnimations = _iconControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 0.0).animate(controller);
    }).toList();

    // Simplified bounce animations
    _bounceAnimations = _iconControllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -6.0), weight: 40),
        TweenSequenceItem(tween: Tween<double>(begin: -6.0, end: 0.0), weight: 60),
      ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    }).toList();
    
    // Defer heavy initialization to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _deferredInit());
  }
  
  void _deferredInit() {
    if (!mounted) return;
    
    // Initialize providers in background
    try {
      final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      exchangeProvider.initialize();
      authProvider.loadToken();
    } catch (e) {
      debugPrint('Provider init error: $e');
    }
    
    // Initialize app lock service
    _appLockService.initialize(() {
      if (mounted) setState(() => _isLocked = true);
    });
    
    // Check PIN setup after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _checkPinSetup();
    });
  }

  Future<void> _checkPinSetup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Only show PIN setup if user is logged in
    if (!authProvider.isAuthenticated) return;
    
    final shouldShow = await _appLockService.shouldShowPinSetup();
    if (shouldShow && mounted) {
      // Wait a bit for the UI to settle
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        _showPinSetupDialog();
      }
    }
  }

  void _showPinSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.security, color: Color(0xFF8B5CF6)),
            SizedBox(width: 12),
            Text('Secure Your Account'),
          ],
        ),
        content: const Text(
          'Set up a 4-digit PIN to protect your transactions and secure your account.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _appLockService.markPinSetupShown();
              Navigator.pop(context);
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SetupPinScreen(),
                ),
              );
              if (result == true) {
                _appLockService.markPinSetupShown();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction PIN set successfully! 🎉'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Set Up Now'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _appLockService.dispose();
    _waveController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Use IndexedStack for instant tab switching - keeps all screens alive
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(child: _buildNavBar()),
          ),
          // App lock overlay
          if (_isLocked)
            Positioned.fill(
              child: AppLockScreen(
                onUnlock: () {
                  _appLockService.unlock();
                  setState(() {
                    _isLocked = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Clean, professional navigation bar
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E293B).withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: const Color(0xFF1E293B).withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0), // History
                  _buildNavItem(1), // Support
                  const SizedBox(width: 64), // Space for floating button
                  _buildNavItem(3), // Alerts
                  _buildNavItem(4), // Profile
                ],
              ),
            ),
            // Floating center button (perfectly centered)
            Positioned(
              top: -14,
              child: _buildFloatingCenterButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCenterButton() {
    final centerIndex = 2; // Middle button
    final item = _navItems[centerIndex];
    final isSelected = _currentIndex == centerIndex;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = centerIndex);
        _iconControllers[centerIndex].forward(from: 0.0);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, isSelected ? -2 : 4, 0),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? item.color : Colors.white,
            border: Border.all(
              color: isSelected ? item.color : const Color(0xFFE2E8F0),
              width: isSelected ? 0 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? item.color.withOpacity(0.3)
                    : const Color(0xFF1E293B).withOpacity(0.12),
                blurRadius: isSelected ? 16 : 12,
                offset: const Offset(0, 4),
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _iconControllers[centerIndex],
            builder: (context, child) {
              final scaleValue = 1.0 + (_scaleAnimations[centerIndex].value - 1.0) * 0.5;
              final bounceValue = _bounceAnimations[centerIndex].value * 0.25;
              
              return Transform.scale(
                scale: scaleValue,
                child: Transform.translate(
                  offset: Offset(0, bounceValue),
                  child: Icon(
                    Icons.home_rounded,
                    size: 28,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    // Skip center button (index 2) as it's the floating button
    if (index == 2) return const SizedBox.shrink();
    
    final isSelected = _currentIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _iconControllers[index].forward(from: 0.0);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: AnimatedBuilder(
          animation: _iconControllers[index],
          builder: (context, child) {
            final bounceValue = _bounceAnimations[index].value * 0.4;
            final scaleValue = _scaleAnimations[index].value;
            
            return Transform.translate(
              offset: Offset(0, bounceValue),
              child: Transform.scale(
                scale: scaleValue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clean icon without glow
                    _buildCustomIcon(index, isSelected),
                    const SizedBox(height: 4),
                    // Simple indicator bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: isSelected ? 20 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomIcon(int index, bool isSelected) {
    final item = _navItems[index];
    // Use item color for selected, dark gray for unselected
    final color = isSelected ? item.color : const Color(0xFF64748B);
    final progress = _iconControllers[index].value;

    switch (index) {
      case 0: // History
        return AnimatedHistoryIcon(
          isSelected: isSelected,
          color: color,
          progress: progress,
        );
      case 1: // Support
        return AnimatedSupportIcon(
          isSelected: isSelected,
          color: color,
          progress: progress,
        );
      case 2: // Home (Center button)
        return AnimatedHomeIcon(
          isSelected: isSelected,
          color: color,
          progress: progress,
        );
      case 3: // Alerts
        return AnimatedAlertsIcon(
          isSelected: isSelected,
          color: color,
          progress: progress,
        );
      case 4: // Profile
        return AnimatedProfileIcon(
          isSelected: isSelected,
          color: color,
          progress: progress,
        );
      default:
        return Icon(
          _navItems[index].icon,
          color: color,
          size: 26,
        );
    }
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final Color color;

  NavItem({required this.icon, required this.label, required this.color});
}


