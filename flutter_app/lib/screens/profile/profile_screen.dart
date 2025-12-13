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
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: user?.photoUrl != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(user!.photoUrl!),
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getKycColor(user?.kycStatus ?? 'pending'),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'KYC: ${user?.kycStatus.toUpperCase() ?? 'PENDING'}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('৳${user?.balance.toStringAsFixed(2) ?? '0.00'}', 'Total Amount'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('৳0.00', 'Available'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('৳0.00', 'Progressing'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildMenuItem(
              context,
              icon: Icons.people,
              title: 'Referrals',
              subtitle: 'Invite friends and earn',
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
              onTap: () {
                Navigator.pushNamed(context, '/transactions');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.receipt_long,
              title: 'Statement',
              subtitle: 'Download transaction reports',
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
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App preferences',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.headset_mic,
              title: '24/7 Support',
              subtitle: 'Get help anytime',
              onTap: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              isDestructive: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDestructive
            ? Colors.red.shade50
            : const Color(0xFF3B82F6).withOpacity(0.1),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF3B82F6),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
}
