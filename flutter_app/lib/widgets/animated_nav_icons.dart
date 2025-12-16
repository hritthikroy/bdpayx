import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated Home Icon - Beautiful House with Smoke Animation
class AnimatedHomeIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double progress;

  const AnimatedHomeIcon({
    super.key,
    required this.isSelected,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: AnimatedHomePainter(
        progress: progress,
        color: color,
        isSelected: isSelected,
      ),
    );
  }
}

class AnimatedHomePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isSelected;

  AnimatedHomePainter({
    required this.progress,
    required this.color,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(isSelected ? 0.2 : 0.1)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Smooth bounce effect
    final bounce = math.sin(progress * math.pi) * 2;
    
    canvas.save();
    canvas.translate(0, -bounce);

    // House roof with chimney
    final roofPath = Path();
    roofPath.moveTo(center.dx, center.dy - 11);
    roofPath.lineTo(center.dx - 11, center.dy);
    roofPath.lineTo(center.dx + 11, center.dy);
    roofPath.close();

    // House body
    final bodyPath = Path();
    bodyPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - 8, center.dy, 16, 12),
      const Radius.circular(1.5),
    ));

    // Door with rounded top
    final doorPath = Path();
    doorPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - 2.5, center.dy + 4, 5, 8),
      const Radius.circular(2.5),
    ));

    // Window
    final windowPath = Path();
    windowPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx + 3, center.dy + 3, 4, 4),
      const Radius.circular(1),
    ));

    // Chimney
    final chimneyPath = Path();
    chimneyPath.addRect(Rect.fromLTWH(center.dx + 4, center.dy - 9, 4, 6));

    if (isSelected) {
      canvas.drawPath(roofPath, fillPaint);
      canvas.drawPath(bodyPath, fillPaint);
    }
    
    canvas.drawPath(roofPath, paint);
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(doorPath, paint);
    canvas.drawPath(windowPath, paint);
    canvas.drawPath(chimneyPath, paint);

    // Animated smoke from chimney when selected
    if (isSelected && progress > 0) {
      final smokePaint = Paint()
        ..color = color.withOpacity(0.4 * (1 - progress))
        ..style = PaintingStyle.fill;
      
      for (int i = 0; i < 3; i++) {
        final smokeY = center.dy - 12 - (progress * 8) - (i * 4);
        final smokeX = center.dx + 6 + math.sin(progress * math.pi * 2 + i) * 2;
        final smokeSize = 2.0 + (progress * 2) - (i * 0.5);
        if (smokeSize > 0) {
          canvas.drawCircle(
            Offset(smokeX, smokeY),
            smokeSize,
            smokePaint..color = color.withOpacity(0.3 * (1 - progress) * (1 - i * 0.3)),
          );
        }
      }
    }

    canvas.restore();

    // Glow effect when selected
    if (isSelected) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, 14, glowPaint);
    }
  }

  @override
  bool shouldRepaint(AnimatedHomePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isSelected != isSelected;
  }
}

/// Animated History Icon - Clock with Spinning Hands
class AnimatedHistoryIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double progress;

  const AnimatedHistoryIcon({
    super.key,
    required this.isSelected,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: AnimatedHistoryPainter(
        progress: progress,
        color: color,
        isSelected: isSelected,
      ),
    );
  }
}

class AnimatedHistoryPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isSelected;

  AnimatedHistoryPainter({
    required this.progress,
    required this.color,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(isSelected ? 0.15 : 0.08)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Smooth elastic bounce
    final elasticProgress = _elasticOut(progress);
    final scale = 1.0 + (elasticProgress * 0.1);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    // Clock face
    if (isSelected) canvas.drawCircle(center, 10, fillPaint);
    canvas.drawCircle(center, 10, paint);

    // Clock tick marks
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180 - math.pi / 2;
      final innerRadius = i % 3 == 0 ? 7.0 : 8.0;
      final outerRadius = 9.5;
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * innerRadius,
               center.dy + math.sin(angle) * innerRadius),
        Offset(center.dx + math.cos(angle) * outerRadius,
               center.dy + math.sin(angle) * outerRadius),
        paint..strokeWidth = i % 3 == 0 ? 1.5 : 1.0,
      );
    }

    // Animated clock hands - smooth rotation
    final handRotation = progress * math.pi * 2;
    
    // Hour hand
    canvas.drawLine(
      center,
      Offset(center.dx + math.cos(-math.pi / 2 + handRotation * 0.3) * 4,
             center.dy + math.sin(-math.pi / 2 + handRotation * 0.3) * 4),
      paint..strokeWidth = 2.5,
    );

    // Minute hand with smooth sweep
    canvas.drawLine(
      center,
      Offset(center.dx + math.cos(-math.pi / 2 + handRotation) * 6.5,
             center.dy + math.sin(-math.pi / 2 + handRotation) * 6.5),
      paint..strokeWidth = 2.0,
    );

    // Center dot
    canvas.drawCircle(center, 2, Paint()..color = color);

    canvas.restore();

    // Rewind arrow with animation
    final arrowBounce = math.sin(progress * math.pi) * 3;
    final arrowPath = Path();
    arrowPath.moveTo(center.dx - 13 - arrowBounce, center.dy - 2);
    arrowPath.lineTo(center.dx - 13 - arrowBounce, center.dy - 7);
    arrowPath.lineTo(center.dx - 8 - arrowBounce, center.dy - 4);
    canvas.drawPath(arrowPath, paint..strokeWidth = 2.0);

    // Glow effect
    if (isSelected) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, 14, glowPaint);
    }
  }

  double _elasticOut(double t) {
    if (t == 0 || t == 1) return t;
    return math.pow(2, -10 * t) * math.sin((t - 0.1) * 5 * math.pi) + 1;
  }

  @override
  bool shouldRepaint(AnimatedHistoryPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isSelected != isSelected;
  }
}

/// Animated Support Icon - Headset with Sound Waves
class AnimatedSupportIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double progress;

  const AnimatedSupportIcon({
    super.key,
    required this.isSelected,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: AnimatedSupportPainter(
        progress: progress,
        color: color,
        isSelected: isSelected,
      ),
    );
  }
}

class AnimatedSupportPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isSelected;

  AnimatedSupportPainter({
    required this.progress,
    required this.color,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(isSelected ? 0.2 : 0.1)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Gentle wobble animation
    final wobble = math.sin(progress * math.pi * 2) * 0.05;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(wobble);
    canvas.translate(-center.dx, -center.dy);

    // Headband arc
    final headbandPath = Path();
    headbandPath.addArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 1), width: 20, height: 18),
      math.pi, math.pi,
    );
    canvas.drawPath(headbandPath, paint);

    // Left ear cup with padding effect
    final leftCupOuter = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - 12, center.dy - 3, 6, 10),
      const Radius.circular(3),
    );
    final leftCupInner = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - 11, center.dy - 1, 4, 6),
      const Radius.circular(2),
    );
    if (isSelected) canvas.drawRRect(leftCupOuter, fillPaint);
    canvas.drawRRect(leftCupOuter, paint);
    canvas.drawRRect(leftCupInner, paint..strokeWidth = 1.5);

    // Right ear cup
    final rightCupOuter = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx + 6, center.dy - 3, 6, 10),
      const Radius.circular(3),
    );
    final rightCupInner = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx + 7, center.dy - 1, 4, 6),
      const Radius.circular(2),
    );
    if (isSelected) canvas.drawRRect(rightCupOuter, fillPaint);
    canvas.drawRRect(rightCupOuter, paint..strokeWidth = 2.0);
    canvas.drawRRect(rightCupInner, paint..strokeWidth = 1.5);

    // Microphone arm
    final micPath = Path();
    micPath.moveTo(center.dx + 9, center.dy + 5);
    micPath.quadraticBezierTo(center.dx + 5, center.dy + 11, center.dx + 1, center.dy + 11);
    canvas.drawPath(micPath, paint..strokeWidth = 2.0);

    // Microphone head
    canvas.drawCircle(Offset(center.dx + 1, center.dy + 11), 3, paint);
    if (isSelected) {
      canvas.drawCircle(Offset(center.dx + 1, center.dy + 11), 3, fillPaint);
    }

    canvas.restore();

    // Sound waves animation when selected
    if (isSelected && progress > 0) {
      final wavePaint = Paint()
        ..color = color.withOpacity(0.4 * (1 - progress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      for (int i = 0; i < 2; i++) {
        final waveProgress = (progress + i * 0.3) % 1.0;
        final waveRadius = 5 + waveProgress * 8;
        final waveOpacity = (1 - waveProgress) * 0.5;
        
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx + 1, center.dy + 11),
            width: waveRadius * 2,
            height: waveRadius * 2,
          ),
          -math.pi / 4,
          -math.pi / 2,
          false,
          wavePaint..color = color.withOpacity(waveOpacity),
        );
      }
    }

    // Glow effect
    if (isSelected) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, 14, glowPaint);
    }
  }

  @override
  bool shouldRepaint(AnimatedSupportPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isSelected != isSelected;
  }
}

/// Animated Alerts Icon - Bell with Realistic Ring
class AnimatedAlertsIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double progress;

  const AnimatedAlertsIcon({
    super.key,
    required this.isSelected,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: AnimatedAlertsPainter(
        progress: progress,
        color: color,
        isSelected: isSelected,
      ),
    );
  }
}

class AnimatedAlertsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isSelected;

  AnimatedAlertsPainter({
    required this.progress,
    required this.color,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(isSelected ? 0.2 : 0.1)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Realistic bell swing with damping
    final swingDecay = math.exp(-progress * 3);
    final swing = math.sin(progress * math.pi * 6) * 0.2 * swingDecay;
    
    canvas.save();
    canvas.translate(center.dx, center.dy - 10);
    canvas.rotate(swing);
    canvas.translate(-center.dx, -(center.dy - 10));

    // Bell body - more realistic shape
    final bellPath = Path();
    bellPath.moveTo(center.dx - 9, center.dy + 5);
    bellPath.cubicTo(
      center.dx - 9, center.dy - 2,
      center.dx - 6, center.dy - 10,
      center.dx, center.dy - 11,
    );
    bellPath.cubicTo(
      center.dx + 6, center.dy - 10,
      center.dx + 9, center.dy - 2,
      center.dx + 9, center.dy + 5,
    );
    bellPath.lineTo(center.dx - 9, center.dy + 5);

    if (isSelected) canvas.drawPath(bellPath, fillPaint);
    canvas.drawPath(bellPath, paint);

    // Bell bottom rim with curve
    final rimPath = Path();
    rimPath.moveTo(center.dx - 11, center.dy + 5);
    rimPath.quadraticBezierTo(center.dx, center.dy + 7, center.dx + 11, center.dy + 5);
    canvas.drawPath(rimPath, paint);

    // Bell top loop
    canvas.drawCircle(Offset(center.dx, center.dy - 11), 2.5, paint);

    // Inner bell detail
    final innerPath = Path();
    innerPath.moveTo(center.dx - 5, center.dy + 2);
    innerPath.quadraticBezierTo(center.dx, center.dy - 4, center.dx + 5, center.dy + 2);
    canvas.drawPath(innerPath, paint..strokeWidth = 1.2);

    canvas.restore();

    // Clapper with swing
    final clapperSwing = math.sin(progress * math.pi * 6 + math.pi / 4) * 3 * swingDecay;
    canvas.drawCircle(
      Offset(center.dx + clapperSwing, center.dy + 9),
      3,
      Paint()..color = color,
    );

    // Ring waves when animating
    if (progress > 0 && progress < 0.8) {
      final wavePaint = Paint()
        ..color = color.withOpacity(0.3 * (1 - progress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      // Left wave
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx - 12, center.dy - 2),
          width: 6 + progress * 8,
          height: 10 + progress * 8,
        ),
        math.pi / 4,
        math.pi / 2,
        false,
        wavePaint,
      );
      
      // Right wave
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx + 12, center.dy - 2),
          width: 6 + progress * 8,
          height: 10 + progress * 8,
        ),
        math.pi + math.pi / 4,
        -math.pi / 2,
        false,
        wavePaint,
      );
    }

    // Notification dot
    if (isSelected) {
      final dotPaint = Paint()..color = const Color(0xFFEF4444);
      canvas.drawCircle(Offset(center.dx + 8, center.dy - 9), 4, dotPaint);
      
      // Dot highlight
      canvas.drawCircle(
        Offset(center.dx + 7, center.dy - 10),
        1.5,
        Paint()..color = Colors.white.withOpacity(0.6),
      );
    }

    // Glow effect
    if (isSelected) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, 14, glowPaint);
    }
  }

  @override
  bool shouldRepaint(AnimatedAlertsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isSelected != isSelected;
  }
}

/// Animated Profile Icon - User with Wave Effect
class AnimatedProfileIcon extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final double progress;

  const AnimatedProfileIcon({
    super.key,
    required this.isSelected,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: AnimatedProfilePainter(
        progress: progress,
        color: color,
        isSelected: isSelected,
      ),
    );
  }
}

class AnimatedProfilePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isSelected;

  AnimatedProfilePainter({
    required this.progress,
    required this.color,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(isSelected ? 0.2 : 0.1)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Smooth pop animation
    final popScale = 1.0 + math.sin(progress * math.pi) * 0.15;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(popScale);
    canvas.translate(-center.dx, -center.dy);

    final headCenter = Offset(center.dx, center.dy - 4);

    // Head with gradient-like effect
    if (isSelected) {
      canvas.drawCircle(headCenter, 6, fillPaint);
    }
    canvas.drawCircle(headCenter, 6, paint);
    
    // Face details when selected
    if (isSelected) {
      // Eyes
      canvas.drawCircle(Offset(headCenter.dx - 2, headCenter.dy - 1), 1, Paint()..color = color);
      canvas.drawCircle(Offset(headCenter.dx + 2, headCenter.dy - 1), 1, Paint()..color = color);
      
      // Smile
      final smilePath = Path();
      smilePath.addArc(
        Rect.fromCenter(center: Offset(headCenter.dx, headCenter.dy + 1), width: 5, height: 4),
        0.2, math.pi - 0.4,
      );
      canvas.drawPath(smilePath, paint..strokeWidth = 1.2);
    }

    // Body - shoulders
    final bodyPath = Path();
    bodyPath.moveTo(center.dx - 10, center.dy + 14);
    bodyPath.quadraticBezierTo(
      center.dx - 10, center.dy + 6,
      center.dx - 4, center.dy + 4,
    );
    bodyPath.lineTo(center.dx + 4, center.dy + 4);
    bodyPath.quadraticBezierTo(
      center.dx + 10, center.dy + 6,
      center.dx + 10, center.dy + 14,
    );
    
    if (isSelected) {
      final bodyFill = Path.from(bodyPath);
      bodyFill.lineTo(center.dx - 10, center.dy + 14);
      canvas.drawPath(bodyFill, fillPaint);
    }
    canvas.drawPath(bodyPath, paint..strokeWidth = 2.0);

    canvas.restore();

    // Animated badge/checkmark
    if (isSelected && progress > 0.3) {
      final badgeProgress = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
      final badgeScale = _elasticOut(badgeProgress);
      final badgeCenter = Offset(center.dx + 9, center.dy - 7);
      
      // Badge circle
      canvas.drawCircle(
        badgeCenter,
        5 * badgeScale,
        Paint()..color = color,
      );
      
      // Checkmark
      if (badgeProgress > 0.5) {
        final checkProgress = ((badgeProgress - 0.5) / 0.5).clamp(0.0, 1.0);
        final checkPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;
        
        final check = Path();
        check.moveTo(badgeCenter.dx - 2.5, badgeCenter.dy);
        check.lineTo(badgeCenter.dx - 0.5, badgeCenter.dy + 2);
        if (checkProgress > 0.5) {
          check.lineTo(badgeCenter.dx + 2.5, badgeCenter.dy - 2);
        }
        canvas.drawPath(check, checkPaint);
      }
    }

    // Ripple effect when tapped
    if (progress > 0 && progress < 0.6) {
      final rippleRadius = 15 + progress * 20;
      final rippleOpacity = (1 - progress / 0.6) * 0.3;
      canvas.drawCircle(
        center,
        rippleRadius,
        Paint()
          ..color = color.withOpacity(rippleOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Glow effect
    if (isSelected) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, 14, glowPaint);
    }
  }

  double _elasticOut(double t) {
    if (t == 0 || t == 1) return t;
    return math.pow(2, -10 * t) * math.sin((t - 0.1) * 5 * math.pi) + 1;
  }

  @override
  bool shouldRepaint(AnimatedProfilePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isSelected != isSelected;
  }
}
