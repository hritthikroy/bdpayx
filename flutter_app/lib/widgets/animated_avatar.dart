import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class AnimatedAvatar extends StatefulWidget {
  final double size;
  final String? userName;

  const AnimatedAvatar({
    super.key,
    required this.size,
    this.userName,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _pulseController;
  late Animation<double> _blinkAnimation;
  late Animation<double> _pulseAnimation;
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _tiltX = 0.0; // Left/Right tilt
  double _tiltY = 0.0; // Up/Down tilt

  @override
  void initState() {
    super.initState();

    // Blink animation - eyes close and open
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Pulse animation - gentle scale
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startBlinking();
    _startPulsing();
    _startAccelerometer();
  }
  
  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (mounted) {
          setState(() {
            // Normalize tilt values (-1 to 1 range)
            // X axis: left/right tilt
            // Y axis: forward/backward tilt
            _tiltX = (event.x / 10).clamp(-1.0, 1.0);
            _tiltY = (event.y / 10).clamp(-1.0, 1.0);
          });
        }
      },
      onError: (error) {
        // Silently handle errors (sensor might not be available on web)
      },
    );
  }

  void _startBlinking() {
    Future.delayed(Duration(seconds: 2 + math.Random().nextInt(3)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  void _startPulsing() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _pulseController.forward().then((_) {
          _pulseController.reverse().then((_) {
            _startPulsing();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _pulseController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(_tiltX * 0.3) // Rotate based on left/right tilt
          ..rotateX(-_tiltY * 0.3), // Rotate based on forward/backward tilt
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _blinkAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: AvatarPainter(
                blinkValue: _blinkAnimation.value,
                userName: widget.userName,
                tiltX: _tiltX,
                tiltY: _tiltY,
              ),
            );
          },
        ),
      ),
    );
  }
}

class AvatarPainter extends CustomPainter {
  final double blinkValue;
  final String? userName;
  final double tiltX;
  final double tiltY;

  AvatarPainter({
    required this.blinkValue,
    this.userName,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw vibrant gradient head circle with cool colors
    final headPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF00D9FF), // Bright Cyan
          const Color(0xFF6366F1), // Indigo
          const Color(0xFF8B5CF6), // Purple
          const Color(0xFFFF6B9D), // Pink
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, headPaint);

    // Draw vibrant highlight for depth
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.4, -0.4),
        radius: 0.6,
        colors: [
          Colors.white.withOpacity(0.5),
          const Color(0xFF00D9FF).withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, highlightPaint);

    // Draw animated border with vibrant gradient
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF00D9FF).withOpacity(0.8),
          Colors.white.withOpacity(0.9),
          const Color(0xFFFF6B9D).withOpacity(0.8),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;
    canvas.drawCircle(center, radius - (size.width * 0.03), borderPaint);

    // Calculate eye positions with tilt offset
    final eyeY = center.dy - radius * 0.15;
    final eyeSpacing = radius * 0.35;
    
    // Move eyes based on tilt (pupils follow the tilt direction)
    final eyeOffsetX = tiltX * radius * 0.15;
    final eyeOffsetY = tiltY * radius * 0.15;
    
    final leftEyeCenter = Offset(
      center.dx - eyeSpacing + eyeOffsetX,
      eyeY + eyeOffsetY,
    );
    final rightEyeCenter = Offset(
      center.dx + eyeSpacing + eyeOffsetX,
      eyeY + eyeOffsetY,
    );
    final eyeRadius = radius * 0.12;

    // Draw eyes (white circles that close when blinking)
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (blinkValue > 0.1) {
      // Left eye
      canvas.drawOval(
        Rect.fromCenter(
          center: leftEyeCenter,
          width: eyeRadius * 2,
          height: eyeRadius * 2 * blinkValue,
        ),
        eyePaint,
      );

      // Right eye
      canvas.drawOval(
        Rect.fromCenter(
          center: rightEyeCenter,
          width: eyeRadius * 2,
          height: eyeRadius * 2 * blinkValue,
        ),
        eyePaint,
      );

      // Eye pupils (vibrant gradient dots)
      final pupilRadius = eyeRadius * 0.5;
      
      // Left pupil
      final leftPupilPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF00D9FF),
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
        ).createShader(Rect.fromCircle(center: leftEyeCenter, radius: pupilRadius))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(leftEyeCenter, pupilRadius, leftPupilPaint);
      
      // Right pupil
      final rightPupilPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF00D9FF),
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
        ).createShader(Rect.fromCircle(center: rightEyeCenter, radius: pupilRadius))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(rightEyeCenter, pupilRadius, rightPupilPaint);

      // Eye shine (white dots)
      final shinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final shineRadius = eyeRadius * 0.25;

      canvas.drawCircle(
        Offset(leftEyeCenter.dx - eyeRadius * 0.2,
            leftEyeCenter.dy - eyeRadius * 0.2),
        shineRadius,
        shinePaint,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx - eyeRadius * 0.2,
            rightEyeCenter.dy - eyeRadius * 0.2),
        shineRadius,
        shinePaint,
      );
    } else {
      // Eyes closed - draw white lines
      final closedEyePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.04
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(leftEyeCenter.dx - eyeRadius, leftEyeCenter.dy),
        Offset(leftEyeCenter.dx + eyeRadius, leftEyeCenter.dy),
        closedEyePaint,
      );
      canvas.drawLine(
        Offset(rightEyeCenter.dx - eyeRadius, rightEyeCenter.dy),
        Offset(rightEyeCenter.dx + eyeRadius, rightEyeCenter.dy),
        closedEyePaint,
      );
    }

    // Draw smile (white)
    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    final smileY = center.dy + radius * 0.2;
    final smileWidth = radius * 0.6;
    smilePath.moveTo(center.dx - smileWidth / 2, smileY);
    smilePath.quadraticBezierTo(
      center.dx,
      smileY + radius * 0.25,
      center.dx + smileWidth / 2,
      smileY,
    );
    canvas.drawPath(smilePath, smilePaint);

    // Draw initial letter with white color
    if (userName != null && userName!.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: userName![0].toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.15),
            fontSize: radius * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(AvatarPainter oldDelegate) {
    return oldDelegate.blinkValue != blinkValue ||
        oldDelegate.tiltX != tiltX ||
        oldDelegate.tiltY != tiltY;
  }
}
