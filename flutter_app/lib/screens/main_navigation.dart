import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'home/home_screen.dart';
import 'transactions/transactions_screen.dart';
import 'chat/support_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  double _scrollOffset = 0.0;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _waveController;
  late AnimationController _rippleController;
  late List<AnimationController> _iconControllers;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const SupportScreen(),
    const ProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.home_rounded, label: 'Home', color: const Color(0xFF6366F1)),
    NavItem(icon: Icons.receipt_long_rounded, label: 'History', color: const Color(0xFF8B5CF6)),
    NavItem(icon: Icons.chat_bubble_rounded, label: 'Support', color: const Color(0xFFA855F7)),
    NavItem(icon: Icons.person_rounded, label: 'Profile', color: const Color(0xFFEC4899)),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _iconControllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    
    _iconControllers[0].forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _waveController.dispose();
    _rippleController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Main content
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                setState(() {
                  _scrollOffset = notification.metrics.pixels.clamp(0.0, 100.0);
                });
              }
              return false;
            },
            child: _screens[_currentIndex],
          ),
          // Top blue nav bar (appears on scroll)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _scrollOffset > 50 ? 0 : -80,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BDPayX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassNavBar(),
    );
  }

  Widget _buildGlassNavBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _navItems[_currentIndex].color.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Animated water flow background
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WaterFlowPainter(
                    animation: _waveController.value,
                    color: _navItems[_currentIndex].color,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            // Glass effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.7),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Navigation items
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _navItems.length,
                  (index) => _buildGlassNavItem(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassNavItem(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_currentIndex != index) {
            setState(() {
              _iconControllers[_currentIndex].reverse();
              _currentIndex = index;
              _iconControllers[index].forward();
            });
            _rippleController.forward(from: 0);
          }
        },
        child: AnimatedBuilder(
          animation: _iconControllers[index],
          builder: (context, child) {
            final scale = isSelected 
                ? 1.0 + (_iconControllers[index].value * 0.2)
                : 1.0;
            final rotation = _iconControllers[index].value * 0.1;
            
            return Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple effect
                          if (isSelected)
                            AnimatedBuilder(
                              animation: _rippleController,
                              builder: (context, child) {
                                return Container(
                                  width: 50 * (1 + _rippleController.value),
                                  height: 50 * (1 + _rippleController.value),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: item.color.withOpacity(
                                      0.2 * (1 - _rippleController.value),
                                    ),
                                  ),
                                );
                              },
                            ),
                          // Icon container with glass effect
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSelected
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        item.color.withOpacity(0.8),
                                        item.color.withOpacity(0.6),
                                      ],
                                    )
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: item.color.withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Label with fade animation
                      AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? item.color : const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final Color color;
  
  NavItem({required this.icon, required this.label, required this.color});
}

// Custom painter for water flow effect
class WaterFlowPainter extends CustomPainter {
  final double animation;
  final Color color;

  WaterFlowPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05),
          color.withOpacity(0.15),
        ],
        stops: [
          (animation - 0.3).clamp(0.0, 1.0),
          animation.clamp(0.0, 1.0),
          (animation + 0.3).clamp(0.0, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 8.0;
    final waveLength = size.width / 3;

    path.moveTo(0, size.height / 2);

    for (double i = 0; i <= size.width; i++) {
      final y = size.height / 2 +
          math.sin((i / waveLength + animation * 2 * math.pi) * 2 * math.pi) *
              waveHeight;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: [
          color.withOpacity(0.08),
          color.withOpacity(0.03),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height / 2 + 10);

    for (double i = 0; i <= size.width; i++) {
      final y = size.height / 2 +
          10 +
          math.cos((i / waveLength - animation * 2 * math.pi) * 2 * math.pi) *
              waveHeight;
      path2.lineTo(i, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WaterFlowPainter oldDelegate) {
    return animation != oldDelegate.animation || color != oldDelegate.color;
  }
}
