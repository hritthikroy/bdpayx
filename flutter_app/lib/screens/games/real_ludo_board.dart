import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class RealLudoBoard extends StatefulWidget {
  final String opponentName;
  final String betAmount;
  final String gameMode;

  const RealLudoBoard({
    super.key,
    required this.opponentName,
    required this.betAmount,
    required this.gameMode,
  });

  @override
  State<RealLudoBoard> createState() => _RealLudoBoardState();
}

class _RealLudoBoardState extends State<RealLudoBoard>
    with TickerProviderStateMixin {
  int _diceValue = 1;
  bool _isRolling = false;
  bool _isMyTurn = true;
  int _myPosition = -1; // -1 = home, 0-51 = board, 52 = won
  int _opponentPosition = -1;
  bool _canMove = false;
  int _timeLeft = 15;
  Timer? _turnTimer;
  late AnimationController _diceController;
  late AnimationController _tokenController;

  // Ludo board path (52 positions in a cross pattern)
  final List<Offset> _boardPath = [];

  @override
  void initState() {
    super.initState();
    _generateBoardPath();
    
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _tokenController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _startTurnTimer();
  }

  void _generateBoardPath() {
    // Generate the 52 positions in a cross pattern
    // This creates the classic Ludo board path
    final double cellSize = 30.0;
    final double centerX = 7.5 * cellSize;
    final double centerY = 7.5 * cellSize;

    // Green path (bottom-left, going up)
    for (int i = 0; i < 6; i++) {
      _boardPath.add(Offset(cellSize * 1, centerY + cellSize * (5 - i)));
    }
    
    // Turn corner (left side going up)
    for (int i = 0; i < 6; i++) {
      _boardPath.add(Offset(cellSize * 1, centerY - cellSize * (i + 1)));
    }
    
    // Top-left corner going right
    for (int i = 0; i < 5; i++) {
      _boardPath.add(Offset(cellSize * (2 + i), cellSize * 1));
    }
    
    // Red path (top-left, going right)
    for (int i = 0; i < 6; i++) {
      _boardPath.add(Offset(centerX + cellSize * i, cellSize * 1));
    }
    
    // Turn corner (top side going right)
    for (int i = 0; i < 6; i++) {
      _boardPath.add(Offset(centerX + cellSize * 6, cellSize * (2 + i)));
    }
    
    // Top-right corner going down
    for (int i = 0; i < 5; i++) {
      _boardPath.add(Offset(cellSize * 13, cellSize * (2 + i)));
    }
    
    // Yellow path (top-right, going down)
    for (int i = 0; i < 6; i++) {
      _boardPath.add(Offset(cellSize * 13, centerY + cellSize * i));
    }
    
    // Turn corner (right side going down)
    for (int i = 0; i < 6; i++) {
      _boardPath.add(Offset(cellSize * (12 - i), centerY + cellSize * 6));
    }
    
    // Bottom-right corner going left
    for (int i = 0; i < 5; i++) {
      _boardPath.add(Offset(cellSize * (12 - i), cellSize * 13));
    }
    
    // Blue path (bottom-right, going left)
    for (int i = 0; i < 6; i++) {
      _boardPath.add(Offset(centerX - cellSize * i, cellSize * 13));
    }
    
    // Final stretch to home
    for (int i = 0; i < 5; i++) {
      _boardPath.add(Offset(cellSize * (6 - i), cellSize * 12));
    }
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _diceController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _startTurnTimer() {
    _timeLeft = 15;
    _turnTimer?.cancel();
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft--;
          if (_timeLeft <= 0 && _isMyTurn && !_isRolling) {
            _rollDice();
          }
        });
      }
    });
  }

  void _rollDice() {
    if (_isRolling || !_isMyTurn) return;

    setState(() {
      _isRolling = true;
      _canMove = false;
    });

    _diceController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 600), () {
      final random = math.Random();
      final newDiceValue = random.nextInt(6) + 1;

      if (mounted) {
        setState(() {
          _diceValue = newDiceValue;
          _isRolling = false;

          if (_myPosition == -1 && newDiceValue == 6) {
            _canMove = true;
          } else if (_myPosition >= 0) {
            _canMove = true;
          } else {
            _switchTurn();
          }
        });
      }
    });
  }

  void _moveToken() {
    if (!_canMove || _isRolling) return;

    _tokenController.forward(from: 0);

    setState(() {
      if (_myPosition == -1 && _diceValue == 6) {
        _myPosition = 0;
      } else {
        _myPosition += _diceValue;

        if (_myPosition >= 52) {
          _myPosition = 52;
          _showWinDialog();
          return;
        }

        if (_myPosition == _opponentPosition && _opponentPosition >= 0) {
          _opponentPosition = -1;
          _showCutAnimation();
        }
      }

      _canMove = false;

      if (_diceValue == 6) {
        _startTurnTimer();
      } else {
        _switchTurn();
      }
    });
  }

  void _switchTurn() {
    setState(() {
      _isMyTurn = false;
      _canMove = false;
    });

    _startTurnTimer();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _opponentTurn();
    });
  }

  void _opponentTurn() {
    if (!mounted) return;

    final random = math.Random();
    final opponentDice = random.nextInt(6) + 1;

    setState(() {
      _diceValue = opponentDice;
    });

    _diceController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      setState(() {
        if (_opponentPosition == -1 && opponentDice == 6) {
          _opponentPosition = 0;
        } else if (_opponentPosition >= 0) {
          _opponentPosition += opponentDice;

          if (_opponentPosition >= 52) {
            _opponentPosition = 52;
            _showLoseDialog();
            return;
          }

          if (_opponentPosition == _myPosition && _myPosition >= 0) {
            _myPosition = -1;
            _showCutAnimation();
          }
        }

        if (opponentDice == 6) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _opponentTurn();
          });
        } else {
          _isMyTurn = true;
          _startTurnTimer();
        }
      });
    });
  }

  void _showCutAnimation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.close, color: Colors.white),
            SizedBox(width: 8),
            Text('Token Cut! 💥', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWinDialog() {
    _turnTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.emoji_events, color: Color(0xFFFBBF24), size: 32),
            SizedBox(width: 12),
            Text('You Won! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.currency_rupee, color: Colors.white, size: 24),
                  Text(
                    widget.betAmount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showLoseDialog() {
    _turnTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('You Lost'),
        content: const Text('Better luck next time!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B4513),
                        width: 8,
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
                      borderRadius: BorderRadius.circular(8),
                      child: CustomPaint(
                        painter: ProfessionalLudoBoardPainter(
                          myPosition: _myPosition,
                          opponentPosition: _opponentPosition,
                          isMyTurn: _isMyTurn,
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildDiceSection(),
            const SizedBox(height: 16),
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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.gameMode,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _timeLeft <= 5 ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_timeLeft}s',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
            const Color(0xFF1E293B),
            const Color(0xFF334155),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isMyTurn ? const Color(0xFF00C853) : const Color(0xFFFF1744),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isMyTurn ? const Color(0xFF00C853) : const Color(0xFFFF1744))
                .withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isMyTurn ? '🎯 Your Turn' : '⏳ ${widget.opponentName}\'s Turn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isMyTurn ? const Color(0xFF00C853) : const Color(0xFFFF1744),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _canMove ? 'Tap to move your token!' : 'Roll the dice',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _canMove ? _moveToken : (_isMyTurn ? _rollDice : null),
            child: AnimatedBuilder(
              animation: _diceController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _diceController.value * math.pi * 4,
                  child: Transform.scale(
                    scale: 1.0 + (math.sin(_diceController.value * math.pi) * 0.2),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _canMove
                              ? [const Color(0xFF00C853), const Color(0xFF00E676)]
                              : [Colors.white, Colors.grey[200]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_canMove ? const Color(0xFF00C853) : Colors.white)
                                .withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _canMove
                            ? const Icon(Icons.touch_app, color: Colors.white, size: 36)
                            : _buildDiceDots(_diceValue),
                      ),
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

  Widget _buildDiceDots(int value) {
    return CustomPaint(
      size: const Size(50, 50),
      painter: DicePainter(value),
    );
  }
}

class ProfessionalLudoBoardPainter extends CustomPainter {
  final int myPosition;
  final int opponentPosition;
  final bool isMyTurn;

  // Colors
  static const Color redColor = Color(0xFFE53935);
  static const Color greenColor = Color(0xFF43A047);
  static const Color yellowColor = Color(0xFFFDD835);
  static const Color blueColor = Color(0xFF1E88E5);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color boardBg = Color(0xFFF5F5DC);

  ProfessionalLudoBoardPainter({
    required this.myPosition,
    required this.opponentPosition,
    required this.isMyTurn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 15;

    // Draw cream/beige board background
    final bgPaint = Paint()..color = boardBg;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw the 4 home quadrants
    _drawHomeQuadrant(canvas, 0, 0, cellSize * 6, redColor);
    _drawHomeQuadrant(canvas, cellSize * 9, 0, cellSize * 6, yellowColor);
    _drawHomeQuadrant(canvas, 0, cellSize * 9, cellSize * 6, greenColor);
    _drawHomeQuadrant(canvas, cellSize * 9, cellSize * 9, cellSize * 6, blueColor);

    // Draw the cross paths (white with colored home columns)
    _drawCrossPaths(canvas, size, cellSize);

    // Draw center triangle home
    _drawCenterHome(canvas, size, cellSize);

    // Draw safe spots (stars)
    _drawSafeSpots(canvas, cellSize);

    // Draw tokens
    _drawTokens(canvas, cellSize);

    // Draw glossy overlay effect
    _drawGlossyOverlay(canvas, size);
  }

  void _drawGlossyOverlay(Canvas canvas, Size size) {
    // Top glossy shine
    final glossyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.5), glossyPaint);

    // Corner highlights
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), size.width * 0.2, highlightPaint);
  }

  void _drawHomeQuadrant(Canvas canvas, double x, double y, double size, Color color) {
    // Draw gradient background for glossy effect
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.9),
          color,
          color.withOpacity(0.8),
        ],
      ).createShader(Rect.fromLTWH(x, y, size, size));
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), gradientPaint);

    // Draw inner white area with 4 token spots (glossy)
    final innerSize = size * 0.7;
    final innerX = x + (size - innerSize) / 2;
    final innerY = y + (size - innerSize) / 2;
    
    // Inner white with gradient
    final innerGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.grey[100]!,
        ],
      ).createShader(Rect.fromLTWH(innerX, innerY, innerSize, innerSize));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(innerX, innerY, innerSize, innerSize),
        const Radius.circular(12),
      ),
      innerGradient,
    );

    // Inner shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(innerX + 2, innerY + 2, innerSize, innerSize),
        const Radius.circular(12),
      ),
      shadowPaint,
    );

    // Draw 4 token circles in home with glossy effect
    final spotRadius = size * 0.12;
    final positions = [
      Offset(innerX + innerSize * 0.3, innerY + innerSize * 0.3),
      Offset(innerX + innerSize * 0.7, innerY + innerSize * 0.3),
      Offset(innerX + innerSize * 0.3, innerY + innerSize * 0.7),
      Offset(innerX + innerSize * 0.7, innerY + innerSize * 0.7),
    ];
    for (final pos in positions) {
      // Shadow
      canvas.drawCircle(
        Offset(pos.dx + 2, pos.dy + 2),
        spotRadius,
        Paint()..color = Colors.black.withOpacity(0.2),
      );
      // Gradient fill
      final spotGradient = Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.8), color],
        ).createShader(Rect.fromCircle(center: pos, radius: spotRadius));
      canvas.drawCircle(pos, spotRadius, spotGradient);
      // Highlight
      canvas.drawCircle(
        Offset(pos.dx - spotRadius * 0.3, pos.dy - spotRadius * 0.3),
        spotRadius * 0.3,
        Paint()..color = Colors.white.withOpacity(0.4),
      );
    }
  }

  void _drawCrossPaths(Canvas canvas, Size size, double cellSize) {
    final whitePaint = Paint()..color = whiteColor;
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Horizontal path (middle row - 3 rows)
    canvas.drawRect(
      Rect.fromLTWH(0, cellSize * 6, size.width, cellSize * 3),
      whitePaint,
    );

    // Vertical path (middle column - 3 columns)
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 6, 0, cellSize * 3, size.height),
      whitePaint,
    );

    // Draw individual cells in the cross path with borders
    // Horizontal cells
    for (int row = 6; row < 9; row++) {
      for (int col = 0; col < 6; col++) {
        canvas.drawRect(
          Rect.fromLTWH(cellSize * col, cellSize * row, cellSize, cellSize),
          borderPaint,
        );
      }
      for (int col = 9; col < 15; col++) {
        canvas.drawRect(
          Rect.fromLTWH(cellSize * col, cellSize * row, cellSize, cellSize),
          borderPaint,
        );
      }
    }

    // Vertical cells
    for (int col = 6; col < 9; col++) {
      for (int row = 0; row < 6; row++) {
        canvas.drawRect(
          Rect.fromLTWH(cellSize * col, cellSize * row, cellSize, cellSize),
          borderPaint,
        );
      }
      for (int row = 9; row < 15; row++) {
        canvas.drawRect(
          Rect.fromLTWH(cellSize * col, cellSize * row, cellSize, cellSize),
          borderPaint,
        );
      }
    }

    // Draw colored home columns with individual cells
    // Red home column (top, going down) - column 7, rows 1-5
    for (int row = 1; row < 6; row++) {
      final cellRect = Rect.fromLTWH(cellSize * 7, cellSize * row, cellSize, cellSize);
      canvas.drawRect(cellRect, Paint()..color = redColor.withOpacity(0.6));
      canvas.drawRect(cellRect, borderPaint);
    }

    // Yellow home column (right, going left) - row 7, columns 9-13
    for (int col = 9; col < 14; col++) {
      final cellRect = Rect.fromLTWH(cellSize * col, cellSize * 7, cellSize, cellSize);
      canvas.drawRect(cellRect, Paint()..color = yellowColor.withOpacity(0.6));
      canvas.drawRect(cellRect, borderPaint);
    }

    // Blue home column (bottom, going up) - column 7, rows 9-13
    for (int row = 9; row < 14; row++) {
      final cellRect = Rect.fromLTWH(cellSize * 7, cellSize * row, cellSize, cellSize);
      canvas.drawRect(cellRect, Paint()..color = blueColor.withOpacity(0.6));
      canvas.drawRect(cellRect, borderPaint);
    }

    // Green home column (left, going right) - row 7, columns 1-5
    for (int col = 1; col < 6; col++) {
      final cellRect = Rect.fromLTWH(cellSize * col, cellSize * 7, cellSize, cellSize);
      canvas.drawRect(cellRect, Paint()..color = greenColor.withOpacity(0.6));
      canvas.drawRect(cellRect, borderPaint);
    }

    // Draw starting cells with color (where tokens enter the board)
    // Green start - row 6, col 1
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 1, cellSize * 6, cellSize, cellSize),
      Paint()..color = greenColor.withOpacity(0.6),
    );
    // Red start - row 1, col 8
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 8, cellSize * 1, cellSize, cellSize),
      Paint()..color = redColor.withOpacity(0.6),
    );
    // Yellow start - row 8, col 13
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 13, cellSize * 8, cellSize, cellSize),
      Paint()..color = yellowColor.withOpacity(0.6),
    );
    // Blue start - row 13, col 6
    canvas.drawRect(
      Rect.fromLTWH(cellSize * 6, cellSize * 13, cellSize, cellSize),
      Paint()..color = blueColor.withOpacity(0.6),
    );
  }

  void _drawCenterHome(Canvas canvas, Size size, double cellSize) {
    final center = Offset(size.width / 2, size.height / 2);
    final triangleSize = cellSize * 1.5;

    // Draw 4 triangles pointing to center with glossy effect
    final colors = [redColor, yellowColor, blueColor, greenColor];
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final angle = i * math.pi / 2;
      
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + math.cos(angle - math.pi / 4) * triangleSize * 1.5,
        center.dy + math.sin(angle - math.pi / 4) * triangleSize * 1.5,
      );
      path.lineTo(
        center.dx + math.cos(angle + math.pi / 4) * triangleSize * 1.5,
        center.dy + math.sin(angle + math.pi / 4) * triangleSize * 1.5,
      );
      path.close();

      // Gradient fill for glossy effect
      final gradientPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          colors: [colors[i].withOpacity(0.9), colors[i]],
        ).createShader(path.getBounds());
      canvas.drawPath(path, gradientPaint);

      // Border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawPath(path, borderPaint);
    }

    // Draw center circle with glossy effect
    final centerGlow = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, cellSize * 0.4, centerGlow);
    
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.grey[300]!],
      ).createShader(Rect.fromCircle(center: center, radius: cellSize * 0.3));
    canvas.drawCircle(center, cellSize * 0.3, centerPaint);
  }

  void _drawSafeSpots(Canvas canvas, double cellSize) {
    // Safe spot positions (stars on the board) - at starting positions
    final safeSpots = [
      // Green safe spots
      Offset(cellSize * 1.5, cellSize * 6.5),   // Green start
      Offset(cellSize * 2.5, cellSize * 8.5),   // Green safe
      // Red safe spots
      Offset(cellSize * 8.5, cellSize * 1.5),   // Red start
      Offset(cellSize * 6.5, cellSize * 2.5),   // Red safe
      // Yellow safe spots
      Offset(cellSize * 13.5, cellSize * 8.5),  // Yellow start
      Offset(cellSize * 12.5, cellSize * 6.5),  // Yellow safe
      // Blue safe spots
      Offset(cellSize * 6.5, cellSize * 13.5),  // Blue start
      Offset(cellSize * 8.5, cellSize * 12.5),  // Blue safe
    ];

    for (final spot in safeSpots) {
      _drawStar(canvas, spot, cellSize * 0.25, Paint()..color = Colors.black87);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
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
    canvas.drawPath(path, paint);
  }

  void _drawTokens(Canvas canvas, double cellSize) {
    // Get path positions
    final pathPositions = _getAllPathPositions(cellSize);

    // Draw my token (green)
    if (myPosition >= 0 && myPosition < pathPositions.length) {
      _drawToken(canvas, pathPositions[myPosition], greenColor, cellSize);
    } else if (myPosition == -1) {
      // At home
      _drawToken(canvas, Offset(cellSize * 2.5, cellSize * 11.5), greenColor, cellSize);
    }

    // Draw opponent token (red)
    if (opponentPosition >= 0 && opponentPosition < pathPositions.length) {
      _drawToken(canvas, pathPositions[opponentPosition], redColor, cellSize);
    } else if (opponentPosition == -1) {
      // At home
      _drawToken(canvas, Offset(cellSize * 2.5, cellSize * 2.5), redColor, cellSize);
    }
  }

  void _drawToken(Canvas canvas, Offset position, Color color, double cellSize) {
    final radius = cellSize * 0.4;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(position.dx + 2, position.dy + 2), radius, shadowPaint);

    // Draw token body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.9), color],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: position, radius: radius));
    canvas.drawCircle(position, radius, bodyPaint);

    // Draw highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4);
    canvas.drawCircle(
      Offset(position.dx - radius * 0.3, position.dy - radius * 0.3),
      radius * 0.3,
      highlightPaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(position, radius, borderPaint);
  }

  List<Offset> _getAllPathPositions(double cellSize) {
    final positions = <Offset>[];

    // Green's path (starting from green start, going clockwise)
    // Bottom-left, going up
    for (int i = 5; i >= 0; i--) {
      positions.add(Offset(cellSize * 0.5, cellSize * (6 + i) + cellSize * 0.5));
    }
    // Top-left corner, going right
    positions.add(Offset(cellSize * 0.5, cellSize * 6.5));
    for (int i = 0; i < 5; i++) {
      positions.add(Offset(cellSize * (1 + i) + cellSize * 0.5, cellSize * 5.5));
    }
    // Top row, going right
    for (int i = 0; i < 6; i++) {
      positions.add(Offset(cellSize * (6 + i) + cellSize * 0.5, cellSize * 0.5));
    }
    // Top-right, going down
    for (int i = 0; i < 6; i++) {
      positions.add(Offset(cellSize * 14.5, cellSize * (1 + i) + cellSize * 0.5));
    }
    // Right side, going down
    for (int i = 0; i < 6; i++) {
      positions.add(Offset(cellSize * (9 + i) + cellSize * 0.5, cellSize * 6.5));
    }
    // Bottom-right, going left
    for (int i = 5; i >= 0; i--) {
      positions.add(Offset(cellSize * (9 + i) + cellSize * 0.5, cellSize * 8.5));
    }
    // Bottom row, going left
    for (int i = 5; i >= 0; i--) {
      positions.add(Offset(cellSize * (6 + i) + cellSize * 0.5, cellSize * 14.5));
    }
    // Bottom-left, going up
    for (int i = 5; i >= 0; i--) {
      positions.add(Offset(cellSize * 0.5, cellSize * (9 + i) + cellSize * 0.5));
    }

    return positions;
  }

  @override
  bool shouldRepaint(ProfessionalLudoBoardPainter oldDelegate) {
    return oldDelegate.myPosition != myPosition ||
        oldDelegate.opponentPosition != opponentPosition ||
        oldDelegate.isMyTurn != isMyTurn;
  }
}

class DicePainter extends CustomPainter {
  final int value;

  DicePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final dotRadius = size.width * 0.08;

    final dots = _getDotsForValue(value);

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

  List<Offset> _getDotsForValue(int value) {
    switch (value) {
      case 1:
        return [const Offset(0, 0)];
      case 2:
        return [const Offset(-0.3, -0.3), const Offset(0.3, 0.3)];
      case 3:
        return [
          const Offset(-0.3, -0.3),
          const Offset(0, 0),
          const Offset(0.3, 0.3),
        ];
      case 4:
        return [
          const Offset(-0.3, -0.3),
          const Offset(0.3, -0.3),
          const Offset(-0.3, 0.3),
          const Offset(0.3, 0.3),
        ];
      case 5:
        return [
          const Offset(-0.3, -0.3),
          const Offset(0.3, -0.3),
          const Offset(0, 0),
          const Offset(-0.3, 0.3),
          const Offset(0.3, 0.3),
        ];
      case 6:
        return [
          const Offset(-0.3, -0.3),
          const Offset(0.3, -0.3),
          const Offset(-0.3, 0),
          const Offset(0.3, 0),
          const Offset(-0.3, 0.3),
          const Offset(0.3, 0.3),
        ];
      default:
        return [];
    }
  }

  @override
  bool shouldRepaint(DicePainter oldDelegate) => oldDelegate.value != value;
}
