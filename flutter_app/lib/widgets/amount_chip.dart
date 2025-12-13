import 'package:flutter/material.dart';

/// Reusable amount chip widget for quick amount selection
class AmountChip extends StatelessWidget {
  final String amount;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const AmountChip({
    super.key,
    required this.amount,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          '৳$amount',
          style: TextStyle(
            color: textColor ?? const Color(0xFF475569),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
