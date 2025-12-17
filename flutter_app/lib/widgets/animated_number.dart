import 'package:flutter/material.dart';

class AnimatedNumber extends StatelessWidget {
  final double value;
  final TextStyle style;
  final String prefix;
  final int decimals;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.decimals = 2,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '$prefix${animatedValue.toStringAsFixed(decimals)}',
          style: style,
        );
      },
    );
  }
}
