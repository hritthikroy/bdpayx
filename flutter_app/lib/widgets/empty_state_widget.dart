import 'package:flutter/material.dart';

/// A reusable empty state widget that displays when there's no data to show.
/// Provides a professional, consistent look across all screens.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? const Color(0xFF6366F1);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              width: iconSize + 32,
              height: iconSize + 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    effectiveIconColor.withOpacity(0.1),
                    effectiveIconColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: effectiveIconColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            // Optional CTA button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveIconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Factory constructor for transactions empty state
  factory EmptyStateWidget.transactions({VoidCallback? onExchange}) {
    return EmptyStateWidget(
      title: 'No Transactions Yet',
      message: 'Your transaction history will appear here once you make your first exchange.',
      icon: Icons.receipt_long_outlined,
      iconColor: const Color(0xFF6366F1),
      actionLabel: 'Make First Exchange',
      onAction: onExchange,
    );
  }

  /// Factory constructor for pending withdrawals empty state
  factory EmptyStateWidget.pendingWithdrawals() {
    return const EmptyStateWidget(
      title: 'No Pending Withdrawals',
      message: 'Your withdrawal requests will appear here.',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: Color(0xFF3B82F6),
    );
  }

  /// Factory constructor for pending deposits empty state
  factory EmptyStateWidget.pendingDeposits() {
    return const EmptyStateWidget(
      title: 'No Pending Deposits',
      message: 'Your deposit requests will appear here.',
      icon: Icons.add_circle_outline,
      iconColor: Color(0xFF10B981),
    );
  }

  /// Factory constructor for pending exchanges empty state
  factory EmptyStateWidget.pendingExchanges() {
    return const EmptyStateWidget(
      title: 'No Pending Exchanges',
      message: 'Your exchange requests will appear here.',
      icon: Icons.swap_horiz_outlined,
      iconColor: Color(0xFF8B5CF6),
    );
  }
}

/// Compact version for inline empty states within sections
class CompactEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? iconColor;

  const CompactEmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? const Color(0xFF94A3B8);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: effectiveColor,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
