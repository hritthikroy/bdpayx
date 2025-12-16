import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

// ============================================
// ZUPEE EXACT LUDO - PIXEL PERFECT MATCH
// ============================================

class ZupeeExactLudo extends StatefulWidget {
  final String gameMode;
  final String betAmount;

  const ZupeeExactLudo({
    super.key,
    this.gameMode = 'Quick Match',
    this.betAmount = '50',
  });

  @override
  State<ZupeeExactLudo> createState() => _ZupeeExactLudoState();
}

class _ZupeeExactLudoState extends State<ZupeeExactLudo>
    with TickerProviderStateMixin {
  int _timeLeft = 15;
  Timer? _timer;
  int _diceValue = 1;
  bool _isRolling = false;
  bool _isMyTurn = true;

  late AnimationController _diceController;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _diceController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && _timeLeft > 0) {
        setState(() => _timeLeft--);
      }
    });
  }

  void _rollDice() {
    if (_isRolling) return;
    setState(() => _isRolling = true);
    _diceController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _diceValue = math.Random().nextInt(6) + 1;
          _isRolling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5C6BC0), // Purple-blue top
              Color(0xFF1A237E), // Deep blue
              Color(0xFF0D1B4A), // Dark blue bottom
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Spacer(),
              _buildLudoBoard(),
              const Spacer(),
              _buildDiceSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const Spacer(),
          // Game mode & bet
          Column(
            children: [
              Text(
                widget.gameMode,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '₹ ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.betAmount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _timeLeft <= 5 ? const Color(0xFFE53935) : const Color(0xFFE91E63),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_timeLeft}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLudoBoard() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8B4513), // Wooden brown border
              width: 6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CustomPaint(
              painter: ExactZupeeBoardPainter(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isMyTurn ? const Color(0xFF4CAF50) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Target icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.gps_fixed, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          // Turn text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isMyTurn ? 'Your Turn' : 'Opponent Turn',
                  style: TextStyle(
                    color: _isMyTurn ? const Color(0xFF4CAF50) : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Roll the dice',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Dice
          GestureDetector(
            onTap: _isMyTurn ? _rollDice : null,
            child: AnimatedBuilder(
              animation: _diceController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _diceController.value * math.pi * 2,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: DiceDotsPainter(value: _diceValue),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// EXACT ZUPEE BOARD PAINTER
// ============================================
class ExactZupeeBoardPainter extends CustomPainter {
  // Exact Zupee colors
  static const Color redColor = Color(0xFFE57373);    // Light red/coral
  static const Color yellowColor = Color(0xFFFFEB3B); // Bright yellow
  static const Color greenColor = Color(0xFF81C784);  // Light green
  static const Color blueColor = Color(0xFF64B5F6);   // Light blue
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color pathWhite = Color(0xFFFAFAFA);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;

    // Draw white background first
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = pathWhite,
    );

    // Draw 4 colored quadrants (corners)
    // RED - Top Left
    _drawQuadrant(canvas, 0, 0, cell * 6, redColor, cell);
    // YELLOW - Top Right
    _drawQuadrant(canvas, cell * 9, 0, cell * 6, yellowColor, cell);
    // GREEN - Bottom Left
    _drawQuadrant(canvas, 0, cell * 9, cell * 6, greenColor, cell);
    // BLUE - Bottom Right
    _drawQuadrant(canvas, cell * 9, cell * 9, cell * 6, blueColor, cell);

    // Draw the cross paths with grid
    _drawCrossPaths(canvas, size, cell);

    // Draw colored home columns
    _drawHomeColumns(canvas, cell);

    // Draw center home triangles
    _drawCenterHome(canvas, size, cell);

    // Draw safe spot stars
    _drawSafeStars(canvas, cell);
  }

  void _drawQuadrant(Canvas canvas, double x, double y, double size, Color color, double cell) {
    // Main colored background
    canvas.drawRect(
      Rect.fromLTWH(x, y, size, size),
      Paint()..color = color,
    );

    // Inner white home area with rounded corners
    final padding = size * 0.1;
    final innerSize = size * 0.8;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + padding, y + padding, innerSize, innerSize),
      const Radius.circular(12),
    );
    canvas.drawRRect(innerRect, Paint()..color = whiteColor);

    // Draw 4 token circles in home
    final tokenRadius = size * 0.12;
    final cx = x + size / 2;
    final cy = y + size / 2;
    final offset = size * 0.22;

    final spots = [
      Offset(cx - offset, cy - offset),
      Offset(cx + offset, cy - offset),
      Offset(cx - offset, cy + offset),
      Offset(cx + offset, cy + offset),
    ];

    for (final spot in spots) {
      // Token shadow
      canvas.drawCircle(
        Offset(spot.dx + 2, spot.dy + 2),
        tokenRadius,
        Paint()..color = Colors.black.withOpacity(0.15),
      );

      // Token gradient fill
      final gradient = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Color.lerp(color, Colors.white, 0.4)!,
          color,
          Color.lerp(color, Colors.black, 0.1)!,
        ],
      );
      canvas.drawCircle(
        spot,
        tokenRadius,
        Paint()..shader = gradient.createShader(Rect.fromCircle(center: spot, radius: tokenRadius)),
      );

      // Token highlight
      canvas.drawCircle(
        Offset(spot.dx - tokenRadius * 0.3, spot.dy - tokenRadius * 0.3),
        tokenRadius * 0.25,
        Paint()..color = Colors.white.withOpacity(0.5),
      );

      // Token inner ring (lighter)
      canvas.drawCircle(
        spot,
        tokenRadius * 0.5,
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawCrossPaths(Canvas canvas, Size size, double cell) {
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw grid cells in horizontal path (rows 6, 7, 8)
    for (int row = 6; row < 9; row++) {
      for (int col = 0; col < 15; col++) {
        // Skip center area
        if (col >= 6 && col < 9) continue;
        canvas.drawRect(
          Rect.fromLTWH(cell * col, cell * row, cell, cell),
          borderPaint,
        );
      }
    }

    // Draw grid cells in vertical path (cols 6, 7, 8)
    for (int col = 6; col < 9; col++) {
      for (int row = 0; row < 15; row++) {
        // Skip center area
        if (row >= 6 && row < 9) continue;
        canvas.drawRect(
          Rect.fromLTWH(cell * col, cell * row, cell, cell),
          borderPaint,
        );
      }
    }
  }

  void _drawHomeColumns(Canvas canvas, double cell) {
    // RED home column - Top center going down (col 7, rows 1-5)
    for (int row = 1; row < 6; row++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * 7, cell * row, cell, cell),
        Paint()..color = redColor.withOpacity(0.5),
      );
      // Border
      canvas.drawRect(
        Rect.fromLTWH(cell * 7, cell * row, cell, cell),
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // YELLOW home column - Right center going left (row 7, cols 9-13)
    for (int col = 9; col < 14; col++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * col, cell * 7, cell, cell),
        Paint()..color = yellowColor.withOpacity(0.5),
      );
      canvas.drawRect(
        Rect.fromLTWH(cell * col, cell * 7, cell, cell),
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // BLUE home column - Bottom center going up (col 7, rows 9-13)
    for (int row = 9; row < 14; row++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * 7, cell * row, cell, cell),
        Paint()..color = blueColor.withOpacity(0.5),
      );
      canvas.drawRect(
        Rect.fromLTWH(cell * 7, cell * row, cell, cell),
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // GREEN home column - Left center going right (row 7, cols 1-5)
    for (int col = 1; col < 6; col++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * col, cell * 7, cell, cell),
        Paint()..color = greenColor.withOpacity(0.5),
      );
      canvas.drawRect(
        Rect.fromLTWH(cell * col, cell * 7, cell, cell),
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }
  }

  void _drawCenterHome(Canvas canvas, Size size, double cell) {
    final center = Offset(size.width / 2, size.height / 2);
    final triSize = cell * 1.5;

    // Draw 4 triangles - Red, Yellow, Blue, Green
    final colors = [redColor, yellowColor, blueColor, greenColor];
    final angles = [-math.pi / 2, 0, math.pi / 2, math.pi]; // Top, Right, Bottom, Left

    for (int i = 0; i < 4; i++) {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(angles[i] - math.pi / 4) * triSize,
          center.dy + math.sin(angles[i] - math.pi / 4) * triSize,
        )
        ..lineTo(
          center.dx + math.cos(angles[i] + math.pi / 4) * triSize,
          center.dy + math.sin(angles[i] + math.pi / 4) * triSize,
        )
        ..close();

      canvas.drawPath(path, Paint()..color = colors[i]);
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Center white circle
    canvas.drawCircle(center, cell * 0.35, Paint()..color = whiteColor);
  }

  void _drawSafeStars(Canvas canvas, double cell) {
    final starPositions = [
      // On the paths
      Offset(cell * 2.5, cell * 6.5),   // Left of green
      Offset(cell * 6.5, cell * 2.5),   // Top of red
      Offset(cell * 8.5, cell * 6.5),   // Right side
      Offset(cell * 6.5, cell * 8.5),   // Bottom side
      Offset(cell * 12.5, cell * 8.5),  // Right of yellow
      Offset(cell * 8.5, cell * 12.5),  // Bottom of blue
      Offset(cell * 2.5, cell * 8.5),   // Left side
      Offset(cell * 8.5, cell * 2.5),   // Top side
    ];

    for (final pos in starPositions) {
      _drawStar(canvas, pos, cell * 0.25);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF424242));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================
// DICE DOTS PAINTER
// ============================================
class DiceDotsPainter extends CustomPainter {
  final int value;

  DiceDotsPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final dotRadius = size.width * 0.08;
    final paint = Paint()..color = const Color(0xFF212121);
    final center = Offset(size.width / 2, size.height / 2);

    final positions = <Offset>[];
    switch (value) {
      case 1:
        positions.add(center);
        break;
      case 2:
        positions.addAll([
          Offset(size.width * 0.3, size.height * 0.3),
          Offset(size.width * 0.7, size.height * 0.7),
        ]);
        break;
      case 3:
        positions.addAll([
          Offset(size.width * 0.3, size.height * 0.3),
          center,
          Offset(size.width * 0.7, size.height * 0.7),
        ]);
        break;
      case 4:
        positions.addAll([
          Offset(size.width * 0.3, size.height * 0.3),
          Offset(size.width * 0.7, size.height * 0.3),
          Offset(size.width * 0.3, size.height * 0.7),
          Offset(size.width * 0.7, size.height * 0.7),
        ]);
        break;
      case 5:
        positions.addAll([
          Offset(size.width * 0.3, size.height * 0.3),
          Offset(size.width * 0.7, size.height * 0.3),
          center,
          Offset(size.width * 0.3, size.height * 0.7),
          Offset(size.width * 0.7, size.height * 0.7),
        ]);
        break;
      case 6:
        positions.addAll([
          Offset(size.width * 0.3, size.height * 0.25),
          Offset(size.width * 0.7, size.height * 0.25),
          Offset(size.width * 0.3, size.height * 0.5),
          Offset(size.width * 0.7, size.height * 0.5),
          Offset(size.width * 0.3, size.height * 0.75),
          Offset(size.width * 0.7, size.height * 0.75),
        ]);
        break;
    }

    for (final pos in positions) {
      canvas.drawCircle(pos, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DiceDotsPainter oldDelegate) => oldDelegate.value != value;
}
