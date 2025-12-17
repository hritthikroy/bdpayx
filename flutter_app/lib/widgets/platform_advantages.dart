import 'package:flutter/material.dart';

class PlatformAdvantages extends StatelessWidget {
  const PlatformAdvantages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform advantage',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildAdvantageItem(
            icon: Icons.headset_mic,
            title: '24 / 7 Support',
            description: 'Got a problem? Just get in touch. Our customer service support team is available 24/7.',
          ),
          const SizedBox(height: 20),
          _buildAdvantageItem(
            icon: Icons.credit_card,
            title: 'Transaction free',
            description: 'Use a variety of payment methods to trade cryptocurrency, free, safe and fast.',
          ),
          const SizedBox(height: 20),
          _buildAdvantageItem(
            icon: Icons.info_outline,
            title: 'Rich information',
            description: 'Gather a wealth of information, let you know the industry dynamics in first time.',
          ),
          const SizedBox(height: 20),
          _buildAdvantageItem(
            icon: Icons.security,
            title: 'Reliable security',
            description: 'Our sophisticated security measures protect your cryptocurrency from all risks.',
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantageItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E3A8A),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
