import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

// ============================================
// PROFESSIONAL LUDO - EXACT ZUPEE STYLE
// 4 Colors: Blue, Red, Yellow, Green
// ============================================

class LudoProfessional extends StatefulWidget {
  final String prizePot;

  const LudoProfessional({
    super.key,
    this.prizePot = '50',
  });

  @override
  State<LudoProfessional> createState() => _LudoProfessionalState();
}

class _LudoProfessionalState extends State<LudoProfessional>
    with TickerProviderStateMixin {
  
  // Game state
  int _timeLeft = 600;
  int _turnTime = 15;
  Timer? _gameTimer;
  Timer? _turnTimer;
  
  bool _isMyTurn = true;
  int _diceValue = 1;
  bool _isRolling = false;
  bool _canMove = false;
  
  // Scores
  int _blueScore = 0;
  int _greenScore = 0;
  
  // Tokens: -1 = home, 0-51 = board, 52-56 = home stretch, 57 = finished
  List<int> _blueTokens = [-1, -1, -1, -1];
  List<int> _greenTokens = [-1, -1, -1, -1];
  
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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _startTimers();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _turnTimer?.cancel();
    _diceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startTimers() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && _timeLeft > 0) setState(() => _timeLeft--);
    });
    _startTurnTimer();
  }

  void _startTurnTimer() {
    _turnTime = 15;
    _turnTimer?.cancel();
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _turnTime--;
          if (_turnTime <= 0) {
            if (!_isRolling && !_canMove) _rollDice();
            else _switchTurn();
          }
        });
      }
    });
  }

  String _formatTime(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _rollDice() {
    if (_isRolling || !_isMyTurn || _canMove) return;
    setState(() => _isRolling = true);
    _diceController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final val = math.Random().nextInt(6) + 1;
      setState(() {
        _diceValue = val;
        _isRolling = false;
        _canMove = _hasValidMove(val);
        if (!_canMove) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) _switchTurn();
          });
        }
      });
    });
  }

  bool _hasValidMove(int dice) {
    for (int i = 0; i < 4; i++) {
      if (_isValidMove(i, dice)) return true;
    }
    return false;
  }

  bool _isValidMove(int idx, int dice) {
    final pos = _blueTokens[idx];
    if (pos == -1) return dice == 6;
    if (pos >= 57) return false;
    return pos + dice <= 57;
  }

  void _moveToken(int idx) {
    if (!_canMove || !_isValidMove(idx, _diceValue)) return;
    
    setState(() {
      if (_blueTokens[idx] == -1) {
        _blueTokens[idx] = 0;
      } else {
        _blueTokens[idx] += _diceValue;
        if (_blueTokens[idx] >= 57) {
          _blueTokens[idx] = 57;
          _blueScore += 10;
        }
        _checkCut(_blueTokens[idx]);
      }
      _canMove = false;
      
      if (_checkWin()) {
        _showWinDialog();
        return;
      }
      
      if (_diceValue == 6) {
        _startTurnTimer();
      } else {
        _switchTurn();
      }
    });
  }

  void _checkCut(int pos) {
    if (pos >= 52) return;
    final safeSpots = [0, 8, 13, 21, 26, 34, 39, 47];
    if (safeSpots.contains(pos)) return;
    
    for (int i = 0; i < 4; i++) {
      if (_greenTokens[i] > 0 && _greenTokens[i] < 52) {
        final greenOnBlue = (_greenTokens[i] + 26) % 52;
        if (greenOnBlue == pos) {
          _greenTokens[i] = -1;
          _blueScore += 5;
          _showCutSnackbar();
        }
      }
    }
  }

  void _switchTurn() {
    setState(() {
      _isMyTurn = false;
      _canMove = false;
    });
    _startTurnTimer();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _opponentPlay();
    });
  }

  void _opponentPlay() {
    if (!mounted) return;
    setState(() => _isRolling = true);
    _diceController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final dice = math.Random().nextInt(6) + 1;
      setState(() {
        _diceValue = dice;
        _isRolling = false;
      });
      
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        
        int? moveIdx;
        for (int i = 0; i < 4; i++) {
          final pos = _greenTokens[i];
          if (pos == -1 && dice == 6) { moveIdx = i; break; }
          if (pos >= 0 && pos < 57 && pos + dice <= 57) { moveIdx = i; break; }
        }
        
        if (moveIdx != null) {
          setState(() {
            if (_greenTokens[moveIdx!] == -1) {
              _greenTokens[moveIdx] = 0;
            } else {
              _greenTokens[moveIdx] += dice;
              if (_greenTokens[moveIdx] >= 57) {
                _greenTokens[moveIdx] = 57;
                _greenScore += 10;
              }
            }
          });
          
          if (_greenTokens.every((t) => t == 57)) {
            _showLoseDialog();
            return;
          }
        }
        
        if (dice == 6) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) _opponentPlay();
          });
        } else {
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              setState(() => _isMyTurn = true);
              _startTurnTimer();
            }
          });
        }
      });
    });
  }

  bool _checkWin() => _blueTokens.every((t) => t == 57);

  void _showCutSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.flash_on, color: Colors.white),
            SizedBox(width: 8),
            Text('Token Cut! +5 💥'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWinDialog() {
    _gameTimer?.cancel();
    _turnTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),
            SizedBox(width: 8),
            Text('You Won! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('₹${widget.prizePot}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: const Text('Collect'),
          ),
        ],
      ),
    );
  }

  void _showLoseDialog() {
    _gameTimer?.cancel();
    _turnTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('You Lost'),
        content: const Text('Better luck next time!'),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a237e), Color(0xFF0d1442)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildPlayers(),
              Expanded(child: _buildBoard()),
              _buildDiceArea(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _circleButton(Icons.arrow_back_ios_new, const Color(0xFF2196F3), () => Navigator.pop(context)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8F00)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFF5D4037), size: 18),
                const SizedBox(width: 4),
                Text('₹${widget.prizePot}', style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Spacer(),
          _circleButton(Icons.settings, const Color(0xFF4CAF50), () {}),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildPlayers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _playerCard('You', _blueScore, const Color(0xFF1565C0), _isMyTurn),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: _turnTime <= 5 ? Colors.red : Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(_formatTime(_timeLeft), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Spacer(),
          _playerCard('Bot', _greenScore, const Color(0xFF2E7D32), !_isMyTurn),
        ],
      ),
    );
  }

  Widget _playerCard(String name, int score, Color color, bool active) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? Color.lerp(Colors.green, Colors.lightGreen, _glowController.value)! : Colors.amber,
              width: 3,
            ),
            boxShadow: active ? [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)] : null,
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                Text('$score', style: const TextStyle(color: Colors.white70, fontSize: 9)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoard() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF5D4037), width: 4),
            boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CustomPaint(
              painter: ProBoardPainter(
                blueTokens: _blueTokens,
                greenTokens: _greenTokens,
                canMove: _canMove,
                diceValue: _diceValue,
              ),
              child: _buildTapAreas(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapAreas() {
    if (!_canMove || !_isMyTurn) return const SizedBox();
    
    return LayoutBuilder(builder: (ctx, constraints) {
      final cell = constraints.maxWidth / 15;
      final List<Widget> taps = [];
      
      for (int i = 0; i < 4; i++) {
        if (_isValidMove(i, _diceValue)) {
          Offset pos;
          if (_blueTokens[i] == -1) {
            // Home positions
            final homePos = [
              Offset(cell * 1.8, cell * 1.8),
              Offset(cell * 4.2, cell * 1.8),
              Offset(cell * 1.8, cell * 4.2),
              Offset(cell * 4.2, cell * 4.2),
            ];
            pos = homePos[i];
          } else {
            pos = _getBoardPos(_blueTokens[i], cell);
          }
          
          taps.add(Positioned(
            left: pos.dx - cell * 0.6,
            top: pos.dy - cell * 0.6,
            child: GestureDetector(
              onTap: () => _moveToken(i),
              child: Container(
                width: cell * 1.2,
                height: cell * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.3),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Icon(Icons.touch_app, color: Colors.green, size: 18),
              ),
            ),
          ));
        }
      }
      
      return Stack(children: taps);
    });
  }

  Offset _getBoardPos(int pos, double cell) {
    if (pos < 0) return Offset.zero;
    final path = _genPath(cell);
    if (pos < path.length) return path[pos];
    // Home stretch
    if (pos >= 52 && pos < 57) {
      return Offset(cell * (1.5 + (pos - 52)), cell * 7.5);
    }
    return Offset(cell * 7.5, cell * 7.5);
  }

  List<Offset> _genPath(double c) {
    return [
      Offset(c*6.5, c*13.5), Offset(c*6.5, c*12.5), Offset(c*6.5, c*11.5), Offset(c*6.5, c*10.5), Offset(c*6.5, c*9.5), Offset(c*6.5, c*8.5),
      Offset(c*5.5, c*8.5), Offset(c*4.5, c*8.5), Offset(c*3.5, c*8.5), Offset(c*2.5, c*8.5), Offset(c*1.5, c*8.5), Offset(c*0.5, c*8.5),
      Offset(c*0.5, c*7.5), Offset(c*0.5, c*6.5),
      Offset(c*1.5, c*6.5), Offset(c*2.5, c*6.5), Offset(c*3.5, c*6.5), Offset(c*4.5, c*6.5), Offset(c*5.5, c*6.5), Offset(c*6.5, c*6.5),
      Offset(c*6.5, c*5.5), Offset(c*6.5, c*4.5), Offset(c*6.5, c*3.5), Offset(c*6.5, c*2.5), Offset(c*6.5, c*1.5), Offset(c*6.5, c*0.5),
      Offset(c*7.5, c*0.5), Offset(c*8.5, c*0.5),
      Offset(c*8.5, c*1.5), Offset(c*8.5, c*2.5), Offset(c*8.5, c*3.5), Offset(c*8.5, c*4.5), Offset(c*8.5, c*5.5), Offset(c*8.5, c*6.5),
      Offset(c*9.5, c*6.5), Offset(c*10.5, c*6.5), Offset(c*11.5, c*6.5), Offset(c*12.5, c*6.5), Offset(c*13.5, c*6.5), Offset(c*14.5, c*6.5),
      Offset(c*14.5, c*7.5), Offset(c*14.5, c*8.5),
      Offset(c*13.5, c*8.5), Offset(c*12.5, c*8.5), Offset(c*11.5, c*8.5), Offset(c*10.5, c*8.5), Offset(c*9.5, c*8.5), Offset(c*8.5, c*8.5),
      Offset(c*8.5, c*9.5), Offset(c*8.5, c*10.5), Offset(c*8.5, c*11.5), Offset(c*8.5, c*12.5), Offset(c*8.5, c*13.5), Offset(c*8.5, c*14.5),
      Offset(c*7.5, c*14.5),
    ];
  }

  Widget _buildDiceArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isMyTurn ? Colors.green : Colors.red, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _isMyTurn ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(_isMyTurn ? Icons.person : Icons.smart_toy, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isMyTurn ? 'Your Turn' : 'Bot Playing...',
                  style: TextStyle(color: _isMyTurn ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(_canMove ? 'Tap token to move' : 'Tap dice to roll', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _turnTime / 15,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(_turnTime <= 5 ? Colors.red : Colors.green),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: (_isMyTurn && !_isRolling && !_canMove) ? _rollDice : null,
            child: AnimatedBuilder(
              animation: _diceController,
              builder: (ctx, _) {
                return Transform.rotate(
                  angle: _diceController.value * math.pi * 4,
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: _canMove ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
                    ),
                    child: _canMove
                        ? const Icon(Icons.touch_app, color: Colors.white, size: 28)
                        : CustomPaint(painter: DiceFacePainter(_diceValue)),
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
// PROFESSIONAL BOARD PAINTER - 4 COLORS
// ============================================
class ProBoardPainter extends CustomPainter {
  final List<int> blueTokens;
  final List<int> greenTokens;
  final bool canMove;
  final int diceValue;

  // Vibrant Zupee colors
  static const Color blue = Color(0xFF1976D2);
  static const Color red = Color(0xFFE53935);
  static const Color yellow = Color(0xFFFDD835);
  static const Color green = Color(0xFF43A047);
  static const Color white = Color(0xFFFFFFFF);

  ProBoardPainter({
    required this.blueTokens,
    required this.greenTokens,
    required this.canMove,
    required this.diceValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 15;

    // White background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = white);

    // 4 colored quadrants
    _drawQuadrant(canvas, 0, 0, c * 6, blue, c, blueTokens);           // Blue top-left
    _drawQuadrant(canvas, c * 9, 0, c * 6, red, c, [-1,-1,-1,-1]);     // Red top-right
    _drawQuadrant(canvas, 0, c * 9, c * 6, yellow, c, [-1,-1,-1,-1]);  // Yellow bottom-left
    _drawQuadrant(canvas, c * 9, c * 9, c * 6, green, c, greenTokens); // Green bottom-right

    // Cross paths
    _drawPaths(canvas, size, c);

    // Home columns
    _drawHomeColumns(canvas, c);

    // Center
    _drawCenter(canvas, size, c);

    // Stars
    _drawStars(canvas, c);

    // Board tokens
    _drawBoardTokens(canvas, c);
  }

  void _drawQuadrant(Canvas canvas, double x, double y, double s, Color color, double c, List<int> tokens) {
    // Background
    canvas.drawRect(Rect.fromLTWH(x, y, s, s), Paint()..color = color);

    // Inner white
    final p = s * 0.1;
    final inner = s * 0.8;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x + p, y + p, inner, inner), const Radius.circular(10)),
      Paint()..color = white,
    );

    // Token spots
    final r = s * 0.11;
    final cx = x + s / 2;
    final cy = y + s / 2;
    final off = s * 0.22;
    final spots = [
      Offset(cx - off, cy - off),
      Offset(cx + off, cy - off),
      Offset(cx - off, cy + off),
      Offset(cx + off, cy + off),
    ];

    for (int i = 0; i < 4; i++) {
      if (tokens[i] == -1) {
        _draw3DToken(canvas, spots[i], color, r);
      } else {
        // Empty ring
        canvas.drawCircle(spots[i], r, Paint()..color = color.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2);
      }
    }
  }

  void _draw3DToken(Canvas canvas, Offset pos, Color color, double r) {
    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + r * 0.35), width: r * 1.7, height: r * 0.5),
      Paint()..color = Colors.black26,
    );
    // Base
    canvas.drawCircle(Offset(pos.dx, pos.dy + 2), r, Paint()..color = Color.lerp(color, Colors.black, 0.25)!);
    // Body gradient
    final grad = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      colors: [Color.lerp(color, white, 0.35)!, color, Color.lerp(color, Colors.black, 0.1)!],
    );
    canvas.drawCircle(pos, r, Paint()..shader = grad.createShader(Rect.fromCircle(center: pos, radius: r)));
    // Highlight
    canvas.drawCircle(Offset(pos.dx - r * 0.3, pos.dy - r * 0.3), r * 0.22, Paint()..color = white.withOpacity(0.55));
  }

  void _drawPaths(Canvas canvas, Size size, double c) {
    final border = Paint()..color = Colors.grey.shade300..style = PaintingStyle.stroke..strokeWidth = 0.5;

    // Horizontal path cells
    for (int row = 6; row < 9; row++) {
      for (int col = 0; col < 15; col++) {
        if (col >= 6 && col < 9) continue;
        canvas.drawRect(Rect.fromLTWH(c * col, c * row, c, c), border);
      }
    }
    // Vertical path cells
    for (int col = 6; col < 9; col++) {
      for (int row = 0; row < 15; row++) {
        if (row >= 6 && row < 9) continue;
        canvas.drawRect(Rect.fromLTWH(c * col, c * row, c, c), border);
      }
    }
  }

  void _drawHomeColumns(Canvas canvas, double c) {
    // Blue home (left, row 7)
    for (int i = 1; i < 6; i++) {
      canvas.drawRect(Rect.fromLTWH(c * i, c * 7, c, c), Paint()..color = blue.withOpacity(0.4));
    }
    // Red home (top, col 7)
    for (int i = 1; i < 6; i++) {
      canvas.drawRect(Rect.fromLTWH(c * 7, c * i, c, c), Paint()..color = red.withOpacity(0.4));
    }
    // Yellow home (bottom, col 7)
    for (int i = 9; i < 14; i++) {
      canvas.drawRect(Rect.fromLTWH(c * 7, c * i, c, c), Paint()..color = yellow.withOpacity(0.4));
    }
    // Green home (right, row 7)
    for (int i = 9; i < 14; i++) {
      canvas.drawRect(Rect.fromLTWH(c * i, c * 7, c, c), Paint()..color = green.withOpacity(0.4));
    }

    // Start cells
    canvas.drawRect(Rect.fromLTWH(c * 6, c * 1, c, c), Paint()..color = blue.withOpacity(0.3));
    canvas.drawRect(Rect.fromLTWH(c * 13, c * 6, c, c), Paint()..color = red.withOpacity(0.3));
    canvas.drawRect(Rect.fromLTWH(c * 1, c * 8, c, c), Paint()..color = yellow.withOpacity(0.3));
    canvas.drawRect(Rect.fromLTWH(c * 8, c * 13, c, c), Paint()..color = green.withOpacity(0.3));

    // Arrows
    _drawArrow(canvas, Offset(c * 0.5, c * 7.5), 0, c * 0.28, blue);
    _drawArrow(canvas, Offset(c * 7.5, c * 0.5), math.pi / 2, c * 0.28, red);
    _drawArrow(canvas, Offset(c * 14.5, c * 7.5), math.pi, c * 0.28, green);
    _drawArrow(canvas, Offset(c * 7.5, c * 14.5), -math.pi / 2, c * 0.28, yellow);
  }

  void _drawArrow(Canvas canvas, Offset pos, double angle, double size, Color color) {
    final path = Path()
      ..moveTo(pos.dx + math.cos(angle) * size, pos.dy + math.sin(angle) * size)
      ..lineTo(pos.dx + math.cos(angle + 2.5) * size * 0.7, pos.dy + math.sin(angle + 2.5) * size * 0.7)
      ..lineTo(pos.dx + math.cos(angle - 2.5) * size * 0.7, pos.dy + math.sin(angle - 2.5) * size * 0.7)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawCenter(Canvas canvas, Size size, double c) {
    final center = Offset(size.width / 2, size.height / 2);
    final ts = c * 1.5;

    // 4 triangles
    final colors = [blue, red, green, yellow];
    final angles = [math.pi, -math.pi / 2, 0, math.pi / 2];
    for (int i = 0; i < 4; i++) {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + math.cos(angles[i] - math.pi / 4) * ts, center.dy + math.sin(angles[i] - math.pi / 4) * ts)
        ..lineTo(center.dx + math.cos(angles[i] + math.pi / 4) * ts, center.dy + math.sin(angles[i] + math.pi / 4) * ts)
        ..close();
      canvas.drawPath(path, Paint()..color = colors[i]);
      canvas.drawPath(path, Paint()..color = white.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1);
    }

    // Center circle
    canvas.drawCircle(center, c * 0.38, Paint()..color = const Color(0xFF455A64));
    canvas.drawCircle(center, c * 0.3, Paint()..color = white);
    
    // Home icon
    final hp = Path()
      ..moveTo(center.dx, center.dy - c * 0.15)
      ..lineTo(center.dx - c * 0.12, center.dy)
      ..lineTo(center.dx - c * 0.08, center.dy)
      ..lineTo(center.dx - c * 0.08, center.dy + c * 0.1)
      ..lineTo(center.dx + c * 0.08, center.dy + c * 0.1)
      ..lineTo(center.dx + c * 0.08, center.dy)
      ..lineTo(center.dx + c * 0.12, center.dy)
      ..close();
    canvas.drawPath(hp, Paint()..color = const Color(0xFF455A64));
  }

  void _drawStars(Canvas canvas, double c) {
    final positions = [
      Offset(c * 2.5, c * 6.5), Offset(c * 6.5, c * 2.5),
      Offset(c * 8.5, c * 6.5), Offset(c * 6.5, c * 8.5),
      Offset(c * 12.5, c * 8.5), Offset(c * 8.5, c * 12.5),
      Offset(c * 2.5, c * 8.5), Offset(c * 8.5, c * 2.5),
    ];
    for (final p in positions) {
      _drawStar(canvas, p, c * 0.2);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
      if (i == 0) path.moveTo(center.dx + math.cos(angle) * r, center.dy + math.sin(angle) * r);
      else path.lineTo(center.dx + math.cos(angle) * r, center.dy + math.sin(angle) * r);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.grey.shade700);
  }

  void _drawBoardTokens(Canvas canvas, double c) {
    final path = _genPath(c);
    
    // Blue tokens on board
    for (int i = 0; i < 4; i++) {
      final pos = blueTokens[i];
      if (pos >= 0 && pos < 52) {
        _draw3DToken(canvas, path[pos], blue, c * 0.32);
      } else if (pos >= 52 && pos < 57) {
        _draw3DToken(canvas, Offset(c * (1.5 + (pos - 52)), c * 7.5), blue, c * 0.32);
      }
    }
    
    // Green tokens on board
    for (int i = 0; i < 4; i++) {
      final pos = greenTokens[i];
      if (pos >= 0 && pos < 52) {
        final greenPath = (pos + 26) % 52;
        _draw3DToken(canvas, path[greenPath], green, c * 0.32);
      } else if (pos >= 52 && pos < 57) {
        _draw3DToken(canvas, Offset(c * (13.5 - (pos - 52)), c * 7.5), green, c * 0.32);
      }
    }
  }

  List<Offset> _genPath(double c) {
    return [
      Offset(c*6.5, c*13.5), Offset(c*6.5, c*12.5), Offset(c*6.5, c*11.5), Offset(c*6.5, c*10.5), Offset(c*6.5, c*9.5), Offset(c*6.5, c*8.5),
      Offset(c*5.5, c*8.5), Offset(c*4.5, c*8.5), Offset(c*3.5, c*8.5), Offset(c*2.5, c*8.5), Offset(c*1.5, c*8.5), Offset(c*0.5, c*8.5),
      Offset(c*0.5, c*7.5), Offset(c*0.5, c*6.5),
      Offset(c*1.5, c*6.5), Offset(c*2.5, c*6.5), Offset(c*3.5, c*6.5), Offset(c*4.5, c*6.5), Offset(c*5.5, c*6.5), Offset(c*6.5, c*6.5),
      Offset(c*6.5, c*5.5), Offset(c*6.5, c*4.5), Offset(c*6.5, c*3.5), Offset(c*6.5, c*2.5), Offset(c*6.5, c*1.5), Offset(c*6.5, c*0.5),
      Offset(c*7.5, c*0.5), Offset(c*8.5, c*0.5),
      Offset(c*8.5, c*1.5), Offset(c*8.5, c*2.5), Offset(c*8.5, c*3.5), Offset(c*8.5, c*4.5), Offset(c*8.5, c*5.5), Offset(c*8.5, c*6.5),
      Offset(c*9.5, c*6.5), Offset(c*10.5, c*6.5), Offset(c*11.5, c*6.5), Offset(c*12.5, c*6.5), Offset(c*13.5, c*6.5), Offset(c*14.5, c*6.5),
      Offset(c*14.5, c*7.5), Offset(c*14.5, c*8.5),
      Offset(c*13.5, c*8.5), Offset(c*12.5, c*8.5), Offset(c*11.5, c*8.5), Offset(c*10.5, c*8.5), Offset(c*9.5, c*8.5), Offset(c*8.5, c*8.5),
      Offset(c*8.5, c*9.5), Offset(c*8.5, c*10.5), Offset(c*8.5, c*11.5), Offset(c*8.5, c*12.5), Offset(c*8.5, c*13.5), Offset(c*8.5, c*14.5),
    ];
  }

  @override
  bool shouldRepaint(covariant ProBoardPainter old) => true;
}

// ============================================
// DICE FACE PAINTER
// ============================================
class DiceFacePainter extends CustomPainter {
  final int value;
  DiceFacePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width * 0.08;
    final paint = Paint()..color = const Color(0xFF212121);
    final cx = size.width / 2;
    final cy = size.height / 2;

    final dots = <Offset>[];
    switch (value) {
      case 1: dots.add(Offset(cx, cy)); break;
      case 2: dots.addAll([Offset(size.width * 0.3, size.height * 0.3), Offset(size.width * 0.7, size.height * 0.7)]); break;
      case 3: dots.addAll([Offset(size.width * 0.3, size.height * 0.3), Offset(cx, cy), Offset(size.width * 0.7, size.height * 0.7)]); break;
      case 4: dots.addAll([Offset(size.width * 0.3, size.height * 0.3), Offset(size.width * 0.7, size.height * 0.3), Offset(size.width * 0.3, size.height * 0.7), Offset(size.width * 0.7, size.height * 0.7)]); break;
      case 5: dots.addAll([Offset(size.width * 0.3, size.height * 0.3), Offset(size.width * 0.7, size.height * 0.3), Offset(cx, cy), Offset(size.width * 0.3, size.height * 0.7), Offset(size.width * 0.7, size.height * 0.7)]); break;
      case 6: dots.addAll([Offset(size.width * 0.3, size.height * 0.25), Offset(size.width * 0.7, size.height * 0.25), Offset(size.width * 0.3, size.height * 0.5), Offset(size.width * 0.7, size.height * 0.5), Offset(size.width * 0.3, size.height * 0.75), Offset(size.width * 0.7, size.height * 0.75)]); break;
    }
    for (final d in dots) canvas.drawCircle(d, r, paint);
  }

  @override
  bool shouldRepaint(covariant DiceFacePainter old) => old.value != value;
}
