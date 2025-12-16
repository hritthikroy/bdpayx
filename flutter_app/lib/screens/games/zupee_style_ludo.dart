import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

// ============================================
// ZUPEE STYLE LUDO - EXACT REPLICA
// With 3D Tokens, Glossy Board, Professional UI
// ============================================

class ZupeeStyleLudo extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  final String player3Name;
  final String player4Name;
  final String prizePot;

  const ZupeeStyleLudo({
    super.key,
    this.player1Name = 'Priya',
    this.player2Name = 'Deepak',
    this.player3Name = 'Kanik',
    this.player4Name = 'Ranjit',
    this.prizePot = '4500',
  });

  @override
  State<ZupeeStyleLudo> createState() => _ZupeeStyleLudoState();
}

class _ZupeeStyleLudoState extends State<ZupeeStyleLudo>
    with TickerProviderStateMixin {
  
  // Game Timer
  int _timeLeft = 477; // 7:57
  Timer? _gameTimer;
  
  // Player Scores
  final Map<String, int> _scores = {
    'blue': 60,
    'red': 125,
    'yellow': 30,
    'green': 45,
  };
  
  // Token positions: -1 = home, 0-56 = board path, 57 = finished
  final Map<String, List<int>> _tokens = {
    'blue': [-1, -1, 8, 15],
    'red': [-1, 12, 22, -1],
    'yellow': [-1, -1, 35, 42],
    'green': [-1, 28, -1, 48],
  };
  
  // Current player turn
  String _currentPlayer = 'blue';
  int _diceValue = 1;
  bool _isRolling = false;
  
  late AnimationController _diceController;
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _startGameTimer();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _diceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timeLeft > 0) {
        setState(() => _timeLeft--);
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _rollDice() {
    if (_isRolling) return;
    setState(() => _isRolling = true);
    _diceController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 500), () {
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
              _buildPlayersRow(),
              Expanded(child: _buildBoard()),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP BAR - Back, Prize Pot, Settings
  // ==========================================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Back Button
          _buildCircleButton(
            icon: Icons.arrow_back_ios_new,
            color: const Color(0xFF2196F3),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          // Prize Pot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFF5D4037), size: 22),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Prize Pot',
                      style: TextStyle(
                        color: Color(0xFF5D4037),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.prizePot,
                      style: const TextStyle(
                        color: Color(0xFF3E2723),
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
          // Settings
          _buildCircleButton(
            icon: Icons.settings,
            color: const Color(0xFF4CAF50),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ==========================================
  // PLAYERS ROW - Top 2 players with timer
  // ==========================================
  Widget _buildPlayersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _buildPlayerAvatar(widget.player1Name, const Color(0xFF1565C0), true),
          const Spacer(),
          _buildTimer(),
          const Spacer(),
          _buildPlayerAvatar(widget.player2Name, const Color(0xFFc62828), false),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar(String name, Color color, bool isLeft) {
    final isActive = (isLeft && _currentPlayer == 'blue') || 
                     (!isLeft && _currentPlayer == 'red');
    
    return Row(
      children: [
        if (!isLeft) _buildCrownIcon(color),
        if (!isLeft) const SizedBox(width: 8),
        
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive 
                      ? Color.lerp(const Color(0xFFFFD700), const Color(0xFFFFA000), _glowController.value)!
                      : color.withOpacity(0.5),
                  width: isActive ? 3 : 2,
                ),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5 * _glowController.value),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ] : null,
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        
        if (isLeft) const SizedBox(width: 8),
        if (isLeft) _buildCrownIcon(color),
      ],
    );
  }

  Widget _buildCrownIcon(Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(Icons.workspace_premium, color: color, size: 24),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, color: Colors.white60, size: 16),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Time Left',
                style: TextStyle(color: Colors.white54, fontSize: 9),
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomPaint(
              painter: ZupeeExactBoardPainter(
                tokens: _tokens,
                scores: _scores,
                currentPlayer: _currentPlayer,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM BAR - Players & Dice
  // ==========================================
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomPlayer(widget.player3Name, const Color(0xFFFFC107)),
          _buildDiceArea(),
          _buildBottomPlayer(widget.player4Name, const Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  Widget _buildBottomPlayer(String name, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDiceArea() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDiceButton(const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        _buildHomeButton(),
        const SizedBox(width: 12),
        _buildDiceButton(const Color(0xFFFFC107)),
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: _isRolling
                    ? Icon(Icons.casino, color: color, size: 28)
                    : _buildDiceFace(_diceValue, color),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiceFace(int value, Color color) {
    return CustomPaint(
      size: const Size(32, 32),
      painter: DiceFacePainter(value: value, color: color),
    );
  }

  Widget _buildHomeButton() {
    return Container(
      width: 52,
      height: 52,
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
// EXACT ZUPEE BOARD PAINTER
// ============================================
class ZupeeExactBoardPainter extends CustomPainter {
  final Map<String, List<int>> tokens;
  final Map<String, int> scores;
  final String currentPlayer;

  // Exact Zupee Colors
  static const Color blueColor = Color(0xFF1565C0);
  static const Color redColor = Color(0xFFc62828);
  static const Color yellowColor = Color(0xFFF9A825);
  static const Color greenColor = Color(0xFF2E7D32);
  static const Color whiteColor = Color(0xFFFFFFFF);

  ZupeeExactBoardPainter({
    required this.tokens,
    required this.scores,
    required this.currentPlayer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;

    // Draw 4 quadrants
    _drawQuadrant(canvas, 0, 0, cell * 6, blueColor, 'blue', cell);
    _drawQuadrant(canvas, cell * 9, 0, cell * 6, redColor, 'red', cell);
    _drawQuadrant(canvas, 0, cell * 9, cell * 6, yellowColor, 'yellow', cell);
    _drawQuadrant(canvas, cell * 9, cell * 9, cell * 6, greenColor, 'green', cell);

    // Draw cross paths
    _drawPaths(canvas, size, cell);

    // Draw center
    _drawCenter(canvas, size, cell);

    // Draw score circles
    _drawScores(canvas, cell);

    // Draw all tokens
    _drawTokens(canvas, cell);
  }

  void _drawQuadrant(Canvas canvas, double x, double y, double size, Color color, String player, double cell) {
    // Main colored area with diagonal stripe effect
    final rect = Rect.fromLTWH(x, y, size, size);
    canvas.drawRect(rect, Paint()..color = color);

    // Diagonal darker stripe (Zupee signature style)
    final stripePath = Path();
    if (player == 'blue') {
      stripePath.moveTo(x, y + size * 0.35);
      stripePath.lineTo(x + size * 0.65, y + size);
      stripePath.lineTo(x, y + size);
      stripePath.close();
    } else if (player == 'red') {
      stripePath.moveTo(x + size, y + size * 0.35);
      stripePath.lineTo(x + size * 0.35, y + size);
      stripePath.lineTo(x + size, y + size);
      stripePath.close();
    } else if (player == 'yellow') {
      stripePath.moveTo(x, y + size * 0.65);
      stripePath.lineTo(x + size * 0.65, y);
      stripePath.lineTo(x, y);
      stripePath.close();
    } else {
      stripePath.moveTo(x + size, y + size * 0.65);
      stripePath.lineTo(x + size * 0.35, y);
      stripePath.lineTo(x + size, y);
      stripePath.close();
    }
    canvas.drawPath(stripePath, Paint()..color = color.withOpacity(0.6));

    // Inner white home area
    final padding = size * 0.12;
    final innerSize = size * 0.76;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + padding, y + padding, innerSize, innerSize),
      const Radius.circular(10),
    );
    canvas.drawRRect(innerRect, Paint()..color = whiteColor);

    // 4 token spots in home
    final spotRadius = size * 0.14;
    final spots = [
      Offset(x + padding + innerSize * 0.28, y + padding + innerSize * 0.28),
      Offset(x + padding + innerSize * 0.72, y + padding + innerSize * 0.28),
      Offset(x + padding + innerSize * 0.28, y + padding + innerSize * 0.72),
      Offset(x + padding + innerSize * 0.72, y + padding + innerSize * 0.72),
    ];

    for (final spot in spots) {
      // Ring
      canvas.drawCircle(
        spot,
        spotRadius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      // Inner light fill
      canvas.drawCircle(
        spot,
        spotRadius - 4,
        Paint()..color = color.withOpacity(0.15),
      );
    }
  }

  void _drawPaths(Canvas canvas, Size size, double cell) {
    final white = Paint()..color = whiteColor;
    final border = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Horizontal path
    canvas.drawRect(Rect.fromLTWH(0, cell * 6, size.width, cell * 3), white);
    // Vertical path
    canvas.drawRect(Rect.fromLTWH(cell * 6, 0, cell * 3, size.height), white);

    // Grid lines
    for (int i = 0; i <= 15; i++) {
      // Vertical in horizontal path
      canvas.drawLine(Offset(cell * i, cell * 6), Offset(cell * i, cell * 9), border);
      // Horizontal in vertical path
      canvas.drawLine(Offset(cell * 6, cell * i), Offset(cell * 9, cell * i), border);
    }

    // Colored home columns
    // Blue (left)
    for (int c = 1; c < 6; c++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * c, cell * 7, cell, cell),
        Paint()..color = blueColor.withOpacity(0.45),
      );
    }
    // Red (top)
    for (int r = 1; r < 6; r++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * 7, cell * r, cell, cell),
        Paint()..color = redColor.withOpacity(0.45),
      );
    }
    // Yellow (bottom)
    for (int r = 9; r < 14; r++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * 7, cell * r, cell, cell),
        Paint()..color = yellowColor.withOpacity(0.45),
      );
    }
    // Green (right)
    for (int c = 9; c < 14; c++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * c, cell * 7, cell, cell),
        Paint()..color = greenColor.withOpacity(0.45),
      );
    }

    // Starting positions (colored cells)
    canvas.drawRect(Rect.fromLTWH(cell * 6, cell * 1, cell, cell), Paint()..color = blueColor.withOpacity(0.35));
    canvas.drawRect(Rect.fromLTWH(cell * 13, cell * 6, cell, cell), Paint()..color = redColor.withOpacity(0.35));
    canvas.drawRect(Rect.fromLTWH(cell * 1, cell * 8, cell, cell), Paint()..color = yellowColor.withOpacity(0.35));
    canvas.drawRect(Rect.fromLTWH(cell * 8, cell * 13, cell, cell), Paint()..color = greenColor.withOpacity(0.35));

    // Safe spots (stars)
    _drawStar(canvas, Offset(cell * 2.5, cell * 6.5), cell * 0.28, Colors.grey.shade700);
    _drawStar(canvas, Offset(cell * 6.5, cell * 2.5), cell * 0.28, Colors.grey.shade700);
    _drawStar(canvas, Offset(cell * 12.5, cell * 8.5), cell * 0.28, Colors.grey.shade700);
    _drawStar(canvas, Offset(cell * 8.5, cell * 12.5), cell * 0.28, Colors.grey.shade700);

    // Direction arrows
    _drawArrow(canvas, Offset(cell * 0.5, cell * 7.5), 0, cell * 0.25);
    _drawArrow(canvas, Offset(cell * 14.5, cell * 7.5), math.pi, cell * 0.25);
    _drawArrow(canvas, Offset(cell * 7.5, cell * 0.5), math.pi / 2, cell * 0.25);
    _drawArrow(canvas, Offset(cell * 7.5, cell * 14.5), -math.pi / 2, cell * 0.25);
  }

  void _drawCenter(Canvas canvas, Size size, double cell) {
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

    // Center home icon
    canvas.drawCircle(center, cell * 0.45, Paint()..color = const Color(0xFF455A64));
    canvas.drawCircle(center, cell * 0.38, Paint()..color = whiteColor);

    // Home icon
    final homeIcon = Path()
      ..moveTo(center.dx, center.dy - cell * 0.2)
      ..lineTo(center.dx - cell * 0.18, center.dy - cell * 0.02)
      ..lineTo(center.dx - cell * 0.12, center.dy - cell * 0.02)
      ..lineTo(center.dx - cell * 0.12, center.dy + cell * 0.15)
      ..lineTo(center.dx + cell * 0.12, center.dy + cell * 0.15)
      ..lineTo(center.dx + cell * 0.12, center.dy - cell * 0.02)
      ..lineTo(center.dx + cell * 0.18, center.dy - cell * 0.02)
      ..close();
    canvas.drawPath(homeIcon, Paint()..color = const Color(0xFF455A64));
  }

  void _drawScores(Canvas canvas, double cell) {
    final positions = [
      Offset(cell * 3, cell * 3),
      Offset(cell * 12, cell * 3),
      Offset(cell * 3, cell * 12),
      Offset(cell * 12, cell * 12),
    ];
    final scoreValues = [scores['blue']!, scores['red']!, scores['yellow']!, scores['green']!];

    for (int i = 0; i < 4; i++) {
      // White circle
      canvas.drawCircle(positions[i], cell * 1.15, Paint()..color = whiteColor);

      // Score text
      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Score\n',
              style: TextStyle(
                color: Color(0xFF757575),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '${scoreValues[i]}',
              style: const TextStyle(
                color: Color(0xFF212121),
                fontSize: 20,
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
        Offset(positions[i].dx - textPainter.width / 2, positions[i].dy - textPainter.height / 2),
      );
    }
  }

  void _drawTokens(Canvas canvas, double cell) {
    final colors = {'blue': blueColor, 'red': redColor, 'yellow': yellowColor, 'green': greenColor};
    final playerOffsets = {'blue': 0, 'red': 13, 'yellow': 26, 'green': 39};

    tokens.forEach((player, tokenList) {
      for (int i = 0; i < tokenList.length; i++) {
        final pos = tokenList[i];
        if (pos >= 0) {
          final boardPos = _getBoardPosition(pos, playerOffsets[player]!, cell);
          _draw3DToken(canvas, boardPos, colors[player]!, cell);
        }
      }
    });
  }

  Offset _getBoardPosition(int position, int offset, double cell) {
    final path = _generatePath(cell);
    final idx = (position + offset) % path.length;
    return path[idx];
  }

  List<Offset> _generatePath(double cell) {
    final path = <Offset>[];
    
    // Generate 52 positions clockwise starting from yellow start
    // Bottom-left going up
    for (int i = 0; i < 5; i++) path.add(Offset(cell * 1.5, cell * (13.5 - i)));
    path.add(Offset(cell * 1.5, cell * 8.5));
    
    // Going right on row 8
    for (int i = 0; i < 5; i++) path.add(Offset(cell * (2.5 + i), cell * 8.5));
    
    // Going up on col 6
    for (int i = 0; i < 6; i++) path.add(Offset(cell * 6.5, cell * (7.5 - i)));
    
    // Top row going right
    path.add(Offset(cell * 7.5, cell * 1.5));
    path.add(Offset(cell * 8.5, cell * 1.5));
    
    // Going down on col 8
    for (int i = 0; i < 6; i++) path.add(Offset(cell * 8.5, cell * (2.5 + i)));
    
    // Going right on row 6
    for (int i = 0; i < 5; i++) path.add(Offset(cell * (9.5 + i), cell * 6.5));
    
    // Right column going down
    path.add(Offset(cell * 13.5, cell * 7.5));
    path.add(Offset(cell * 13.5, cell * 8.5));
    
    // Going left on row 8
    for (int i = 0; i < 6; i++) path.add(Offset(cell * (12.5 - i), cell * 8.5));
    
    // Going down on col 8
    for (int i = 0; i < 5; i++) path.add(Offset(cell * 8.5, cell * (9.5 + i)));
    
    // Bottom row going left
    path.add(Offset(cell * 7.5, cell * 13.5));
    path.add(Offset(cell * 6.5, cell * 13.5));
    
    // Going up on col 6
    for (int i = 0; i < 6; i++) path.add(Offset(cell * 6.5, cell * (12.5 - i)));
    
    // Going left on row 6
    for (int i = 0; i < 5; i++) path.add(Offset(cell * (5.5 - i), cell * 6.5));
    
    return path;
  }

  void _draw3DToken(Canvas canvas, Offset pos, Color color, double cell) {
    final radius = cell * 0.38;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + radius * 0.3), width: radius * 1.6, height: radius * 0.5),
      Paint()..color = Colors.black.withOpacity(0.25),
    );

    // Token base (darker)
    canvas.drawCircle(
      Offset(pos.dx, pos.dy + 3),
      radius,
      Paint()..color = Color.lerp(color, Colors.black, 0.3)!,
    );

    // Token body with gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [
        Color.lerp(color, Colors.white, 0.3)!,
        color,
        Color.lerp(color, Colors.black, 0.2)!,
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
      Offset(pos.dx - radius * 0.25, pos.dy - radius * 0.25),
      radius * 0.3,
      Paint()..color = Colors.white.withOpacity(0.5),
    );

    // Border
    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
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

  void _drawArrow(Canvas canvas, Offset pos, double angle, double size) {
    final path = Path()
      ..moveTo(pos.dx + math.cos(angle) * size, pos.dy + math.sin(angle) * size)
      ..lineTo(pos.dx + math.cos(angle + 2.5) * size * 0.7, pos.dy + math.sin(angle + 2.5) * size * 0.7)
      ..lineTo(pos.dx + math.cos(angle - 2.5) * size * 0.7, pos.dy + math.sin(angle - 2.5) * size * 0.7)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.grey.shade400);
  }

  @override
  bool shouldRepaint(covariant ZupeeExactBoardPainter oldDelegate) => true;
}

// ============================================
// DICE FACE PAINTER
// ============================================
class DiceFacePainter extends CustomPainter {
  final int value;
  final Color color;

  DiceFacePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final dotRadius = size.width * 0.1;
    final paint = Paint()..color = color;
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
  bool shouldRepaint(covariant DiceFacePainter oldDelegate) => oldDelegate.value != value;
}
