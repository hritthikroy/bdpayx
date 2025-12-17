import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/login_popup.dart';
import '../../widgets/theme_icons.dart';
import '../../widgets/custom_icons.dart';
import 'chat_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
          slivers: [
            // Theme-friendly Header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CustomIcons.supportAgent(
                            color: colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Help & Support',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'We\'re here to help you 24/7',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '❓',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'How can we help you?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Support Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Live Chat
                    _buildSupportCard(
                      context,
                      icon: null, // Will use emoji
                      title: 'Live Chat',
                      subtitle: 'Chat with our support team',
                      color: colorScheme.primary,
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
                    
                    // Call
                    _buildSupportCard(
                      context,
                      icon: null, // Will use emoji
                      title: 'Call',
                      subtitle: 'Voice call support',
                      color: const Color(0xFF0088CC),
                      onTap: () {
                        _showTelegramCallDialog(context);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Message
                    _buildSupportCard(
                      context,
                      icon: null, // Will use emoji
                      title: 'Message',
                      subtitle: 'Send us a message',
                      color: const Color(0xFF0088CC),
                      onTap: () {
                        _showTelegramMessageDialog(context);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Video Call
                    _buildSupportCard(
                      context,
                      icon: null, // Will use emoji
                      title: 'Video Call',
                      subtitle: 'Face-to-face support',
                      color: const Color(0xFF0088CC),
                      onTap: () {
                        _showTelegramVideoCallDialog(context);
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Operating Hours
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.1),
                            colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomIcons.schedule(color: colorScheme.onPrimary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Support Hours',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildHoursRow('Live Chat', '24/7 Available'),
                          _buildHoursRow('Call', '24/7 Available'),
                          _buildHoursRow('Message', '24/7 Available'),
                          _buildHoursRow('Video Call', '24/7 Available'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Emergency Contact
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.error.withValues(alpha: 0.1),
                            colorScheme.error.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.warning_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emergency Support',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.error,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'For urgent issues, contact us via Telegram: @bdpayx_support',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.error.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Add bottom padding to account for navigation bar
                    const SizedBox(height: 100),
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
    required IconData? icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get emoji icon based on title
    Widget iconWidget;
    switch (title) {
      case 'Live Chat':
        iconWidget = ThemeIcons.support(color: color, size: 28);
        break;
      case 'Call':
        iconWidget = ThemeIcons.phone(color: color, size: 28);
        break;
      case 'Message':
        iconWidget = ThemeIcons.send(color: color, size: 28);
        break;
      case 'Video Call':
        iconWidget = ThemeIcons.play(color: color, size: 28);
        break;
      default:
        iconWidget = icon != null 
          ? Icon(icon, color: color, size: 28)
          : ThemeIcons.support(color: color, size: 28);
    }
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: iconWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            CustomIcons.arrowForwardIos(color: color, size: 18),
          ],
        ),
      ),
    );
  }



  Widget _buildHoursRow(String service, String hours) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                hours,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTelegramCallDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIcons.phone(color: const Color(0xFF0088CC)),
            const SizedBox(width: 12),
            const Text('Call'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Start a voice call on Telegram:'),
            const SizedBox(height: 8),
            SelectableText(
              '@bdpayx_support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0088CC),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Available 24/7 for instant voice support',
              style: TextStyle(
                fontSize: 13, 
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
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

  void _showTelegramMessageDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            ThemeIcons.send(color: const Color(0xFF0088CC), size: 24),
            const SizedBox(width: 12),
            const Text('Message'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send us a message on Telegram:'),
            const SizedBox(height: 8),
            SelectableText(
              '@bdpayx_support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0088CC),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Get quick responses to your questions 24/7',
              style: TextStyle(
                fontSize: 13, 
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
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

  void _showTelegramVideoCallDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.videocam_rounded,
              size: 24,
              color: Color(0xFF0088CC),
            ),
            const SizedBox(width: 12),
            const Text('Video Call'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Start a video call on Telegram:'),
            const SizedBox(height: 8),
            SelectableText(
              '@bdpayx_support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0088CC),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Face-to-face support available 24/7',
              style: TextStyle(
                fontSize: 13, 
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
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
