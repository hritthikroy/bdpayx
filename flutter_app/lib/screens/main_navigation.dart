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
  late AnimationController _bubbleController;
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const SupportScreen(),
    const ProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.home_rounded, label: 'Home', color: Color(0xFF6366F1)),
    NavItem(icon: Icons.receipt_long_rounded, label: 'History', color: Color(0xFF8B5CF6)),
    NavItem(icon: Icons.chat_bubble_rounded, label: 'Support', color: Color(0xFFA855F7)),
    NavItem(icon: Icons.person_rounded, label: 'Profile', color: Color(0xFFEC4899)),
  ];

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll(double offset) {
    setState(() {
      _scrollOffset = offset.clamp(0.0, 100.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            _onScroll(notification.metrics.pixels);
          }
          return false;
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _navItems[_currentIndex].color.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, -15),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 25,
                    sigmaY: 25,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: _navItems[_currentIndex].color.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Container(
                        height: 75,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Stack(
                          children: [
                            // Animated background indicator
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                              left: _currentIndex * (MediaQuery.of(context).size.width - 32) / 4,
                              top: 0,
                              bottom: 0,
                              width: (MediaQuery.of(context).size.width - 32) / 4,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _navItems[_currentIndex].color.withOpacity(0.15),
                                      _navItems[_currentIndex].color.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _navItems[_currentIndex].color.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _navItems[_currentIndex].color.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Navigation items
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(
                                _navItems.length,
                                (index) => _buildNavItem(index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = index);
          _bubbleController.forward(from: 0);
        },
        behavior: HitTestBehavior.opaque,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          tween: Tween(begin: 0, end: isSelected ? 1 : 0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1 + (value * 0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      if (isSelected)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                item.color.withOpacity(0.3 * value),
                                item.color.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      // Icon container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(isSelected ? 10 : 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    item.color.withOpacity(0.2),
                                    item.color.withOpacity(0.1),
                                  ],
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: item.color.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Transform.rotate(
                          angle: value * 0.1 * math.pi,
                          child: Icon(
                            item.icon,
                            color: Color.lerp(
                              const Color(0xFF94A3B8),
                              item.color,
                              value,
                            ),
                            size: 24 + (value * 4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: Color.lerp(
                        const Color(0xFF94A3B8),
                        item.color,
                        value,
                      ),
                      fontSize: 10 + (value * 1.5),
                      fontWeight: FontWeight.lerp(
                        FontWeight.w500,
                        FontWeight.w700,
                        value,
                      ),
                      letterSpacing: 0.3,
                    ),
                    child: Text(item.label),
                  ),
                ],
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
