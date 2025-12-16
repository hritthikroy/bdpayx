import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

// ============================================
// PROFESSIONAL ZUPEE LUDO - EXACT STYLE MATCH
// ============================================

class ProfessionalZupeeLudo extends StatefulWidget {
  final String opponentName;
  final String betAmount;
  final String gameMode;

  const ProfessionalZupeeLudo({
    super.key,
    this.opponentName = 'Deepak',
    this.betAmount = '4500',
    this.gameMode = 'Classic',
  });

  @override
  State<ProfessionalZupeeLudo> createState() => _ProfessionalZupeeLudoState();
}

class _ProfessionalZupeeLudoState extends State<ProfessionalZupeeLudo>
    with TickerProviderStateMixin {
  
  // Game State
  int _diceValue = 1;
  bool _isRolling = false;
  bool _isMyTurn = true;
  int _timeLeft = 477; // 7:57 in seconds
  Timer? _turnTimer;
  
  // Player scores (Zupee style)
  int _player1Score = 60;  // Blue (bottom-left)
  int _player2Score = 125; // Red (top-right)
  int _player3Score = 30;  // Yellow (bottom-left corner)
  int _player4Score = 45;  // Green (bottom-right)
  
  // Token positions for each player (4 tokens each)
  // -1 = home, 0-51 = on board, 52+ = in home column, 57 = finished
  List<int> _blueTokens = [-1, -1, 5, 12];
  List<int> _redTokens = [-1, 8, 15, -1];
  List<int> _yellowTokens = [-1, -1, 22, 28];
  List<int> _greenTokens = [-1, 35, -1, 42];
  
  late AnimationController _diceController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _startGameTimer();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _diceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startGameTimer() {
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timeLeft > 0) {
        setState(() => _timeLeft--);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  void _rollDice() {
    if (_isRolling) return;
    setState(() => _isRolling = true);
    _diceController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 600), () {
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
              Color(0xFF1a237e), // Deep blue top
              Color(0xFF0d1b4a), // Darker blue bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopHeader(),
              _buildTopPlayersRow(),
              Expanded(child: _buildLudoBoard()),
              _buildBottomPlayersRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP HEADER - Prize Pot & Timer
  // ==========================================
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          const Spacer(),
          
          // Prize Pot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFF5D4037), size: 20),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Prize Pot',
                      style: TextStyle(
                        color: Color(0xFF5D4037),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.betAmount,
                      style: const TextStyle(
                        color: Color(0xFF5D4037),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Settings button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP PLAYERS ROW - Priya & Deepak
  // ==========================================
  Widget _buildTopPlayersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left player (Priya - Blue)
          _buildPlayerInfo('Priya', const Color(0xFF1565C0), true, isLeft: true),
          
          // Timer in center
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Time Left',
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                    Text(
                      _formatTime(_timeLeft),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Right player (Deepak - Red)
          _buildPlayerInfo('Deepak', const Color(0xFFc62828), false, isLeft: false),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(String name, Color color, bool isActive, {required bool isLeft}) {
    return Row(
      children: [
        if (!isLeft) ...[
          _buildCrownButton(color),
          const SizedBox(width: 8),
        ],
        
        // Avatar with ring
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFFFFD700) : color,
              width: 3,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.3),
            child: Icon(Icons.person, color: color, size: 24),
          ),
        ),
        
        if (isLeft) ...[
          const SizedBox(width: 8),
          _buildCrownButton(color),
        ],
      ],
    );
  }

  Widget _buildCrownButton(Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.workspace_premium,
        color: color,
        size: 22,
      ),
    );
  }

  // ==========================================
  // LUDO BOARD - Main Game Board
  // ==========================================
  Widget _buildLudoBoard() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: ZupeeLudoBoardPainter(
                blueTokens: _blueTokens,
                redTokens: _redTokens,
                yellowTokens: _yellowTokens,
                greenTokens: _greenTokens,
                player1Score: _player1Score,
                player2Score: _player2Score,
                player3Score: _player3Score,
                player4Score: _player4Score,
              ),
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM PLAYERS ROW
  // ==========================================
  Widget _buildBottomPlayersRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0d1b4a).withOpacity(0.9),
            const Color(0xFF1a237e).withOpacity(0.9),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left player (Yellow)
          _buildBottomPlayer('Kanik', const Color(0xFFFFC107), true),
          
          // Dice buttons
          Row(
            children: [
              _buildDiceButton(const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              _buildHomeButton(),
              const SizedBox(width: 12),
              _buildDiceButton(const Color(0xFFFFC107)),
            ],
          ),
          
          // Right player (Green)
          _buildBottomPlayer('Ranjit', const Color(0xFF4CAF50), false),
        ],
      ),
    );
  }

  Widget _buildBottomPlayer(String name, Color color, bool isLeft) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.3),
            child: Icon(Icons.person, color: color, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDiceButton(Color color) {
    return GestureDetector(
      onTap: _rollDice,
      child: AnimatedBuilder(
        animation: _diceController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _diceController.value * math.pi * 2,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.workspace_premium,
                  color: color,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeButton() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF37474F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: const Icon(Icons.home, color: Colors.white, size: 28),
    );
  }
}


// ============================================
// ZUPEE LUDO BOARD PAINTER - EXACT STYLE
// ============================================
class ZupeeLudoBoardPainter extends CustomPainter {
  final List<int> blueTokens;
  final List<int> redTokens;
  final List<int> yellowTokens;
  final List<int> greenTokens;
  final int player1Score;
  final int player2Score;
  final int player3Score;
  final int player4Score;

  // Zupee Colors - Exact match
  static const Color blueColor = Color(0xFF1565C0);
  static const Color redColor = Color(0xFFc62828);
  static const Color yellowColor = Color(0xFFFFC107);
  static const Color greenColor = Color(0xFF2E7D32);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color pathWhite = Color(0xFFF5F5F5);

  ZupeeLudoBoardPainter({
    required this.blueTokens,
    required this.redTokens,
    required this.yellowTokens,
    required this.greenTokens,
    required this.player1Score,
    required this.player2Score,
    required this.player3Score,
    required this.player4Score,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 15;

    // Draw the 4 colored quadrants
    _drawBlueQuadrant(canvas, 0, 0, cellSize * 6, cellSize);
    _drawRedQuadrant(canvas, cellSize * 9, 0, cellSize * 6, cellSize);
    _drawYellowQuadrant(canvas, 0, cellSize * 9, cellSize * 6, cellSize);
    _drawGreenQuadrant(canvas, cellSize * 9, cellSize * 9, cellSize * 6, cellSize);

    // Draw the cross paths
    _drawCrossPaths(canvas, size, cellSize);

    // Draw center home
    _drawCenterHome(canvas, size, cellSize);

    // Draw score circles
    _drawScoreCircles(canvas, cellSize);

    // Draw tokens on board
    _drawAllTokens(canvas, cellSize);

    // Draw safe spot stars
    _drawSafeSpots(canvas, cellSize);

    // Draw arrows on paths
    _drawPathArrows(canvas, cellSize);
  }

  // ==========================================
  // BLUE QUADRANT (Top-Left)
  // ==========================================
  void _drawBlueQuadrant(Canvas canvas, double x, double y, double size, double cellSize) {
    // Main blue background with gradient
    final rect = Rect.fromLTWH(x, y, size, size);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        blueColor.withOpacity(0.95),
        blueColor,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Diagonal darker stripe (Zupee style)
    final stripePath = Path()
      ..moveTo(x, y + size * 0.3)
      ..lineTo(x + size * 0.7, y + size)
      ..lineTo(x, y + size)
      ..close();
    canvas.drawPath(stripePath, Paint()..color = blueColor.withOpacity(0.7));

    // Inner white home area
    final innerPadding = size * 0.12;
    final innerSize = size * 0.76;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + innerPadding, y + innerPadding, innerSize, innerSize),
      const Radius.circular(8),
    );
    canvas.drawRRect(innerRect, Paint()..color = whiteColor);

    // Draw 4 token home spots
    _drawHomeTokenSpots(canvas, x + innerPadding, y + innerPadding, innerSize, blueColor);
  }

  // ==========================================
  // RED QUADRANT (Top-Right)
  // ==========================================
  void _drawRedQuadrant(Canvas canvas, double x, double y, double size, double cellSize) {
    final rect = Rect.fromLTWH(x, y, size, size);
    final gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        redColor.withOpacity(0.95),
        redColor,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Diagonal stripe
    final stripePath = Path()
      ..moveTo(x + size, y + size * 0.3)
      ..lineTo(x + size * 0.3, y + size)
      ..lineTo(x + size, y + size)
      ..close();
    canvas.drawPath(stripePath, Paint()..color = redColor.withOpacity(0.7));

    // Inner white home
    final innerPadding = size * 0.12;
    final innerSize = size * 0.76;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + innerPadding, y + innerPadding, innerSize, innerSize),
      const Radius.circular(8),
    );
    canvas.drawRRect(innerRect, Paint()..color = whiteColor);

    _drawHomeTokenSpots(canvas, x + innerPadding, y + innerPadding, innerSize, redColor);
  }

  // ==========================================
  // YELLOW QUADRANT (Bottom-Left)
  // ==========================================
  void _drawYellowQuadrant(Canvas canvas, double x, double y, double size, double cellSize) {
    final rect = Rect.fromLTWH(x, y, size, size);
    final gradient = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        yellowColor.withOpacity(0.95),
        yellowColor,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Diagonal stripe
    final stripePath = Path()
      ..moveTo(x, y + size * 0.7)
      ..lineTo(x + size * 0.7, y)
      ..lineTo(x, y)
      ..close();
    canvas.drawPath(stripePath, Paint()..color = yellowColor.withOpacity(0.7));

    // Inner white home
    final innerPadding = size * 0.12;
    final innerSize = size * 0.76;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + innerPadding, y + innerPadding, innerSize, innerSize),
      const Radius.circular(8),
    );
    canvas.drawRRect(innerRect, Paint()..color = whiteColor);

    _drawHomeTokenSpots(canvas, x + innerPadding, y + innerPadding, innerSize, yellowColor);
  }

  // ==========================================
  // GREEN QUADRANT (Bottom-Right)
  // ==========================================
  void _drawGreenQuadrant(Canvas canvas, double x, double y, double size, double cellSize) {
    final rect = Rect.fromLTWH(x, y, size, size);
    final gradient = LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [
        greenColor.withOpacity(0.95),
        greenColor,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Diagonal stripe
    final stripePath = Path()
      ..moveTo(x + size, y + size * 0.7)
      ..lineTo(x + size * 0.3, y)
      ..lineTo(x + size, y)
      ..close();
    canvas.drawPath(stripePath, Paint()..color = greenColor.withOpacity(0.7));

    // Inner white home
    final innerPadding = size * 0.12;
    final innerSize = size * 0.76;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + innerPadding, y + innerPadding, innerSize, innerSize),
      const Radius.circular(8),
    );
    canvas.drawRRect(innerRect, Paint()..color = whiteColor);

    _drawHomeTokenSpots(canvas, x + innerPadding, y + innerPadding, innerSize, greenColor);
  }

  // ==========================================
  // HOME TOKEN SPOTS (4 circles in each home)
  // ==========================================
  void _drawHomeTokenSpots(Canvas canvas, double x, double y, double size, Color color) {
    final spotRadius = size * 0.18;
    final positions = [
      Offset(x + size * 0.3, y + size * 0.3),
      Offset(x + size * 0.7, y + size * 0.3),
      Offset(x + size * 0.3, y + size * 0.7),
      Offset(x + size * 0.7, y + size * 0.7),
    ];

    for (final pos in positions) {
      // Outer ring
      canvas.drawCircle(
        pos,
        spotRadius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      // Inner fill (lighter)
      canvas.drawCircle(
        pos,
        spotRadius - 4,
        Paint()..color = color.withOpacity(0.2),
      );
    }
  }

  // ==========================================
  // CROSS PATHS (White paths between quadrants)
  // ==========================================
  void _drawCrossPaths(Canvas canvas, Size size, double cellSize) {
    final whitePaint = Paint()..color = pathWhite;
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Horizontal path (3 rows in middle)
    canvas.drawRect(
      Rect.fromLTWH(0, cellSize * 6, size.width, cellSize * 3),
      whitePaint,
    );

    // Vertical path (3 columns in middle)
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 6, 0, cellSize * 3, size.height),
      whitePaint,
    );

    // Draw grid lines for cells
    for (int i = 0; i <= 15; i++) {
      // Vertical lines in horizontal path
      if (i <= 6 || i >= 9) {
        canvas.drawLine(
          Offset(cellSize * i, cellSize * 6),
          Offset(cellSize * i, cellSize * 9),
          borderPaint,
        );
      }
      // Horizontal lines in vertical path
      if (i <= 6 || i >= 9) {
        canvas.drawLine(
          Offset(cellSize * 6, cellSize * i),
          Offset(cellSize * 9, cellSize * i),
          borderPaint,
        );
      }
    }

    // Horizontal lines in horizontal path
    for (int i = 6; i <= 9; i++) {
      canvas.drawLine(
        Offset(0, cellSize * i),
        Offset(cellSize * 6, cellSize * i),
        borderPaint,
      );
      canvas.drawLine(
        Offset(cellSize * 9, cellSize * i),
        Offset(size.width, cellSize * i),
        borderPaint,
      );
    }

    // Vertical lines in vertical path
    for (int i = 6; i <= 9; i++) {
      canvas.drawLine(
        Offset(cellSize * i, 0),
        Offset(cellSize * i, cellSize * 6),
        borderPaint,
      );
      canvas.drawLine(
        Offset(cellSize * i, cellSize * 9),
        Offset(cellSize * i, size.height),
        borderPaint,
      );
    }

    // Draw colored home columns
    _drawColoredHomePaths(canvas, cellSize);
  }

  // ==========================================
  // COLORED HOME PATHS (Final stretch to center)
  // ==========================================
  void _drawColoredHomePaths(Canvas canvas, double cellSize) {
    // Blue home column (left side, row 7, cols 1-5)
    for (int col = 1; col < 6; col++) {
      canvas.drawRect(
        Rect.fromLTWH(cellSize * col, cellSize * 7, cellSize, cellSize),
        Paint()..color = blueColor.withOpacity(0.5),
      );
    }

    // Red home column (top side, col 7, rows 1-5)
    for (int row = 1; row < 6; row++) {
      canvas.drawRect(
        Rect.fromLTWH(cellSize * 7, cellSize * row, cellSize, cellSize),
        Paint()..color = redColor.withOpacity(0.5),
      );
    }

    // Yellow home column (bottom side, col 7, rows 9-13)
    for (int row = 9; row < 14; row++) {
      canvas.drawRect(
        Rect.fromLTWH(cellSize * 7, cellSize * row, cellSize, cellSize),
        Paint()..color = yellowColor.withOpacity(0.5),
      );
    }

    // Green home column (right side, row 7, cols 9-13)
    for (int col = 9; col < 14; col++) {
      canvas.drawRect(
        Rect.fromLTWH(cellSize * col, cellSize * 7, cellSize, cellSize),
        Paint()..color = greenColor.withOpacity(0.5),
      );
    }

    // Starting cells (colored)
    // Blue start
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 6, cellSize * 1, cellSize, cellSize),
      Paint()..color = blueColor.withOpacity(0.4),
    );
    // Red start
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 13, cellSize * 6, cellSize, cellSize),
      Paint()..color = redColor.withOpacity(0.4),
    );
    // Yellow start
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 1, cellSize * 8, cellSize, cellSize),
      Paint()..color = yellowColor.withOpacity(0.4),
    );
    // Green start
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 8, cellSize * 13, cellSize, cellSize),
      Paint()..color = greenColor.withOpacity(0.4),
    );
  }

  // ==========================================
  // CENTER HOME (Triangles pointing to center)
  // ==========================================
  void _drawCenterHome(Canvas canvas, Size size, double cellSize) {
    final center = Offset(size.width / 2, size.height / 2);
    final triangleSize = cellSize * 1.5;

    final colors = [blueColor, redColor, greenColor, yellowColor];
    final angles = [math.pi, -math.pi / 2, 0, math.pi / 2];

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final angle = angles[i];

      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + math.cos(angle - math.pi / 4) * triangleSize,
        center.dy + math.sin(angle - math.pi / 4) * triangleSize,
      );
      path.lineTo(
        center.dx + math.cos(angle + math.pi / 4) * triangleSize,
        center.dy + math.sin(angle + math.pi / 4) * triangleSize,
      );
      path.close();

      canvas.drawPath(path, Paint()..color = colors[i]);

      // Border
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Center home icon
    canvas.drawCircle(center, cellSize * 0.4, Paint()..color = const Color(0xFF37474F));
    canvas.drawCircle(center, cellSize * 0.35, Paint()..color = Colors.white);
    
    // Home icon in center
    final homePath = Path();
    final homeSize = cellSize * 0.2;
    homePath.moveTo(center.dx, center.dy - homeSize);
    homePath.lineTo(center.dx - homeSize, center.dy);
    homePath.lineTo(center.dx - homeSize * 0.6, center.dy);
    homePath.lineTo(center.dx - homeSize * 0.6, center.dy + homeSize * 0.8);
    homePath.lineTo(center.dx + homeSize * 0.6, center.dy + homeSize * 0.8);
    homePath.lineTo(center.dx + homeSize * 0.6, center.dy);
    homePath.lineTo(center.dx + homeSize, center.dy);
    homePath.close();
    canvas.drawPath(homePath, Paint()..color = const Color(0xFF37474F));
  }

  // ==========================================
  // SCORE CIRCLES (In each quadrant)
  // ==========================================
  void _drawScoreCircles(Canvas canvas, double cellSize) {
    final scores = [player1Score, player2Score, player3Score, player4Score];
    final positions = [
      Offset(cellSize * 3, cellSize * 3),      // Blue (top-left)
      Offset(cellSize * 12, cellSize * 3),     // Red (top-right)
      Offset(cellSize * 3, cellSize * 12),     // Yellow (bottom-left)
      Offset(cellSize * 12, cellSize * 12),    // Green (bottom-right)
    ];

    for (int i = 0; i < 4; i++) {
      // White circle background
      canvas.drawCircle(
        positions[i],
        cellSize * 1.2,
        Paint()..color = whiteColor,
      );

      // Score text
      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Score\n',
              style: TextStyle(
                color: Color(0xFF757575),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '${scores[i]}',
              style: const TextStyle(
                color: Color(0xFF212121),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          positions[i].dx - textPainter.width / 2,
          positions[i].dy - textPainter.height / 2,
        ),
      );
    }
  }

  // ==========================================
  // SAFE SPOTS (Stars on board)
  // ==========================================
  void _drawSafeSpots(Canvas canvas, double cellSize) {
    final safePositions = [
      Offset(cellSize * 2.5, cellSize * 6.5),   // Left
      Offset(cellSize * 6.5, cellSize * 2.5),   // Top
      Offset(cellSize * 12.5, cellSize * 8.5),  // Right
      Offset(cellSize * 8.5, cellSize * 12.5),  // Bottom
    ];

    for (final pos in safePositions) {
      _drawStar(canvas, pos, cellSize * 0.3, Colors.grey.shade600);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
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
    canvas.drawPath(path, Paint()..color = color);
  }

  // ==========================================
  // PATH ARROWS (Direction indicators)
  // ==========================================
  void _drawPathArrows(Canvas canvas, double cellSize) {
    final arrowPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    // Left arrow (blue side)
    _drawArrow(canvas, Offset(cellSize * 0.5, cellSize * 7.5), 0, cellSize * 0.3, arrowPaint);
    
    // Right arrow (green side)
    _drawArrow(canvas, Offset(cellSize * 14.5, cellSize * 7.5), math.pi, cellSize * 0.3, arrowPaint);
    
    // Up arrow (red side)
    _drawArrow(canvas, Offset(cellSize * 7.5, cellSize * 0.5), math.pi / 2, cellSize * 0.3, arrowPaint);
    
    // Down arrow (yellow side)
    _drawArrow(canvas, Offset(cellSize * 7.5, cellSize * 14.5), -math.pi / 2, cellSize * 0.3, arrowPaint);
  }

  void _drawArrow(Canvas canvas, Offset position, double angle, double size, Paint paint) {
    final path = Path();
    path.moveTo(position.dx + math.cos(angle) * size, position.dy + math.sin(angle) * size);
    path.lineTo(
      position.dx + math.cos(angle + 2.5) * size * 0.7,
      position.dy + math.sin(angle + 2.5) * size * 0.7,
    );
    path.lineTo(
      position.dx + math.cos(angle - 2.5) * size * 0.7,
      position.dy + math.sin(angle - 2.5) * size * 0.7,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  // ==========================================
  // DRAW ALL TOKENS
  // ==========================================
  void _drawAllTokens(Canvas canvas, double cellSize) {
    // Draw tokens for each player
    _drawPlayerTokens(canvas, blueTokens, blueColor, cellSize, 0);
    _drawPlayerTokens(canvas, redTokens, redColor, cellSize, 1);
    _drawPlayerTokens(canvas, yellowTokens, yellowColor, cellSize, 2);
    _drawPlayerTokens(canvas, greenTokens, greenColor, cellSize, 3);
  }

  void _drawPlayerTokens(Canvas canvas, List<int> tokens, Color color, double cellSize, int playerIndex) {
    for (int i = 0; i < tokens.length; i++) {
      final position = tokens[i];
      if (position >= 0) {
        final pos = _getTokenBoardPosition(position, playerIndex, cellSize);
        _drawToken(canvas, pos, color, cellSize);
      }
    }
  }

  Offset _getTokenBoardPosition(int position, int playerIndex, double cellSize) {
    // Simplified position mapping - you can expand this
    // This maps position 0-51 to actual board coordinates
    final pathPositions = _generatePathPositions(cellSize);
    if (position < pathPositions.length) {
      return pathPositions[(position + playerIndex * 13) % pathPositions.length];
    }
    return Offset(cellSize * 7.5, cellSize * 7.5);
  }

  List<Offset> _generatePathPositions(double cellSize) {
    final positions = <Offset>[];
    
    // Generate 52 positions around the board
    // Bottom row (left to right)
    for (int i = 0; i < 5; i++) {
      positions.add(Offset(cellSize * (1 + i) + cellSize / 2, cellSize * 6 + cellSize / 2));
    }
    // Left column (bottom to top)
    for (int i = 0; i < 6; i++) {
      positions.add(Offset(cellSize * 6 + cellSize / 2, cellSize * (5 - i) + cellSize / 2));
    }
    // Top row going right
    for (int i = 0; i < 2; i++) {
      positions.add(Offset(cellSize * (7 + i) + cellSize / 2, cellSize / 2));
    }
    // Continue around...
    for (int i = 0; i < 6; i++) {
      positions.add(Offset(cellSize * 8 + cellSize / 2, cellSize * (1 + i) + cellSize / 2));
    }
    // Right side
    for (int i = 0; i < 5; i++) {
      positions.add(Offset(cellSize * (9 + i) + cellSize / 2, cellSize * 6 + cellSize / 2));
    }
    // More positions...
    for (int i = 0; i < 2; i++) {
      positions.add(Offset(cellSize * 14 + cellSize / 2, cellSize * (7 + i) + cellSize / 2));
    }
    for (int i = 0; i < 6; i++) {
      positions.add(Offset(cellSize * (13 - i) + cellSize / 2, cellSize * 8 + cellSize / 2));
    }
    for (int i = 0; i < 5; i++) {
      positions.add(Offset(cellSize * 8 + cellSize / 2, cellSize * (9 + i) + cellSize / 2));
    }
    for (int i = 0; i < 2; i++) {
      positions.add(Offset(cellSize * (7 - i) + cellSize / 2, cellSize * 14 + cellSize / 2));
    }
    for (int i = 0; i < 6; i++) {
      positions.add(Offset(cellSize * 6 + cellSize / 2, cellSize * (13 - i) + cellSize / 2));
    }
    for (int i = 0; i < 5; i++) {
      positions.add(Offset(cellSize * (5 - i) + cellSize / 2, cellSize * 8 + cellSize / 2));
    }
    
    return positions;
  }

  void _drawToken(Canvas canvas, Offset position, Color color, double cellSize) {
    final radius = cellSize * 0.35;

    // Shadow
    canvas.drawCircle(
      Offset(position.dx + 2, position.dy + 2),
      radius,
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    // Token body with gradient
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.8),
        color,
        color.withOpacity(0.9),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    canvas.drawCircle(
      position,
      radius,
      Paint()..shader = gradient.createShader(Rect.fromCircle(center: position, radius: radius)),
    );

    // Highlight
    canvas.drawCircle(
      Offset(position.dx - radius * 0.3, position.dy - radius * 0.3),
      radius * 0.25,
      Paint()..color = Colors.white.withOpacity(0.6),
    );

    // Border
    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant ZupeeLudoBoardPainter oldDelegate) {
    return oldDelegate.blueTokens != blueTokens ||
        oldDelegate.redTokens != redTokens ||
        oldDelegate.yellowTokens != yellowTokens ||
        oldDelegate.greenTokens != greenTokens;
  }
}
