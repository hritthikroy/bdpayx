import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/login_popup.dart';
import '../../widgets/animated_avatar.dart';
import 'kyc_screen.dart';
import 'bank_cards_screen.dart';
import '../referral/referral_screen.dart';
import '../statement/statement_screen.dart';
import '../security/security_settings_screen.dart';
import '../security/setup_pin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _hasPinSet = false;
  bool _isCheckingPin = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPinStatus());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('transaction_pin');
    if (mounted) {
      setState(() {
        _hasPinSet = pin != null && pin.isNotEmpty;
        _isCheckingPin = false;
      });
    }
  }


  Future<void> _handleSecurityTap() async {
    HapticFeedback.lightImpact();
    if (_hasPinSet) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()))
          .then((_) => _checkPinStatus());
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetupPinScreen()),
      );
      if (result == true) {
        _checkPinStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Transaction PIN set successfully'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: authProvider.isAuthenticated
            ? _buildAuthenticatedProfile(user, isDark)
            : _buildLoginPrompt(isDark),
      ),
    );
  }

  Widget _buildAuthenticatedProfile(dynamic user, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeaderWithProfile(user, isDark)),
        SliverToBoxAdapter(child: _buildQuickActions(isDark)),
        SliverToBoxAdapter(child: _buildMyAccountSection(isDark)),
        SliverToBoxAdapter(child: _buildActivitySection(isDark)),
        SliverToBoxAdapter(child: _buildMoreSection(isDark)),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER WITH PROFILE - Combined header and profile info
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeaderWithProfile(dynamic user, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF4F46E5), const Color(0xFF7C3AED)]
              : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              // Top Row: Title + Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      _buildHeaderIcon(Icons.notifications_outlined, () {
                        HapticFeedback.lightImpact();
                      }),
                      const SizedBox(width: 8),
                      _buildHeaderIcon(Icons.settings_outlined, () {
                        HapticFeedback.lightImpact();
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Profile Info Row
              Row(
                children: [
                  // Avatar with gradient ring
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0xFFEC4899)],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1),
                      ),
                      child: AnimatedAvatar(size: 70, userName: user?.fullName),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'User',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_rounded, 
                              size: 14, 
                              color: Colors.white.withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                user?.phone ?? 'Add phone number',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildKycBadgeLight(user?.kycStatus ?? 'pending'),
                      ],
                    ),
                  ),
                  // Edit Profile Button
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Stats Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildStatItem('৳${user?.balance?.toStringAsFixed(0) ?? '0'}', 'Balance', Icons.account_balance_wallet_rounded)),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
                    Expanded(child: _buildStatItem('12', 'Transactions', Icons.swap_horiz_rounded)),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
                    Expanded(child: _buildStatItem('2', 'Cards', Icons.credit_card_rounded)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildKycBadgeLight(String status) {
    final isApproved = status == 'approved';
    final isPending = status == 'pending';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isApproved
            ? Colors.white.withValues(alpha: 0.25)
            : isPending
                ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                : const Color(0xFFEF4444).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApproved ? Icons.verified_rounded : isPending ? Icons.schedule_rounded : Icons.error_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isApproved ? 'Verified' : isPending ? 'KYC Pending' : 'KYC Failed',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE CARD - Floating card with avatar and user info
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildProfileCard(dynamic user, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
                children: [
                  // Avatar with gradient ring
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      ),
                      child: AnimatedAvatar(size: 70, userName: user?.fullName),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'User',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_rounded, 
                              size: 14, 
                              color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                user?.phone ?? 'Add phone number',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildKycBadge(user?.kycStatus ?? 'pending'),
                      ],
                    ),
                  ),
                  // Edit Profile Button
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Color(0xFF6366F1), size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Balance Overview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF374151), const Color(0xFF1F2937)]
                        : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildBalanceStat('৳${user?.balance?.toStringAsFixed(0) ?? '0'}', 'Balance', Icons.account_balance_wallet_rounded, const Color(0xFF10B981), isDark)),
                    Container(width: 1, height: 40, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                    Expanded(child: _buildBalanceStat('12', 'Transactions', Icons.swap_horiz_rounded, const Color(0xFF6366F1), isDark)),
                    Container(width: 1, height: 40, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                  Expanded(child: _buildBalanceStat('2', 'Cards', Icons.credit_card_rounded, const Color(0xFFEC4899), isDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildKycBadge(String status) {
    final isApproved = status == 'approved';
    final isPending = status == 'pending';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isApproved
            ? const Color(0xFF10B981).withValues(alpha: 0.15)
            : isPending
                ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                : const Color(0xFFEF4444).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApproved
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : isPending
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                  : const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApproved ? Icons.verified_rounded : isPending ? Icons.schedule_rounded : Icons.error_rounded,
            size: 12,
            color: isApproved ? const Color(0xFF10B981) : isPending ? const Color(0xFFF59E0B) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 4),
          Text(
            isApproved ? 'Verified' : isPending ? 'KYC Pending' : 'KYC Failed',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isApproved ? const Color(0xFF10B981) : isPending ? const Color(0xFFF59E0B) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(String value, String label, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // QUICK ACTIONS - Horizontal scrollable action buttons
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildQuickActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: SizedBox(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildQuickAction('KYC', Icons.verified_user_rounded, const Color(0xFF3B82F6), isDark, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen()));
            }),
            _buildQuickAction('Bank', Icons.account_balance_rounded, const Color(0xFF10B981), isDark, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BankCardsScreen()));
            }),
            _buildQuickAction('Refer', Icons.card_giftcard_rounded, const Color(0xFFEC4899), isDark, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen()));
            }),
            _buildQuickAction('Support', Icons.headset_mic_rounded, const Color(0xFF8B5CF6), isDark, () {
              Navigator.pushNamed(context, '/chat');
            }),
            _buildQuickAction('History', Icons.history_rounded, const Color(0xFFF59E0B), isDark, () {
              Navigator.pushNamed(context, '/transactions');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 75,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // MY ACCOUNT SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMyAccountSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('My Account', Icons.person_rounded, isDark),
            const SizedBox(height: 12),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.verified_user_rounded,
                title: 'KYC Verification',
                subtitle: 'Complete identity verification',
                color: const Color(0xFF3B82F6),
                isDark: isDark,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen())),
              ),
              _buildMenuItem(
                icon: Icons.credit_card_rounded,
                title: 'Bank & Cards',
                subtitle: 'Manage payment methods',
                color: const Color(0xFF10B981),
                isDark: isDark,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BankCardsScreen())),
              ),
              _buildSecurityMenuItem(isDark),
            ], isDark),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVITY SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActivitySection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Activity', Icons.timeline_rounded, isDark),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.history_rounded,
              title: 'Transaction History',
              subtitle: 'View all transactions',
              color: const Color(0xFF6366F1),
              isDark: isDark,
              onTap: () => Navigator.pushNamed(context, '/transactions'),
            ),
            _buildMenuItem(
              icon: Icons.receipt_long_rounded,
              title: 'Statements',
              subtitle: 'Download reports',
              color: const Color(0xFF8B5CF6),
              isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatementScreen())),
            ),
            _buildMenuItem(
              icon: Icons.card_giftcard_rounded,
              title: 'Referral Program',
              subtitle: 'Invite & earn rewards',
              color: const Color(0xFFEC4899),
              isDark: isDark,
              badge: 'NEW',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen())),
            ),
          ], isDark),
        ],
      ),
    );
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // MORE SECTION (Support, Settings, Logout)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMoreSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('More', Icons.more_horiz_rounded, isDark),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.headset_mic_rounded,
              title: '24/7 Support',
              subtitle: 'Get help anytime',
              color: const Color(0xFF06B6D4),
              isDark: isDark,
              onTap: () => Navigator.pushNamed(context, '/chat'),
            ),
            _buildMenuItem(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Manage alerts',
              color: const Color(0xFFA855F7),
              isDark: isDark,
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              subtitle: 'App preferences',
              color: const Color(0xFF64748B),
              isDark: isDark,
              onTap: () {},
            ),
          ], isDark),
          const SizedBox(height: 16),
          // Logout Button
          _buildLogoutButton(isDark),
          const SizedBox(height: 20),
          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'BDPayX',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // REUSABLE COMPONENTS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFF6366F1)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(
                  height: 1,
                  indent: 70,
                  endIndent: 20,
                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSecurityMenuItem(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleSecurityTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF8B5CF6).withValues(alpha: 0.2), const Color(0xFF8B5CF6).withValues(alpha: 0.1)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_rounded, color: Color(0xFF8B5CF6), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Security',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!_isCheckingPin)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _hasPinSet
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _hasPinSet
                                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                    : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _hasPinSet ? Icons.check_circle : Icons.warning_rounded,
                                  size: 10,
                                  color: _hasPinSet ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _hasPinSet ? 'Active' : 'Setup',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _hasPinSet ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isCheckingPin
                          ? 'Checking status...'
                          : _hasPinSet
                              ? 'PIN & Biometric enabled'
                              : 'Set up transaction PIN',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLogoutButton(bool isDark) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final confirm = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
        
        if (confirm == true && mounted) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          
          // Sign out from Google as well
          await LoginPopup.signOut();
          await authProvider.logout();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Logged out successfully'),
                  ],
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN PROMPT (for unauthenticated users)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLoginPrompt(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF4F46E5), const Color(0xFF0F172A)]
              : [const Color(0xFF6366F1), const Color(0xFFF1F5F9)],
          stops: const [0.0, 0.5],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Login Card
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 40,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Icon
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withValues(alpha: 0.2),
                                const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 56,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Welcome to BDPayX',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sign in to access your profile,\ntransaction history, and more',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              await LoginPopup.show(context, message: 'Login to access your profile');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login_rounded, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Features List
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildFeatureItem('Secure transactions', Icons.shield_rounded, isDark),
                              const SizedBox(height: 10),
                              _buildFeatureItem('Track your history', Icons.history_rounded, isDark),
                              const SizedBox(height: 10),
                              _buildFeatureItem('Earn referral rewards', Icons.card_giftcard_rounded, isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF10B981)),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
