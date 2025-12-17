import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/security_provider.dart';
import 'setup_pin_screen.dart';
import 'change_pin_screen.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, securityProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'Transaction PIN',
                children: [
                  _buildSettingTile(
                    icon: Icons.lock_outline,
                    title: 'Transaction PIN',
                    subtitle: 'Secure your transactions with a PIN',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SetupPinScreen(),
                        ),
                      );
                      if (result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaction PIN set successfully'),
                          ),
                        );
                      }
                    },
                  ),
                  _buildSettingTile(
                    icon: Icons.edit_outlined,
                    title: 'Change PIN',
                    subtitle: 'Update your transaction PIN',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePinScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Biometric Authentication',
                children: [
                  _buildSettingTile(
                    icon: Icons.fingerprint,
                    title: 'Use Biometric',
                    subtitle: securityProvider.isBiometricAvailable
                        ? 'Use fingerprint or face ID'
                        : 'Not available on this device',
                    trailing: Switch(
                      value: securityProvider.isBiometricEnabled,
                      onChanged: securityProvider.isBiometricAvailable
                          ? (value) {
                              securityProvider.enableBiometric(value);
                            }
                          : null,
                      activeColor: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Security Info',
                children: [
                  _buildInfoTile(
                    icon: Icons.info_outline,
                    title: 'About Transaction PIN',
                    subtitle:
                        'Your PIN is stored securely on your device and is required for all transactions.',
                  ),
                  _buildInfoTile(
                    icon: Icons.security,
                    title: 'Security Tips',
                    subtitle:
                        'Never share your PIN with anyone. Choose a PIN that is not easy to guess.',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1).withOpacity(0.1),
              const Color(0xFF8B5CF6).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF8B5CF6)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 13,
        ),
      ),
    );
  }
}
