import 'package:flutter/material.dart';
import 'dart:math' as math;

class LudoGameScreen extends StatefulWidget {
  final String opponentName;
  final String betAmount;
  final String gameMode;

  const LudoGameScreen({
    super.key,
    required this.opponentName,
    required this.betAmount,
    required this.gameMode,
  });

  @override
  State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen>
    with TickerProviderStateMixin {
  int _diceValue = 1;
  bool _isRolling = false;
  bool _isMyTurn = true;
  int _myScore = 0;
  int _opponentScore = 0;
  late AnimationController _diceController;
  late Animation<double> _diceAnimation;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _diceAnimation = CurvedAnimation(
      parent: _diceController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _diceController.dispose();
    super.dispose();
  }

  void _rollDice() {
    if (_isRolling || !_isMyTurn) return;

    setState(() {
      _isRolling = true;
    });

    _diceController.forward(from: 0);

    // Simulate dice roll
    Future.delayed(const Duration(milliseconds: 500), () {
      final random = math.Random();
      setState(() {
        _diceValue = random.nextInt(6) + 1;
        _myScore += _diceValue;
        _isRolling = false;
        _isMyTurn = false;
      });

      // Simulate opponent turn
      Future.delayed(const Duration(seconds: 2), () {
        _opponentTurn();
      });
    });
  }

  void _opponentTurn() {
    final random = math.Random();
    final opponentRoll = random.nextInt(6) + 1;

    setState(() {
      _opponentScore += opponentRoll;
      _isMyTurn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Game Board
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Opponent Section
                    _buildPlayerSection(
                      widget.opponentName,
                      _opponentScore,
                      const Color(0xFFEF4444),
                      !_isMyTurn,
                    ),

                    // Game Board Center
                    Expanded(
                      child: _buildGameBoard(),
                    ),

                    // Your Section
                    _buildPlayerSection(
                      'You',
                      _myScore,
                      const Color(0xFF10B981),
                      _isMyTurn,
                    ),
                  ],
                ),
              ),
            ),

            // Dice and Controls
            _buildDiceSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.gameMode,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.currency_rupee, color: Colors.white, size: 16),
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
          ),
          IconButton(
            onPressed: () {
              // Show game menu
            },
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSection(String name, int score, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: color.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: color, width: 3)
                  : null,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'YOUR TURN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFBBF24).withOpacity(0.1),
            const Color(0xFFEF4444).withOpacity(0.1),
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF6366F1).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 2,
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 15,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: 225,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: _getCellColor(index),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),
    );
  }

  Color _getCellColor(int index) {
    // Simplified Ludo board coloring
    final row = index ~/ 15;
    final col = index % 15;

    // Red home (top-left)
    if (row < 6 && col < 6) return const Color(0xFFEF4444).withOpacity(0.3);
    // Green home (top-right)
    if (row < 6 && col > 8) return const Color(0xFF10B981).withOpacity(0.3);
    // Yellow home (bottom-left)
    if (row > 8 && col < 6) return const Color(0xFFFBBF24).withOpacity(0.3);
    // Blue home (bottom-right)
    if (row > 8 && col > 8) return const Color(0xFF6366F1).withOpacity(0.3);

    // Path cells
    return Colors.white;
  }

  Widget _buildDiceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            _isMyTurn ? 'Your Turn - Roll the Dice!' : 'Opponent\'s Turn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isMyTurn ? const Color(0xFF10B981) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _rollDice,
            child: AnimatedBuilder(
              animation: _diceAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _diceAnimation.value * math.pi * 2,
                  child: Transform.scale(
                    scale: 1.0 + (_diceAnimation.value * 0.2),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _buildDiceDots(_diceValue),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_isMyTurn && !_isRolling)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'TAP TO ROLL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiceDots(int value) {
    final dots = <Offset>[];

    switch (value) {
      case 1:
        dots.add(const Offset(0, 0));
        break;
      case 2:
        dots.addAll([const Offset(-0.3, -0.3), const Offset(0.3, 0.3)]);
        break;
      case 3:
        dots.addAll([
          const Offset(-0.3, -0.3),
          const Offset(0, 0),
          const Offset(0.3, 0.3),
        ]);
        break;
      case 4:
        dots.addAll([
          const Offset(-0.3, -0.3),
          const Offset(0.3, -0.3),
          const Offset(-0.3, 0.3),
          const Offset(0.3, 0.3),
        ]);
        break;
      case 5:
        dots.addAll([
          const Offset(-0.3, -0.3),
          const Offset(0.3, -0.3),
          const Offset(0, 0),
          const Offset(-0.3, 0.3),
          const Offset(0.3, 0.3),
        ]);
        break;
      case 6:
        dots.addAll([
          const Offset(-0.3, -0.3),
          const Offset(0.3, -0.3),
          const Offset(-0.3, 0),
          const Offset(0.3, 0),
          const Offset(-0.3, 0.3),
          const Offset(0.3, 0.3),
        ]);
        break;
    }

    return CustomPaint(
      size: const Size(60, 60),
      painter: DicePainter(dots),
    );
  }
}

class DicePainter extends CustomPainter {
  final List<Offset> dots;

  DicePainter(this.dots);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final dotRadius = size.width * 0.08;

    for (final dot in dots) {
      canvas.drawCircle(
        Offset(
          center.dx + (dot.dx * size.width * 0.6),
          center.dy + (dot.dy * size.height * 0.6),
        ),
        dotRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DicePainter oldDelegate) => false;
}
