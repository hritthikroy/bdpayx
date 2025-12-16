import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/security_provider.dart';
import 'transaction_pin_screen.dart';
import 'setup_pin_screen.dart';
import 'change_pin_screen.dart';
import 'security_settings_screen.dart';

/// Demo screen to test all security features
/// Add this to your app to quickly test the PIN system
class DemoSecurityScreen extends StatelessWidget {
  const DemoSecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Demo'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, securityProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildDemoCard(
                context,
                icon: Icons.lock_outline,
                title: 'Setup Transaction PIN',
                subtitle: 'First-time PIN setup flow',
                color: Colors.blue,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SetupPinScreen(),
                    ),
                  );
                  if (result == true) {
                    _showSuccess(context, 'PIN setup successful!');
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildDemoCard(
                context,
                icon: Icons.verified_user,
                title: 'Verify Transaction PIN',
                subtitle: 'Test PIN verification (like before a transaction)',
                color: const Color(0xFF9C27B0),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionPinScreen(
                        userName: 'Pranta',
                        phoneNumber: '+916268',
                        canUseBiometric: true,
                        onSuccess: () {
                          Navigator.pop(context);
                          _showSuccess(context, 'Transaction authorized!');
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildDemoCard(
                context,
                icon: Icons.edit,
                title: 'Change PIN',
                subtitle: 'Update existing transaction PIN',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePinScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildDemoCard(
                context,
                icon: Icons.settings,
                title: 'Security Settings',
                subtitle: 'Full security settings screen',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecuritySettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildInfoSection(securityProvider),
              const SizedBox(height: 24),
              _buildTestSection(context, securityProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.security, color: Colors.white, size: 40),
          SizedBox(height: 12),
          Text(
            'Transaction Security',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Test all security features',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(SecurityProvider securityProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Biometric Available', 
              securityProvider.isBiometricAvailable ? 'Yes' : 'No'),
          _buildInfoRow('Biometric Enabled', 
              securityProvider.isBiometricEnabled ? 'Yes' : 'No'),
          _buildInfoRow('Remaining Attempts', 
              '${securityProvider.remainingAttempts}/5'),
          if (securityProvider.isLockedOut)
            _buildInfoRow('Locked Out', 'Yes', isError: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isError ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection(BuildContext context, SecurityProvider securityProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            await securityProvider.resetPin();
            _showSuccess(context, 'PIN reset successfully');
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reset PIN (for testing)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
