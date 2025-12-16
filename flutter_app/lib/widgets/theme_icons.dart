import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom theme-matching icons using CustomPainter
/// These icons are drawn with vectors and will match your theme colors perfectly
class ThemeIcons {
  // Trending Up Icon
  static Widget trendingUp({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrendingUpPainter(color: color ?? const Color(0xFF10B981)),
    );
  }

  // Trending Down Icon
  static Widget trendingDown({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrendingDownPainter(color: color ?? const Color(0xFFEF4444)),
    );
  }

  // Bell/Notification Icon
  static Widget notification({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _NotificationPainter(color: color ?? const Color(0xFFF59E0B)),
    );
  }

  // Delete/Trash Icon
  static Widget delete({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DeletePainter(color: color ?? const Color(0xFFEF4444)),
    );
  }

  // Add/Plus Icon
  static Widget add({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AddPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Chart/Analytics Icon
  static Widget chart({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ChartPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Wallet Icon
  static Widget wallet({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WalletPainter(color: color ?? const Color(0xFF10B981)),
    );
  }

  // Bank Icon
  static Widget bank({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BankPainter(color: color ?? const Color(0xFF3B82F6)),
    );
  }

  // Phone/Mobile Icon
  static Widget phone({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PhonePainter(color: color ?? const Color(0xFFEC4899)),
    );
  }

  // Info Icon
  static Widget info({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _InfoPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Check/Success Icon
  static Widget check({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CheckPainter(color: color ?? const Color(0xFF10B981)),
    );
  }

  // Upload Icon
  static Widget upload({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _UploadPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Arrow Back Icon
  static Widget arrowBack({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ArrowBackPainter(color: color ?? Colors.white),
    );
  }

  // Arrow Forward Icon
  static Widget arrowForward({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ArrowForwardPainter(color: color ?? const Color(0xFF64748B)),
    );
  }

  // Star Icon
  static Widget star({Color? color, double size = 24, bool filled = true}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(color: color ?? const Color(0xFFF59E0B), filled: filled),
    );
  }

  // Play Icon
  static Widget play({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PlayPainter(color: color ?? Colors.white),
    );
  }

  // Gift Icon
  static Widget gift({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GiftPainter(color: color ?? const Color(0xFFF59E0B)),
    );
  }

  // Menu/More Icon (3 dots)
  static Widget more({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MorePainter(color: color ?? Colors.white),
    );
  }

  // Rupee Currency Icon
  static Widget rupee({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RupeePainter(color: color ?? Colors.white),
    );
  }

  // Coin/Money Icon
  static Widget coin({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CoinPainter(color: color ?? const Color(0xFFF59E0B)),
    );
  }

  // Notification Off Icon
  static Widget notificationOff({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _NotificationOffPainter(color: color ?? const Color(0xFF94A3B8)),
    );
  }

  // Home Icon
  static Widget home({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HomePainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Send Icon
  static Widget send({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SendPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Download Icon
  static Widget download({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DownloadPainter(color: color ?? const Color(0xFF10B981)),
    );
  }

  // Copy Icon
  static Widget copy({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CopyPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Share Icon
  static Widget share({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SharePainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Settings Icon
  static Widget settings({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SettingsPainter(color: color ?? const Color(0xFF64748B)),
    );
  }

  // User/Person Icon
  static Widget person({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PersonPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Lock Icon
  static Widget lock({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LockPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Shield Icon
  static Widget shield({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShieldPainter(color: color ?? const Color(0xFF10B981)),
    );
  }

  // Help/Question Icon
  static Widget help({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HelpPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Logout Icon
  static Widget logout({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LogoutPainter(color: color ?? const Color(0xFFEF4444)),
    );
  }

  // Edit Icon
  static Widget edit({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EditPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Camera Icon
  static Widget camera({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CameraPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Close/X Icon
  static Widget close({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ClosePainter(color: color ?? const Color(0xFF64748B)),
    );
  }

  // Refresh Icon
  static Widget refresh({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RefreshPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // History Icon
  static Widget history({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HistoryPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Support/Headset Icon
  static Widget support({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SupportPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Game Controller Icon
  static Widget gamepad({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GamepadPainter(color: color ?? const Color(0xFF8B5CF6)),
    );
  }

  // Dice Icon
  static Widget dice({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DicePainter(color: color ?? const Color(0xFFF59E0B)),
    );
  }

  // Trophy Icon
  static Widget trophy({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrophyPainter(color: color ?? const Color(0xFFF59E0B)),
    );
  }

  // Lightning/Flash Icon
  static Widget flash({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FlashPainter(color: color ?? const Color(0xFFF59E0B)),
    );
  }

  // Credit Card Icon
  static Widget creditCard({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CreditCardPainter(color: color ?? const Color(0xFF3B82F6)),
    );
  }

  // QR Code Icon
  static Widget qrCode({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _QrCodePainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Filter Icon
  static Widget filter({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FilterPainter(color: color ?? const Color(0xFF64748B)),
    );
  }

  // Search Icon
  static Widget search({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SearchPainter(color: color ?? const Color(0xFF64748B)),
    );
  }

  // Calendar Icon
  static Widget calendar({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CalendarPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Document Icon
  static Widget document({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DocumentPainter(color: color ?? const Color(0xFF6366F1)),
    );
  }

  // Eye Icon
  static Widget eye({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EyePainter(color: color ?? const Color(0xFF64748B)),
    );
  }

  // Eye Off Icon
  static Widget eyeOff({Color? color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EyeOffPainter(color: color ?? const Color(0xFF64748B)),
    );
  }
}


// ============ CUSTOM PAINTERS ============

class _TrendingUpPainter extends CustomPainter {
  final Color color;
  _TrendingUpPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.4);
    path.lineTo(size.width * 0.6, size.height * 0.55);
    path.lineTo(size.width * 0.9, size.height * 0.2);
    canvas.drawPath(path, paint);

    // Arrow head
    final arrowPath = Path();
    arrowPath.moveTo(size.width * 0.7, size.height * 0.2);
    arrowPath.lineTo(size.width * 0.9, size.height * 0.2);
    arrowPath.lineTo(size.width * 0.9, size.height * 0.4);
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrendingDownPainter extends CustomPainter {
  final Color color;
  _TrendingDownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.45);
    path.lineTo(size.width * 0.9, size.height * 0.8);
    canvas.drawPath(path, paint);

    // Arrow head
    final arrowPath = Path();
    arrowPath.moveTo(size.width * 0.7, size.height * 0.8);
    arrowPath.lineTo(size.width * 0.9, size.height * 0.8);
    arrowPath.lineTo(size.width * 0.9, size.height * 0.6);
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotificationPainter extends CustomPainter {
  final Color color;
  _NotificationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Bell body
    final bellPath = Path();
    bellPath.moveTo(cx - 8, cy + 4);
    bellPath.cubicTo(cx - 8, cy - 4, cx - 5, cy - 9, cx, cy - 9);
    bellPath.cubicTo(cx + 5, cy - 9, cx + 8, cy - 4, cx + 8, cy + 4);
    bellPath.lineTo(cx - 8, cy + 4);
    canvas.drawPath(bellPath, paint);

    // Bell bottom
    canvas.drawLine(Offset(cx - 10, cy + 4), Offset(cx + 10, cy + 4), paint);

    // Bell top
    canvas.drawCircle(Offset(cx, cy - 9), 2, paint);

    // Clapper
    canvas.drawCircle(Offset(cx, cy + 8), 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DeletePainter extends CustomPainter {
  final Color color;
  _DeletePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    // Trash can body
    final bodyPath = Path();
    bodyPath.moveTo(cx - 6, size.height * 0.35);
    bodyPath.lineTo(cx - 5, size.height * 0.85);
    bodyPath.lineTo(cx + 5, size.height * 0.85);
    bodyPath.lineTo(cx + 6, size.height * 0.35);
    canvas.drawPath(bodyPath, paint);

    // Lid
    canvas.drawLine(Offset(cx - 8, size.height * 0.3), Offset(cx + 8, size.height * 0.3), paint);

    // Handle
    canvas.drawLine(Offset(cx - 3, size.height * 0.3), Offset(cx - 3, size.height * 0.2), paint);
    canvas.drawLine(Offset(cx - 3, size.height * 0.2), Offset(cx + 3, size.height * 0.2), paint);
    canvas.drawLine(Offset(cx + 3, size.height * 0.2), Offset(cx + 3, size.height * 0.3), paint);

    // Lines inside
    canvas.drawLine(Offset(cx - 2.5, size.height * 0.45), Offset(cx - 2.5, size.height * 0.75), paint..strokeWidth = 1.5);
    canvas.drawLine(Offset(cx + 2.5, size.height * 0.45), Offset(cx + 2.5, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AddPainter extends CustomPainter {
  final Color color;
  _AddPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy + 7), paint);
    canvas.drawLine(Offset(cx - 7, cy), Offset(cx + 7, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartPainter extends CustomPainter {
  final Color color;
  _ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Bar chart
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.5, size.width * 0.2, size.height * 0.35), const Radius.circular(2)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.5, size.width * 0.2, size.height * 0.35), const Radius.circular(2)), fillPaint);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.4, size.height * 0.25, size.width * 0.2, size.height * 0.6), const Radius.circular(2)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.4, size.height * 0.25, size.width * 0.2, size.height * 0.6), const Radius.circular(2)), fillPaint);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.7, size.height * 0.15, size.width * 0.2, size.height * 0.7), const Radius.circular(2)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.7, size.height * 0.15, size.width * 0.2, size.height * 0.7), const Radius.circular(2)), fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WalletPainter extends CustomPainter {
  final Color color;
  _WalletPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Wallet body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.25, size.width * 0.8, size.height * 0.55), const Radius.circular(4)),
      paint,
    );

    // Flap
    final flapPath = Path();
    flapPath.moveTo(size.width * 0.1, size.height * 0.35);
    flapPath.lineTo(size.width * 0.1, size.height * 0.2);
    flapPath.quadraticBezierTo(size.width * 0.1, size.height * 0.15, size.width * 0.2, size.height * 0.15);
    flapPath.lineTo(size.width * 0.8, size.height * 0.15);
    canvas.drawPath(flapPath, paint);

    // Card slot
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.6, size.height * 0.45, size.width * 0.25, size.height * 0.15), const Radius.circular(2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BankPainter extends CustomPainter {
  final Color color;
  _BankPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    // Roof triangle
    final roofPath = Path();
    roofPath.moveTo(cx, size.height * 0.1);
    roofPath.lineTo(size.width * 0.1, size.height * 0.35);
    roofPath.lineTo(size.width * 0.9, size.height * 0.35);
    roofPath.close();
    canvas.drawPath(roofPath, paint);

    // Pillars
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.4), Offset(size.width * 0.25, size.height * 0.75), paint);
    canvas.drawLine(Offset(cx, size.height * 0.4), Offset(cx, size.height * 0.75), paint);
    canvas.drawLine(Offset(size.width * 0.75, size.height * 0.4), Offset(size.width * 0.75, size.height * 0.75), paint);

    // Base
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.8), Offset(size.width * 0.9, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhonePainter extends CustomPainter {
  final Color color;
  _PhonePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Phone body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.25, size.height * 0.1, size.width * 0.5, size.height * 0.8), const Radius.circular(4)),
      paint,
    );

    // Screen
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.2, size.width * 0.4, size.height * 0.55), paint);

    // Home button
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.83), 2.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoPainter extends CustomPainter {
  final Color color;
  _InfoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.4, paint);

    // Dot
    canvas.drawCircle(Offset(cx, cy - 4), 2, Paint()..color = color);

    // Line
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy + 6), paint..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CheckPainter extends CustomPainter {
  final Color color;
  _CheckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UploadPainter extends CustomPainter {
  final Color color;
  _UploadPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    // Arrow up
    canvas.drawLine(Offset(cx, size.height * 0.2), Offset(cx, size.height * 0.65), paint);
    canvas.drawLine(Offset(cx - 5, size.height * 0.35), Offset(cx, size.height * 0.2), paint);
    canvas.drawLine(Offset(cx + 5, size.height * 0.35), Offset(cx, size.height * 0.2), paint);

    // Base line
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.8), Offset(size.width * 0.8, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArrowBackPainter extends CustomPainter {
  final Color color;
  _ArrowBackPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cy = size.height / 2;

    canvas.drawLine(Offset(size.width * 0.75, cy), Offset(size.width * 0.25, cy), paint);
    canvas.drawLine(Offset(size.width * 0.45, cy - 6), Offset(size.width * 0.25, cy), paint);
    canvas.drawLine(Offset(size.width * 0.45, cy + 6), Offset(size.width * 0.25, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArrowForwardPainter extends CustomPainter {
  final Color color;
  _ArrowForwardPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cy = size.height / 2;

    canvas.drawLine(Offset(size.width * 0.25, cy), Offset(size.width * 0.75, cy), paint);
    canvas.drawLine(Offset(size.width * 0.55, cy - 6), Offset(size.width * 0.75, cy), paint);
    canvas.drawLine(Offset(size.width * 0.55, cy + 6), Offset(size.width * 0.75, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  final Color color;
  final bool filled;
  _StarPainter({required this.color, required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;
      
      if (i == 0) {
        path.moveTo(cx + r * math.cos(angle), cy + r * math.sin(angle));
      } else {
        path.lineTo(cx + r * math.cos(angle), cy + r * math.sin(angle));
      }
      path.lineTo(cx + r * 0.4 * math.cos(innerAngle), cy + r * 0.4 * math.sin(innerAngle));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayPainter extends CustomPainter {
  final Color color;
  _PlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.15);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.lineTo(size.width * 0.25, size.height * 0.85);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GiftPainter extends CustomPainter {
  final Color color;
  _GiftPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    // Box
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.15, size.height * 0.4, size.width * 0.7, size.height * 0.5), const Radius.circular(3)),
      paint,
    );

    // Lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.3, size.width * 0.8, size.height * 0.15), const Radius.circular(3)),
      paint,
    );

    // Ribbon vertical
    canvas.drawLine(Offset(cx, size.height * 0.3), Offset(cx, size.height * 0.9), paint);

    // Bow
    canvas.drawArc(Rect.fromLTWH(cx - 8, size.height * 0.12, 8, 12), 0, math.pi, false, paint);
    canvas.drawArc(Rect.fromLTWH(cx, size.height * 0.12, 8, 12), math.pi, math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MorePainter extends CustomPainter {
  final Color color;
  _MorePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cy = size.height / 2;

    canvas.drawCircle(Offset(size.width * 0.2, cy), 2.5, paint);
    canvas.drawCircle(Offset(size.width * 0.5, cy), 2.5, paint);
    canvas.drawCircle(Offset(size.width * 0.8, cy), 2.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RupeePainter extends CustomPainter {
  final Color color;
  _RupeePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Top line
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.2), Offset(size.width * 0.75, size.height * 0.2), paint);

    // Second line
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.35), Offset(size.width * 0.75, size.height * 0.35), paint);

    // Curve
    final curvePath = Path();
    curvePath.moveTo(size.width * 0.35, size.height * 0.2);
    curvePath.quadraticBezierTo(size.width * 0.65, size.height * 0.2, size.width * 0.65, size.height * 0.35);
    curvePath.quadraticBezierTo(size.width * 0.65, size.height * 0.5, size.width * 0.35, size.height * 0.5);
    canvas.drawPath(curvePath, paint);

    // Diagonal
    canvas.drawLine(Offset(size.width * 0.35, size.height * 0.5), Offset(size.width * 0.65, size.height * 0.85), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CoinPainter extends CustomPainter {
  final Color color;
  _CoinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.4, paint);

    // Inner circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.25, paint);

    // Dollar sign or currency symbol
    canvas.drawLine(Offset(cx, cy - 5), Offset(cx, cy + 5), paint..strokeWidth = 2.5);
    canvas.drawLine(Offset(cx - 3, cy - 2), Offset(cx + 3, cy - 2), paint..strokeWidth = 1.5);
    canvas.drawLine(Offset(cx - 3, cy + 2), Offset(cx + 3, cy + 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotificationOffPainter extends CustomPainter {
  final Color color;
  _NotificationOffPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Bell body
    final bellPath = Path();
    bellPath.moveTo(cx - 8, cy + 4);
    bellPath.cubicTo(cx - 8, cy - 4, cx - 5, cy - 9, cx, cy - 9);
    bellPath.cubicTo(cx + 5, cy - 9, cx + 8, cy - 4, cx + 8, cy + 4);
    bellPath.lineTo(cx - 8, cy + 4);
    canvas.drawPath(bellPath, paint);

    canvas.drawLine(Offset(cx - 10, cy + 4), Offset(cx + 10, cy + 4), paint);
    canvas.drawCircle(Offset(cx, cy - 9), 2, paint);
    canvas.drawCircle(Offset(cx, cy + 8), 2.5, Paint()..color = color);

    // Strike through
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.85), Offset(size.width * 0.85, size.height * 0.15), paint..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _HomePainter extends CustomPainter {
  final Color color;
  _HomePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;

    // Roof
    final roofPath = Path();
    roofPath.moveTo(cx, size.height * 0.15);
    roofPath.lineTo(size.width * 0.1, size.height * 0.45);
    roofPath.lineTo(size.width * 0.9, size.height * 0.45);
    roofPath.close();
    canvas.drawPath(roofPath, paint);

    // House body
    canvas.drawRect(Rect.fromLTWH(size.width * 0.2, size.height * 0.45, size.width * 0.6, size.height * 0.4), paint);

    // Door
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 4, size.height * 0.55, 8, size.height * 0.3), const Radius.circular(2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SendPainter extends CustomPainter {
  final Color color;
  _SendPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.5);
    path.lineTo(size.width * 0.9, size.height * 0.15);
    path.lineTo(size.width * 0.55, size.height * 0.5);
    path.lineTo(size.width * 0.9, size.height * 0.85);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _DownloadPainter extends CustomPainter {
  final Color color;
  _DownloadPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    canvas.drawLine(Offset(cx, size.height * 0.15), Offset(cx, size.height * 0.6), paint);
    canvas.drawLine(Offset(cx - 5, size.height * 0.45), Offset(cx, size.height * 0.6), paint);
    canvas.drawLine(Offset(cx + 5, size.height * 0.45), Offset(cx, size.height * 0.6), paint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.8), Offset(size.width * 0.8, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CopyPainter extends CustomPainter {
  final Color color;
  _CopyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Back rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.25, size.height * 0.1, size.width * 0.55, size.height * 0.55), const Radius.circular(3)),
      paint,
    );

    // Front rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.2, size.height * 0.35, size.width * 0.55, size.height * 0.55), const Radius.circular(3)),
      Paint()..color = color..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.2, size.height * 0.35, size.width * 0.55, size.height * 0.55), const Radius.circular(3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _SharePainter extends CustomPainter {
  final Color color;
  _SharePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Three circles
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.25), 4, paint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.5), 4, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.75), 4, paint);

    // Lines
    canvas.drawLine(Offset(size.width * 0.32, size.height * 0.45), Offset(size.width * 0.68, size.height * 0.3), paint);
    canvas.drawLine(Offset(size.width * 0.32, size.height * 0.55), Offset(size.width * 0.68, size.height * 0.7), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SettingsPainter extends CustomPainter {
  final Color color;
  _SettingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer gear
    canvas.drawCircle(Offset(cx, cy), size.width * 0.35, paint);

    // Inner circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.15, paint);

    // Gear teeth
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final innerR = size.width * 0.35;
      final outerR = size.width * 0.45;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(angle), cy + innerR * math.sin(angle)),
        Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle)),
        paint..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _PersonPainter extends CustomPainter {
  final Color color;
  _PersonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;

    // Head
    canvas.drawCircle(Offset(cx, size.height * 0.3), size.width * 0.2, paint);

    // Body
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.2, size.height * 0.9);
    bodyPath.quadraticBezierTo(size.width * 0.2, size.height * 0.55, cx, size.height * 0.55);
    bodyPath.quadraticBezierTo(size.width * 0.8, size.height * 0.55, size.width * 0.8, size.height * 0.9);
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LockPainter extends CustomPainter {
  final Color color;
  _LockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    // Lock body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.2, size.height * 0.4, size.width * 0.6, size.height * 0.5), const Radius.circular(4)),
      paint,
    );

    // Shackle
    final shacklePath = Path();
    shacklePath.moveTo(size.width * 0.3, size.height * 0.4);
    shacklePath.lineTo(size.width * 0.3, size.height * 0.3);
    shacklePath.quadraticBezierTo(size.width * 0.3, size.height * 0.15, cx, size.height * 0.15);
    shacklePath.quadraticBezierTo(size.width * 0.7, size.height * 0.15, size.width * 0.7, size.height * 0.3);
    shacklePath.lineTo(size.width * 0.7, size.height * 0.4);
    canvas.drawPath(shacklePath, paint);

    // Keyhole
    canvas.drawCircle(Offset(cx, size.height * 0.58), 3, paint);
    canvas.drawLine(Offset(cx, size.height * 0.62), Offset(cx, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _ShieldPainter extends CustomPainter {
  final Color color;
  _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;

    final path = Path();
    path.moveTo(cx, size.height * 0.1);
    path.lineTo(size.width * 0.85, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.85, size.height * 0.6, cx, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.6, size.width * 0.15, size.height * 0.25);
    path.close();
    canvas.drawPath(path, paint);

    // Checkmark
    final checkPath = Path();
    checkPath.moveTo(size.width * 0.3, size.height * 0.5);
    checkPath.lineTo(size.width * 0.45, size.height * 0.65);
    checkPath.lineTo(size.width * 0.7, size.height * 0.35);
    canvas.drawPath(checkPath, paint..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HelpPainter extends CustomPainter {
  final Color color;
  _HelpPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(Offset(cx, cy), size.width * 0.4, paint);

    // Question mark
    final qPath = Path();
    qPath.moveTo(cx - 4, cy - 5);
    qPath.quadraticBezierTo(cx - 4, cy - 10, cx, cy - 10);
    qPath.quadraticBezierTo(cx + 5, cy - 10, cx + 5, cy - 5);
    qPath.quadraticBezierTo(cx + 5, cy, cx, cy + 2);
    canvas.drawPath(qPath, paint..strokeCap = StrokeCap.round);

    canvas.drawCircle(Offset(cx, cy + 7), 1.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _LogoutPainter extends CustomPainter {
  final Color color;
  _LogoutPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cy = size.height / 2;

    // Door frame
    final doorPath = Path();
    doorPath.moveTo(size.width * 0.5, size.height * 0.15);
    doorPath.lineTo(size.width * 0.2, size.height * 0.15);
    doorPath.lineTo(size.width * 0.2, size.height * 0.85);
    doorPath.lineTo(size.width * 0.5, size.height * 0.85);
    canvas.drawPath(doorPath, paint);

    // Arrow
    canvas.drawLine(Offset(size.width * 0.4, cy), Offset(size.width * 0.85, cy), paint);
    canvas.drawLine(Offset(size.width * 0.7, cy - 5), Offset(size.width * 0.85, cy), paint);
    canvas.drawLine(Offset(size.width * 0.7, cy + 5), Offset(size.width * 0.85, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EditPainter extends CustomPainter {
  final Color color;
  _EditPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Pencil body
    final pencilPath = Path();
    pencilPath.moveTo(size.width * 0.75, size.height * 0.15);
    pencilPath.lineTo(size.width * 0.85, size.height * 0.25);
    pencilPath.lineTo(size.width * 0.35, size.height * 0.75);
    pencilPath.lineTo(size.width * 0.15, size.height * 0.85);
    pencilPath.lineTo(size.width * 0.25, size.height * 0.65);
    pencilPath.close();
    canvas.drawPath(pencilPath, paint);

    // Tip line
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.65), Offset(size.width * 0.35, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _CameraPainter extends CustomPainter {
  final Color color;
  _CameraPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;

    // Camera body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.3, size.width * 0.8, size.height * 0.5), const Radius.circular(4)),
      paint,
    );

    // Top bump
    final topPath = Path();
    topPath.moveTo(size.width * 0.35, size.height * 0.3);
    topPath.lineTo(size.width * 0.4, size.height * 0.2);
    topPath.lineTo(size.width * 0.6, size.height * 0.2);
    topPath.lineTo(size.width * 0.65, size.height * 0.3);
    canvas.drawPath(topPath, paint);

    // Lens
    canvas.drawCircle(Offset(cx, size.height * 0.55), size.width * 0.15, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClosePainter extends CustomPainter {
  final Color color;
  _ClosePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.25), Offset(size.width * 0.75, size.height * 0.75), paint);
    canvas.drawLine(Offset(size.width * 0.75, size.height * 0.25), Offset(size.width * 0.25, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _RefreshPainter extends CustomPainter {
  final Color color;
  _RefreshPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Arc
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.7, height: size.height * 0.7), -math.pi * 0.7, math.pi * 1.4, false, paint);

    // Arrow head
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.25), Offset(size.width * 0.8, size.height * 0.35), paint);
    canvas.drawLine(Offset(size.width * 0.6, size.height * 0.35), Offset(size.width * 0.7, size.height * 0.25), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HistoryPainter extends CustomPainter {
  final Color color;
  _HistoryPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Clock circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.35, paint);

    // Clock hands
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - 6), paint..strokeWidth = 2.5);
    canvas.drawLine(Offset(cx, cy), Offset(cx + 5, cy + 2), paint..strokeWidth = 2.0);

    // Rewind arrow
    final arrowPath = Path();
    arrowPath.moveTo(size.width * 0.15, cy - 3);
    arrowPath.lineTo(size.width * 0.15, cy - 8);
    arrowPath.lineTo(size.width * 0.25, cy - 5);
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _SupportPainter extends CustomPainter {
  final Color color;
  _SupportPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    // Headband
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, size.height * 0.4), width: size.width * 0.7, height: size.height * 0.5), math.pi, math.pi, false, paint);

    // Left ear cup
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.35, size.width * 0.2, size.height * 0.3), const Radius.circular(3)), paint);

    // Right ear cup
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.7, size.height * 0.35, size.width * 0.2, size.height * 0.3), const Radius.circular(3)), paint);

    // Microphone
    final micPath = Path();
    micPath.moveTo(size.width * 0.8, size.height * 0.6);
    micPath.quadraticBezierTo(size.width * 0.65, size.height * 0.8, cx, size.height * 0.8);
    canvas.drawPath(micPath, paint);
    canvas.drawCircle(Offset(cx, size.height * 0.8), 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GamepadPainter extends CustomPainter {
  final Color color;
  _GamepadPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Controller body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.3, size.width * 0.8, size.height * 0.4), const Radius.circular(8)), paint);

    // D-pad
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.45), Offset(size.width * 0.25, size.height * 0.6), paint);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.52), Offset(size.width * 0.32, size.height * 0.52), paint);

    // Buttons
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.45), 3, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.52), 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _DicePainter extends CustomPainter {
  final Color color;
  _DicePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dice body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.15, size.height * 0.15, size.width * 0.7, size.height * 0.7), const Radius.circular(4)), paint);

    // Dots
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.35), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.35), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.65), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.65), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrophyPainter extends CustomPainter {
  final Color color;
  _TrophyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    // Cup body
    final cupPath = Path();
    cupPath.moveTo(size.width * 0.2, size.height * 0.15);
    cupPath.lineTo(size.width * 0.8, size.height * 0.15);
    cupPath.quadraticBezierTo(size.width * 0.8, size.height * 0.55, cx, size.height * 0.6);
    cupPath.quadraticBezierTo(size.width * 0.2, size.height * 0.55, size.width * 0.2, size.height * 0.15);
    canvas.drawPath(cupPath, paint);

    // Handles
    canvas.drawArc(Rect.fromLTWH(size.width * 0.05, size.height * 0.2, size.width * 0.2, size.height * 0.2), math.pi / 2, math.pi, false, paint);
    canvas.drawArc(Rect.fromLTWH(size.width * 0.75, size.height * 0.2, size.width * 0.2, size.height * 0.2), -math.pi / 2, math.pi, false, paint);

    // Stem
    canvas.drawLine(Offset(cx, size.height * 0.6), Offset(cx, size.height * 0.75), paint);

    // Base
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.85), Offset(size.width * 0.7, size.height * 0.85), paint);
    canvas.drawLine(Offset(size.width * 0.35, size.height * 0.75), Offset(size.width * 0.65, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _FlashPainter extends CustomPainter {
  final Color color;
  _FlashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.6, size.height * 0.1);
    path.lineTo(size.width * 0.25, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.9);
    path.lineTo(size.width * 0.75, size.height * 0.45);
    path.lineTo(size.width * 0.55, size.height * 0.45);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CreditCardPainter extends CustomPainter {
  final Color color;
  _CreditCardPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Card body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6), const Radius.circular(4)), paint);

    // Stripe
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.38), Offset(size.width * 0.9, size.height * 0.38), paint..strokeWidth = 4);

    // Chip
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.2, size.height * 0.5, size.width * 0.15, size.height * 0.15), const Radius.circular(2)), paint..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QrCodePainter extends CustomPainter {
  final Color color;
  _QrCodePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Outer squares
    canvas.drawRect(Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.3, size.height * 0.3), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, size.height * 0.1, size.width * 0.3, size.height * 0.3), paint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.1, size.height * 0.6, size.width * 0.3, size.height * 0.3), paint);

    // Inner squares
    final fillPaint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.18, size.height * 0.18, size.width * 0.14, size.height * 0.14), fillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.68, size.height * 0.18, size.width * 0.14, size.height * 0.14), fillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.18, size.height * 0.68, size.width * 0.14, size.height * 0.14), fillPaint);

    // Data dots
    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, size.height * 0.6, size.width * 0.1, size.height * 0.1), fillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.75, size.height * 0.75, size.width * 0.1, size.height * 0.1), fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _FilterPainter extends CustomPainter {
  final Color color;
  _FilterPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Three horizontal lines with circles
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.25), Offset(size.width * 0.85, size.height * 0.25), paint);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.25), 4, Paint()..color = color);

    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.5), Offset(size.width * 0.85, size.height * 0.5), paint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.5), 4, Paint()..color = color);

    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.75), Offset(size.width * 0.85, size.height * 0.75), paint);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.75), 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SearchPainter extends CustomPainter {
  final Color color;
  _SearchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Circle
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), size.width * 0.28, paint);

    // Handle
    canvas.drawLine(Offset(size.width * 0.6, size.height * 0.6), Offset(size.width * 0.85, size.height * 0.85), paint..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CalendarPainter extends CustomPainter {
  final Color color;
  _CalendarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Calendar body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.7), const Radius.circular(4)), paint);

    // Top line
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.38), Offset(size.width * 0.9, size.height * 0.38), paint);

    // Hooks
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.1), Offset(size.width * 0.3, size.height * 0.28), paint..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.1), Offset(size.width * 0.7, size.height * 0.28), paint);

    // Date dots
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.55), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.55), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.75), 2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.75), 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _DocumentPainter extends CustomPainter {
  final Color color;
  _DocumentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Document body
    final docPath = Path();
    docPath.moveTo(size.width * 0.2, size.height * 0.1);
    docPath.lineTo(size.width * 0.6, size.height * 0.1);
    docPath.lineTo(size.width * 0.8, size.height * 0.3);
    docPath.lineTo(size.width * 0.8, size.height * 0.9);
    docPath.lineTo(size.width * 0.2, size.height * 0.9);
    docPath.close();
    canvas.drawPath(docPath, paint);

    // Fold
    canvas.drawLine(Offset(size.width * 0.6, size.height * 0.1), Offset(size.width * 0.6, size.height * 0.3), paint);
    canvas.drawLine(Offset(size.width * 0.6, size.height * 0.3), Offset(size.width * 0.8, size.height * 0.3), paint);

    // Lines
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.5), Offset(size.width * 0.7, size.height * 0.5), paint..strokeWidth = 1.5);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.65), Offset(size.width * 0.7, size.height * 0.65), paint);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.8), Offset(size.width * 0.55, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EyePainter extends CustomPainter {
  final Color color;
  _EyePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Eye outline
    final eyePath = Path();
    eyePath.moveTo(size.width * 0.1, cy);
    eyePath.quadraticBezierTo(cx, size.height * 0.2, size.width * 0.9, cy);
    eyePath.quadraticBezierTo(cx, size.height * 0.8, size.width * 0.1, cy);
    canvas.drawPath(eyePath, paint);

    // Pupil
    canvas.drawCircle(Offset(cx, cy), size.width * 0.12, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EyeOffPainter extends CustomPainter {
  final Color color;
  _EyeOffPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Eye outline
    final eyePath = Path();
    eyePath.moveTo(size.width * 0.1, cy);
    eyePath.quadraticBezierTo(cx, size.height * 0.2, size.width * 0.9, cy);
    eyePath.quadraticBezierTo(cx, size.height * 0.8, size.width * 0.1, cy);
    canvas.drawPath(eyePath, paint);

    // Pupil
    canvas.drawCircle(Offset(cx, cy), size.width * 0.12, Paint()..color = color);

    // Strike through
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.85), Offset(size.width * 0.85, size.height * 0.15), paint..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
