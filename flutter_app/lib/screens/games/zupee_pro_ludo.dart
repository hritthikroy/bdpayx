import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

// ============================================
// ZUPEE PRO LUDO - 4 PLAYER EXACT MATCH
// Blue(top-left), Red(top-right), Yellow(bottom-left), Green(bottom-right)
// ============================================

class ZupeeProLudo extends StatefulWidget {
  final String prizePot;

  const ZupeeProLudo({
    super.key,
    this.prizePot = '0.6',
  });

  @override
  State<ZupeeProLudo> createState() => _ZupeeProLudoState();
}

class _ZupeeProLudoState extends State<ZupeeProLudo>
    with TickerProviderStateMixin {
  
  // Players
  final List<PlayerData> players = [
    PlayerData(name: 'Nasim', color: const Color(0xFF1565C0), position: 'top-left', score: 2, moverLabel: 'Second Mover'),
    PlayerData(name: 'Rohit', color: const Color(0xFFc62828), position: 'top-right', score: 0, moverLabel: 'Third Mover'),
    PlayerData(name: 'Malavida', color: const Color(0xFFF9A825), position: 'bottom-left', score: 1, moverLabel: 'First Mover'),
    PlayerData(name: 'Ashish', color: const Color(0xFF2E7D32), position: 'bottom-right', score: 0, moverLabel: 'Fourth Mover'),
  ];

  int _timeLeft = 591; // 09:51
  Timer? _timer;
  int _currentPlayerIndex = 0; // Rohit's turn (green glow)
  int _diceValue = 1;
  bool _isRolling = false;

  late AnimationController _glowController;
  late AnimationController _diceController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
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

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
              Color(0xFF1a237e),
              Color(0xFF0d1442),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              _buildTopPlayersRow(),
              Expanded(child: _buildBoard()),
              _buildBottomPlayersRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP BAR - Back, Prize Pool, Settings
  // ==========================================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Back button (blue circle with arrow)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const Spacer(),
          // Prize Pool (gold badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFF5D4037), size: 18),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Prize Pool',
                      style: TextStyle(color: Color(0xFF5D4037), fontSize: 8, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '₹${widget.prizePot}',
                      style: const TextStyle(color: Color(0xFF3E2723), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Settings (green circle)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP PLAYERS ROW - Nasim (left) & Rohit (right)
  // ==========================================
  Widget _buildTopPlayersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Nasim (Blue - top left)
          _buildTopPlayer(players[0], false),
          const Spacer(),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.access_time, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 6),
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
          ),
          const Spacer(),
          // Rohit (Red - top right) - Active player with green glow
          _buildTopPlayer(players[1], true),
        ],
      ),
    );
  }

  Widget _buildTopPlayer(PlayerData player, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (player.position == 'top-right') ...[
          _buildCrownButton(player.color),
          const SizedBox(width: 6),
        ],
        
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player.name,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 2),
            // Info icon
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 1),
              ),
              child: const Center(
                child: Text('i', style: TextStyle(color: Colors.white54, fontSize: 10)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        
        // Avatar with ring
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive 
                      ? Color.lerp(const Color(0xFF4CAF50), const Color(0xFF81C784), _glowController.value)!
                      : const Color(0xFFFFD700),
                  width: 3,
                ),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.6 * _glowController.value),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ] : null,
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: player.color.withOpacity(0.3),
                child: const Icon(Icons.person, color: Colors.white70, size: 24),
              ),
            );
          },
        ),
        
        if (player.position == 'top-left') ...[
          const SizedBox(width: 6),
          _buildCrownButton(player.color),
        ],
      ],
    );
  }

  Widget _buildCrownButton(Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(Icons.workspace_premium, color: color, size: 24),
    );
  }

  // ==========================================
  // LUDO BOARD
  // ==========================================
  Widget _buildBoard() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              painter: ZupeeProBoardPainter(
                players: players,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM PLAYERS ROW - Malavida (left) & Ashish (right)
  // ==========================================
  Widget _buildBottomPlayersRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildBottomPlayer(players[2]),
          const Spacer(),
          // Dice buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDiceButton(players[2].color),
              const SizedBox(width: 8),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 1),
                ),
                child: const Center(
                  child: Text('i', style: TextStyle(color: Colors.white38, fontSize: 10)),
                ),
              ),
              const SizedBox(width: 8),
              _buildDiceButton(players[3].color),
            ],
          ),
          const Spacer(),
          _buildBottomPlayer(players[3]),
        ],
      ),
    );
  }

  Widget _buildBottomPlayer(PlayerData player) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with frame
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1565C0), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 44,
              height: 44,
              color: player.color.withOpacity(0.3),
              child: const Icon(Icons.person, color: Colors.white70, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          player.name,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDiceButton(Color color) {
    return GestureDetector(
      onTap: _rollDice,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(Icons.workspace_premium, color: color, size: 28),
      ),
    );
  }
}

// ==========================================
// PLAYER DATA MODEL
// ==========================================
class PlayerData {
  final String name;
  final Color color;
  final String position;
  final int score;
  final String moverLabel;

  PlayerData({
    required this.name,
    required this.color,
    required this.position,
    required this.score,
    required this.moverLabel,
  });
}


// ============================================
// ZUPEE PRO BOARD PAINTER
// Blue(top-left), Red(top-right), Yellow(bottom-left), Green(bottom-right)
// ============================================
class ZupeeProBoardPainter extends CustomPainter {
  final List<PlayerData> players;

  // Exact Zupee colors
  static const Color blueColor = Color(0xFF1565C0);
  static const Color redColor = Color(0xFFc62828);
  static const Color yellowColor = Color(0xFFF9A825);
  static const Color greenColor = Color(0xFF2E7D32);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color pathWhite = Color(0xFFFAFAFA);

  ZupeeProBoardPainter({required this.players});

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;

    // Draw white background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = pathWhite,
    );

    // Draw 4 colored quadrants
    // BLUE - Top Left
    _drawQuadrantWithScore(canvas, 0, 0, cell * 6, blueColor, players[0], cell);
    // RED - Top Right  
    _drawQuadrantWithScore(canvas, cell * 9, 0, cell * 6, redColor, players[1], cell);
    // YELLOW - Bottom Left
    _drawQuadrantWithScore(canvas, 0, cell * 9, cell * 6, yellowColor, players[2], cell);
    // GREEN - Bottom Right
    _drawQuadrantWithScore(canvas, cell * 9, cell * 9, cell * 6, greenColor, players[3], cell);

    // Draw cross paths
    _drawCrossPaths(canvas, size, cell);

    // Draw colored home columns
    _drawHomeColumns(canvas, cell);

    // Draw center home
    _drawCenterHome(canvas, size, cell);

    // Draw safe stars
    _drawSafeStars(canvas, cell);

    // Draw tokens on board
    _drawBoardTokens(canvas, cell);
  }

  void _drawQuadrantWithScore(Canvas canvas, double x, double y, double qSize, Color color, PlayerData player, double cell) {
    // Main colored background
    canvas.drawRect(
      Rect.fromLTWH(x, y, qSize, qSize),
      Paint()..color = color,
    );

    // Score circle (white) - positioned in the quadrant
    final scoreCenter = Offset(x + qSize / 2, y + qSize * 0.35);
    final scoreRadius = qSize * 0.22;
    
    // White circle with border
    canvas.drawCircle(scoreCenter, scoreRadius, Paint()..color = whiteColor);
    canvas.drawCircle(
      scoreCenter,
      scoreRadius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Score text
    final scorePainter = TextPainter(
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
            text: '${player.score}',
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
    scorePainter.layout();
    scorePainter.paint(
      canvas,
      Offset(scoreCenter.dx - scorePainter.width / 2, scoreCenter.dy - scorePainter.height / 2),
    );

    // Mover label at bottom of quadrant
    final labelPainter = TextPainter(
      text: TextSpan(
        text: player.moverLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    labelPainter.layout();
    
    // Label background
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x + qSize / 2, y + qSize - cell * 0.6),
        width: labelPainter.width + 16,
        height: 20,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(labelRect, Paint()..color = color.withOpacity(0.8));
    labelPainter.paint(
      canvas,
      Offset(x + qSize / 2 - labelPainter.width / 2, y + qSize - cell * 0.6 - labelPainter.height / 2),
    );

    // Draw tokens in home area (below score circle)
    _drawHomeTokens(canvas, x, y + qSize * 0.5, qSize, color, cell);
  }

  void _drawHomeTokens(Canvas canvas, double x, double y, double qSize, Color color, double cell) {
    final tokenRadius = qSize * 0.1;
    final spacing = qSize * 0.18;
    final centerX = x + qSize / 2;
    final centerY = y + qSize * 0.2;

    // 4 tokens in 2x2 grid (or 3 in a row for some)
    final positions = [
      Offset(centerX - spacing, centerY - spacing * 0.3),
      Offset(centerX + spacing, centerY - spacing * 0.3),
      Offset(centerX - spacing, centerY + spacing * 0.7),
      Offset(centerX + spacing, centerY + spacing * 0.7),
    ];

    for (final pos in positions) {
      _draw3DToken(canvas, pos, color, tokenRadius);
    }
  }

  void _draw3DToken(Canvas canvas, Offset pos, Color color, double radius) {
    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + radius * 0.4), width: radius * 1.8, height: radius * 0.6),
      Paint()..color = Colors.black.withOpacity(0.2),
    );

    // Token base (darker)
    canvas.drawCircle(
      Offset(pos.dx, pos.dy + 2),
      radius,
      Paint()..color = Color.lerp(color, Colors.black, 0.3)!,
    );

    // Token body with gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      colors: [
        Color.lerp(color, Colors.white, 0.4)!,
        color,
        Color.lerp(color, Colors.black, 0.15)!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(
      pos,
      radius,
      Paint()..shader = gradient.createShader(Rect.fromCircle(center: pos, radius: radius)),
    );

    // Highlight
    canvas.drawCircle(
      Offset(pos.dx - radius * 0.3, pos.dy - radius * 0.3),
      radius * 0.3,
      Paint()..color = Colors.white.withOpacity(0.6),
    );
  }

  void _drawCrossPaths(Canvas canvas, Size size, double cell) {
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw grid in cross paths
    for (int row = 6; row < 9; row++) {
      for (int col = 0; col < 15; col++) {
        if (col >= 6 && col < 9) continue;
        canvas.drawRect(
          Rect.fromLTWH(cell * col, cell * row, cell, cell),
          borderPaint,
        );
      }
    }

    for (int col = 6; col < 9; col++) {
      for (int row = 0; row < 15; row++) {
        if (row >= 6 && row < 9) continue;
        canvas.drawRect(
          Rect.fromLTWH(cell * col, cell * row, cell, cell),
          borderPaint,
        );
      }
    }
  }

  void _drawHomeColumns(Canvas canvas, double cell) {
    // BLUE home column - Left (row 7, cols 1-5)
    for (int col = 1; col < 6; col++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * col, cell * 7, cell, cell),
        Paint()..color = blueColor.withOpacity(0.5),
      );
    }

    // RED home column - Top (col 7, rows 1-5)
    for (int row = 1; row < 6; row++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * 7, cell * row, cell, cell),
        Paint()..color = redColor.withOpacity(0.5),
      );
    }

    // YELLOW home column - Bottom (col 7, rows 9-13)
    for (int row = 9; row < 14; row++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * 7, cell * row, cell, cell),
        Paint()..color = yellowColor.withOpacity(0.5),
      );
    }

    // GREEN home column - Right (row 7, cols 9-13)
    for (int col = 9; col < 14; col++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * col, cell * 7, cell, cell),
        Paint()..color = greenColor.withOpacity(0.5),
      );
    }

    // Starting positions (arrows)
    _drawArrow(canvas, Offset(cell * 0.5, cell * 7.5), 0, cell * 0.3, blueColor);
    _drawArrow(canvas, Offset(cell * 7.5, cell * 0.5), math.pi / 2, cell * 0.3, redColor);
    _drawArrow(canvas, Offset(cell * 7.5, cell * 14.5), -math.pi / 2, cell * 0.3, yellowColor);
    _drawArrow(canvas, Offset(cell * 14.5, cell * 7.5), math.pi, cell * 0.3, greenColor);
  }

  void _drawArrow(Canvas canvas, Offset pos, double angle, double size, Color color) {
    final path = Path()
      ..moveTo(pos.dx + math.cos(angle) * size, pos.dy + math.sin(angle) * size)
      ..lineTo(pos.dx + math.cos(angle + 2.5) * size * 0.7, pos.dy + math.sin(angle + 2.5) * size * 0.7)
      ..lineTo(pos.dx + math.cos(angle - 2.5) * size * 0.7, pos.dy + math.sin(angle - 2.5) * size * 0.7)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawCenterHome(Canvas canvas, Size size, double cell) {
    final center = Offset(size.width / 2, size.height / 2);
    final triSize = cell * 1.5;

    final colors = [blueColor, redColor, greenColor, yellowColor];
    final angles = [math.pi, -math.pi / 2, 0, math.pi / 2];

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
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Center circle with home icon
    canvas.drawCircle(center, cell * 0.4, Paint()..color = const Color(0xFF455A64));
    canvas.drawCircle(center, cell * 0.32, Paint()..color = whiteColor);
    
    // Home icon
    final homeIcon = Path()
      ..moveTo(center.dx, center.dy - cell * 0.18)
      ..lineTo(center.dx - cell * 0.15, center.dy)
      ..lineTo(center.dx - cell * 0.1, center.dy)
      ..lineTo(center.dx - cell * 0.1, center.dy + cell * 0.12)
      ..lineTo(center.dx + cell * 0.1, center.dy + cell * 0.12)
      ..lineTo(center.dx + cell * 0.1, center.dy)
      ..lineTo(center.dx + cell * 0.15, center.dy)
      ..close();
    canvas.drawPath(homeIcon, Paint()..color = const Color(0xFF455A64));
  }

  void _drawSafeStars(Canvas canvas, double cell) {
    final positions = [
      Offset(cell * 2.5, cell * 6.5),
      Offset(cell * 6.5, cell * 2.5),
      Offset(cell * 8.5, cell * 6.5),
      Offset(cell * 6.5, cell * 8.5),
      Offset(cell * 12.5, cell * 8.5),
      Offset(cell * 8.5, cell * 12.5),
      Offset(cell * 2.5, cell * 8.5),
      Offset(cell * 8.5, cell * 2.5),
    ];

    for (final pos in positions) {
      _drawStar(canvas, pos, cell * 0.22);
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

  void _drawBoardTokens(Canvas canvas, double cell) {
    // Blue tokens on board
    _draw3DToken(canvas, Offset(cell * 4.5, cell * 6.5), blueColor, cell * 0.35);
    _draw3DToken(canvas, Offset(cell * 5.5, cell * 6.5), blueColor, cell * 0.35);
    
    // Red tokens on board
    _draw3DToken(canvas, Offset(cell * 8.5, cell * 4.5), redColor, cell * 0.35);
    _draw3DToken(canvas, Offset(cell * 7.5, cell * 5.5), redColor, cell * 0.35);
    
    // Yellow tokens on board
    _draw3DToken(canvas, Offset(cell * 6.5, cell * 10.5), yellowColor, cell * 0.35);
    _draw3DToken(canvas, Offset(cell * 7.5, cell * 9.5), yellowColor, cell * 0.35);
    _draw3DToken(canvas, Offset(cell * 7.5, cell * 10.5), yellowColor, cell * 0.35);
    
    // Green tokens on board
    _draw3DToken(canvas, Offset(cell * 10.5, cell * 8.5), greenColor, cell * 0.35);
    _draw3DToken(canvas, Offset(cell * 11.5, cell * 8.5), greenColor, cell * 0.35);
    _draw3DToken(canvas, Offset(cell * 12.5, cell * 8.5), greenColor, cell * 0.35);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
