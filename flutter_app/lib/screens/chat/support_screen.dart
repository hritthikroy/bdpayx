import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/login_popup.dart';
import 'chat_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
          cacheExtent: 500,
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF3B82F6),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Help & Support',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We\'re here to help you 24/7',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Live Chat
                    _buildSupportCard(
                      context,
                      icon: Icons.chat_bubble,
                      title: 'Live Chat',
                      subtitle: 'Chat with our support team',
                      color: const Color(0xFF10B981),
                      onTap: () async {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        if (!authProvider.isAuthenticated) {
                          await LoginPopup.show(context, message: 'Login to chat with support');
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Email Support
                    _buildSupportCard(
                      context,
                      icon: Icons.email,
                      title: 'Email Support',
                      subtitle: 'support@bdpayx.com',
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        _showEmailDialog(context);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Phone Support
                    _buildSupportCard(
                      context,
                      icon: Icons.phone,
                      title: 'Phone Support',
                      subtitle: '+880 1XXX-XXXXXX',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        _showPhoneDialog(context);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // WhatsApp Support
                    _buildSupportCard(
                      context,
                      icon: Icons.chat,
                      title: 'WhatsApp Support',
                      subtitle: 'Quick response via WhatsApp',
                      color: const Color(0xFF059669),
                      onTap: () {
                        _showWhatsAppDialog(context);
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // FAQ Section
                    const Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildFAQItem(
                      'How do I exchange BDT to INR?',
                      'Simply enter the amount you want to exchange on the home screen, verify the rate, and proceed to payment. Your INR will be credited instantly.',
                    ),
                    
                    _buildFAQItem(
                      'What are the transaction fees?',
                      'We offer competitive rates with transparent pricing. Check the pricing tiers on the exchange screen for detailed fee structure.',
                    ),
                    
                    _buildFAQItem(
                      'How long does withdrawal take?',
                      'Withdrawals are processed within 24 hours on business days. You\'ll receive a notification once processed.',
                    ),
                    
                    _buildFAQItem(
                      'Is my money safe?',
                      'Yes! We use bank-level security with SSL encryption and comply with all financial regulations.',
                    ),
                    
                    _buildFAQItem(
                      'How do I verify my account?',
                      'Go to Profile → KYC Verification and upload your ID documents. Verification typically takes 24-48 hours.',
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Operating Hours
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.access_time, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Support Hours',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildHoursRow('Live Chat', '24/7 Available'),
                          _buildHoursRow('Email Support', 'Response within 2 hours'),
                          _buildHoursRow('Phone Support', 'Mon-Sat: 9 AM - 9 PM'),
                          _buildHoursRow('WhatsApp', '24/7 Available'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Emergency Contact
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.emergency, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emergency Support',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'For urgent issues, call: +880 1XXX-XXXXXX',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7F1D1D),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursRow(String service, String hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            service,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF065F46),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            hours,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF047857),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.email, color: Color(0xFF3B82F6)),
            SizedBox(width: 12),
            Text('Email Support'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send us an email at:'),
            SizedBox(height: 8),
            SelectableText(
              'support@bdpayx.com',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'We typically respond within 2 hours during business hours.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.phone, color: Color(0xFF8B5CF6)),
            SizedBox(width: 12),
            Text('Phone Support'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Call us at:'),
            SizedBox(height: 8),
            SelectableText(
              '+880 1XXX-XXXXXX',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5CF6),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Available: Monday - Saturday\n9:00 AM - 9:00 PM (GMT+6)',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showWhatsAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.chat, color: Color(0xFF059669)),
            SizedBox(width: 12),
            Text('WhatsApp Support'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Message us on WhatsApp:'),
            SizedBox(height: 8),
            SelectableText(
              '+880 1XXX-XXXXXX',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF059669),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Available 24/7 for quick support',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
