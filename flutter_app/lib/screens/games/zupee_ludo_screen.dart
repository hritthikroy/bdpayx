import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class ZupeeLudoScreen extends StatefulWidget {
  final String opponentName;
  final String betAmount;
  final String gameMode;

  const ZupeeLudoScreen({
    super.key,
    required this.opponentName,
    required this.betAmount,
    required this.gameMode,
  });

  @override
  State<ZupeeLudoScreen> createState() => _ZupeeLudoScreenState();
}

class _ZupeeLudoScreenState extends State<ZupeeLudoScreen>
    with TickerProviderStateMixin {
  // Game state
  int _diceValue = 1;
  bool _isRolling = false;
  bool _isMyTurn = true;
  int _myPosition = 0; // 0 = home, 1-52 = board positions, 53 = won
  int _opponentPosition = 0;
  bool _canMove = false;
  int _timeLeft = 15; // seconds per turn
  Timer? _turnTimer;
  late AnimationController _diceController;
  late AnimationController _tokenController;
  late Animation<double> _diceAnimation;
  late Animation<double> _tokenAnimation;

  // Zupee Ludo: 52 positions on the board (simplified)
  final int totalPositions = 52;
  final int winPosition = 53;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _diceAnimation = CurvedAnimation(
      parent: _diceController,
      curve: Curves.elasticOut,
    );

    _tokenController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _tokenAnimation = CurvedAnimation(
      parent: _tokenController,
      curve: Curves.easeInOut,
    );

    _startTurnTimer();
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
          if (_timeLeft <= 0) {
            // Auto-roll or skip turn
            if (_isMyTurn && !_isRolling) {
              _rollDice();
            }
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

    // Simulate dice roll
    Future.delayed(const Duration(milliseconds: 600), () {
      final random = math.Random();
      final newDiceValue = random.nextInt(6) + 1;

      if (mounted) {
        setState(() {
          _diceValue = newDiceValue;
          _isRolling = false;

          // Zupee Rule: Can move if dice is rolled
          if (_myPosition == 0 && newDiceValue == 6) {
            // Need 6 to start
            _canMove = true;
          } else if (_myPosition > 0) {
            // Already on board, can always move
            _canMove = true;
          } else {
            // Didn't get 6 to start, turn ends
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
      if (_myPosition == 0 && _diceValue == 6) {
        // Start from home
        _myPosition = 1;
      } else {
        // Move forward
        _myPosition += _diceValue;

        // Check if won
        if (_myPosition >= winPosition) {
          _myPosition = winPosition;
          _showWinDialog();
          return;
        }

        // Check if cut opponent
        if (_myPosition == _opponentPosition && _opponentPosition > 0) {
          _opponentPosition = 0; // Send opponent back to home
          _showCutAnimation();
        }
      }

      _canMove = false;

      // Zupee Rule: Get another turn if rolled 6
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

    // Simulate opponent turn
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
        if (_opponentPosition == 0 && opponentDice == 6) {
          _opponentPosition = 1;
        } else if (_opponentPosition > 0) {
          _opponentPosition += opponentDice;

          if (_opponentPosition >= winPosition) {
            _opponentPosition = winPosition;
            _showLoseDialog();
            return;
          }

          // Check if opponent cut you
          if (_opponentPosition == _myPosition && _myPosition > 0) {
            _myPosition = 0;
            _showCutAnimation();
          }
        }

        // Get another turn if rolled 6
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
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 8),
            const Text(
              'Amount credited to your wallet',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Lobby'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Restart game
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
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
        title: Row(
          children: const [
            Icon(Icons.sentiment_dissatisfied, color: Color(0xFFEF4444), size: 32),
            SizedBox(width: 12),
            Text('You Lost'),
          ],
        ),
        content: const Text('Better luck next time!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Lobby'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Column(
                children: [
                  _buildPlayerSection(
                    widget.opponentName,
                    _opponentPosition,
                    const Color(0xFFEF4444),
                    !_isMyTurn,
                  ),
                  Expanded(child: _buildGameBoard()),
                  _buildPlayerSection(
                    'You',
                    _myPosition,
                    const Color(0xFF10B981),
                    _isMyTurn,
                  ),
                ],
              ),
            ),
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
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit Game?'),
                  content: const Text('You will lose the bet amount if you exit now.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                      child: const Text('Exit'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.gameMode,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _timeLeft <= 5 ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: _timeLeft <= 5 ? Colors.white : Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_timeLeft}s',
                  style: TextStyle(
                    color: _timeLeft <= 5 ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSection(String name, int position, Color color, bool isActive) {
    final progress = position / winPosition;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: color.withOpacity(0.2), width: 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: color, width: 3) : null,
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
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position == 0
                      ? 'At Home'
                      : position >= winPosition
                          ? 'Winner! 🏆'
                          : 'Position: $position/$totalPositions',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Zupee Ludo - Race to Finish!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTokenDisplay('You', _myPosition, const Color(0xFF10B981)),
              const Icon(Icons.arrow_forward, size: 32, color: Color(0xFF64748B)),
              _buildTokenDisplay(widget.opponentName, _opponentPosition, const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '🎯 First to reach position 53 wins!',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenDisplay(String name, int position, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              position == 0 ? '🏠' : position >= winPosition ? '🏆' : '$position',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isMyTurn ? 'Your Turn' : 'Opponent\'s Turn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isMyTurn ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                if (_canMove)
                  const Text(
                    'Tap your token to move!',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _canMove ? _moveToken : _rollDice,
            child: AnimatedBuilder(
              animation: _diceAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _diceAnimation.value * math.pi * 2,
                  child: Transform.scale(
                    scale: 1.0 + (_diceAnimation.value * 0.2),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _canMove ? const Color(0xFF10B981) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_canMove ? const Color(0xFF10B981) : const Color(0xFF6366F1))
                                .withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _canMove
                            ? const Icon(Icons.touch_app, color: Colors.white, size: 32)
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
      size: const Size(50, 50),
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
