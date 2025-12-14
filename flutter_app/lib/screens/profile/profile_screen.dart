import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/login_popup.dart';
import 'kyc_screen.dart';
import 'bank_cards_screen.dart';
import '../referral/referral_screen.dart';
import '../statement/statement_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Check login when profile screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogin();
    });
  }

  Future<void> _checkLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      await LoginPopup.show(
        context,
        message: 'Login to view your profile',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Modern Header with Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: user?.photoUrl != null
                            ? Image.network(
                                user!.photoUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to fun emoji avatar
                                  return Image.network(
                                    'https://api.dicebear.com/7.x/big-smile/png?seed=${user.phone ?? user.id}&backgroundColor=6366f1,8b5cf6,a855f7&size=100',
                                    width: 100,
                                    height: 100,
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
                                            user.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                                            style: const TextStyle(
                                              fontSize: 42,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            : Image.network(
                                'https://api.dicebear.com/7.x/big-smile/png?seed=${user?.phone ?? user?.id ?? 'default'}&backgroundColor=6366f1,8b5cf6,a855f7&size=100',
                                width: 100,
                                height: 100,
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
                                        user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                                        style: const TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          user?.phone ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getKycIcon(user?.kycStatus ?? 'pending'),
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'KYC: ${user?.kycStatus.toUpperCase() ?? 'PENDING'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Stats Cards (Overlapping)
              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '৳${user?.balance.toStringAsFixed(2) ?? '0.00'}',
                            'Total Balance',
                            Icons.account_balance_wallet,
                            const Color(0xFF10B981),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: const Color(0xFFE2E8F0),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            '৳0.00',
                            'Available',
                            Icons.check_circle,
                            const Color(0xFF6366F1),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: const Color(0xFFE2E8F0),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            '৳0.00',
                            'Pending',
                            Icons.pending,
                            const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.people,
                      title: 'Referrals',
                      subtitle: 'Invite friends and earn',
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReferralScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.history,
                      title: 'Exchange History',
                      subtitle: 'View all your exchanges',
                      color: const Color(0xFF6366F1),
                      onTap: () {
                        Navigator.pushNamed(context, '/transactions');
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.receipt_long,
                      title: 'Statement',
                      subtitle: 'Download transaction reports',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StatementScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.credit_card,
                      title: 'Bank Account',
                      subtitle: 'Manage your bank accounts',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BankCardsScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.card_giftcard,
                      title: 'Invite Friends',
                      subtitle: 'Share and earn rewards',
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReferralScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.verified_user,
                      title: 'KYC Verification',
                      subtitle: 'Complete your verification',
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KycScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'View all notifications',
                      color: const Color(0xFFA855F7),
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      color: const Color(0xFF64748B),
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.headset_mic,
                      title: '24/7 Support',
                      subtitle: 'Get help anytime',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.pushNamed(context, '/chat');
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      color: const Color(0xFFEF4444),
                      onTap: () async {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDestructive ? color : const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: const Color(0xFF94A3B8),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getKycColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
  
  IconData _getKycIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
}
