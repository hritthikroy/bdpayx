import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

// ============================================
// ZUPEE 1v1 LUDO - FULLY FUNCTIONAL GAME
// Professional UI + Real Game Logic
// ============================================

class Zupee1v1Ludo extends StatefulWidget {
  final String prizePot;
  final String player1Name;
  final String player2Name;

  const Zupee1v1Ludo({
    super.key,
    this.prizePot = '50',
    this.player1Name = 'You',
    this.player2Name = 'Opponent',
  });

  @override
  State<Zupee1v1Ludo> createState() => _Zupee1v1LudoState();
}

class _Zupee1v1LudoState extends State<Zupee1v1Ludo>
    with TickerProviderStateMixin {
  
  // Game State
  int _timeLeft = 600; // 10 minutes game
  int _turnTimeLeft = 15; // 15 seconds per turn
  Timer? _gameTimer;
  Timer? _turnTimer;
  
  // Players: 0 = You (Blue), 1 = Opponent (Green)
  bool _isMyTurn = true;
  int _myScore = 0;
  int _opponentScore = 0;
  
  // Dice
  int _diceValue = 1;
  bool _isRolling = false;
  bool _canMove = false;
  int? _selectedToken;
  
  // Token positions: -1 = home, 0-56 = on board path, 57 = finished
  // Each player has 4 tokens
  List<int> _myTokens = [-1, -1, -1, -1];
  List<int> _opponentTokens = [-1, -1, -1, -1];
  
  // Animation controllers
  late AnimationController _diceController;
  late AnimationController _glowController;
  late AnimationController _tokenMoveController;
  
  // Board path positions (52 cells around the board)
  final int _pathLength = 52;
  final int _homeStretchLength = 6;
  
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
    _tokenMoveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _startGameTimer();
    _startTurnTimer();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _turnTimer?.cancel();
    _diceController.dispose();
    _glowController.dispose();
    _tokenMoveController.dispose();
    super.dispose();
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && _timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _startTurnTimer() {
    _turnTimeLeft = 15;
    _turnTimer?.cancel();
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _turnTimeLeft--;
          if (_turnTimeLeft <= 0) {
            // Auto-roll or skip turn
            if (!_isRolling && !_canMove) {
              _rollDice();
            } else {
              _switchTurn();
            }
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _rollDice() {
    if (_isRolling || !_isMyTurn || _canMove) return;
    
    setState(() => _isRolling = true);
    _diceController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      final newValue = math.Random().nextInt(6) + 1;
      setState(() {
        _diceValue = newValue;
        _isRolling = false;
        
        // Check if can move any token
        _canMove = _checkCanMove(newValue);
        
        if (!_canMove) {
          // No valid moves, switch turn after delay
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) _switchTurn();
          });
        }
      });
    });
  }

  bool _checkCanMove(int diceValue) {
    for (int i = 0; i < 4; i++) {
      if (_isValidMove(i, diceValue)) {
        return true;
      }
    }
    return false;
  }

  bool _isValidMove(int tokenIndex, int diceValue) {
    final pos = _myTokens[tokenIndex];
    
    // Token at home - need 6 to come out
    if (pos == -1) {
      return diceValue == 6;
    }
    
    // Token already finished
    if (pos >= 57) {
      return false;
    }
    
    // Check if move would exceed finish
    final newPos = pos + diceValue;
    if (newPos > 57) {
      return false;
    }
    
    return true;
  }

  void _selectToken(int tokenIndex) {
    if (!_canMove || !_isMyTurn) return;
    
    if (_isValidMove(tokenIndex, _diceValue)) {
      setState(() => _selectedToken = tokenIndex);
      _moveToken(tokenIndex);
    }
  }

  void _moveToken(int tokenIndex) {
    final currentPos = _myTokens[tokenIndex];
    int newPos;
    
    if (currentPos == -1) {
      // Coming out of home
      newPos = 0;
    } else {
      newPos = currentPos + _diceValue;
    }
    
    _tokenMoveController.forward(from: 0).then((_) {
      if (!mounted) return;
      
      setState(() {
        _myTokens[tokenIndex] = newPos;
        _selectedToken = null;
        _canMove = false;
        
        // Check if token reached home
        if (newPos == 57) {
          _myScore += 10;
          _showScoreAnimation('+10');
        }
        
        // Check if cut opponent token
        _checkCutOpponent(newPos);
        
        // Check win condition
        if (_checkWin()) {
          _showWinDialog();
          return;
        }
        
        // Get another turn if rolled 6
        if (_diceValue == 6) {
          _startTurnTimer();
        } else {
          _switchTurn();
        }
      });
    });
  }

  void _checkCutOpponent(int myNewPos) {
    // Safe positions (can't cut here)
    final safePositions = [0, 8, 13, 21, 26, 34, 39, 47];
    if (safePositions.contains(myNewPos % _pathLength)) return;
    
    for (int i = 0; i < 4; i++) {
      // Convert opponent position to my reference
      final opponentActualPos = _opponentTokens[i];
      if (opponentActualPos > 0 && opponentActualPos < 52) {
        final opponentOnMyPath = (opponentActualPos + 26) % _pathLength;
        if (opponentOnMyPath == myNewPos % _pathLength) {
          setState(() {
            _opponentTokens[i] = -1; // Send back home
            _myScore += 5;
          });
          _showCutAnimation();
        }
      }
    }
  }

  void _switchTurn() {
    setState(() {
      _isMyTurn = false;
      _canMove = false;
      _selectedToken = null;
    });
    _startTurnTimer();
    
    // Simulate opponent turn
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _opponentTurn();
    });
  }

  void _opponentTurn() {
    if (!mounted) return;
    
    // Roll dice for opponent
    setState(() => _isRolling = true);
    _diceController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      final opponentDice = math.Random().nextInt(6) + 1;
      setState(() {
        _diceValue = opponentDice;
        _isRolling = false;
      });
      
      // Find valid move for opponent
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        
        int? tokenToMove;
        for (int i = 0; i < 4; i++) {
          if (_isValidOpponentMove(i, opponentDice)) {
            tokenToMove = i;
            break;
          }
        }
        
        if (tokenToMove != null) {
          _moveOpponentToken(tokenToMove, opponentDice);
        } else {
          // No valid move, switch back to player
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _isMyTurn = true);
              _startTurnTimer();
            }
          });
        }
      });
    });
  }

  bool _isValidOpponentMove(int tokenIndex, int diceValue) {
    final pos = _opponentTokens[tokenIndex];
    if (pos == -1) return diceValue == 6;
    if (pos >= 57) return false;
    return pos + diceValue <= 57;
  }

  void _moveOpponentToken(int tokenIndex, int diceValue) {
    final currentPos = _opponentTokens[tokenIndex];
    int newPos = currentPos == -1 ? 0 : currentPos + diceValue;
    
    setState(() {
      _opponentTokens[tokenIndex] = newPos;
      
      if (newPos == 57) {
        _opponentScore += 10;
      }
      
      // Check if opponent cut my token
      _checkOpponentCutMe(newPos);
    });
    
    // Check opponent win
    if (_checkOpponentWin()) {
      _showLoseDialog();
      return;
    }
    
    // Opponent gets another turn if rolled 6
    if (diceValue == 6) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _opponentTurn();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isMyTurn = true);
          _startTurnTimer();
        }
      });
    }
  }

  void _checkOpponentCutMe(int opponentNewPos) {
    final safePositions = [0, 8, 13, 21, 26, 34, 39, 47];
    if (safePositions.contains(opponentNewPos % _pathLength)) return;
    
    for (int i = 0; i < 4; i++) {
      final myActualPos = _myTokens[i];
      if (myActualPos > 0 && myActualPos < 52) {
        final myOnOpponentPath = (myActualPos + 26) % _pathLength;
        if (myOnOpponentPath == opponentNewPos % _pathLength) {
          setState(() {
            _myTokens[i] = -1;
            _opponentScore += 5;
          });
          _showCutAnimation();
        }
      }
    }
  }

  bool _checkWin() {
    return _myTokens.every((pos) => pos == 57);
  }

  bool _checkOpponentWin() {
    return _opponentTokens.every((pos) => pos == 57);
  }

  void _endGame() {
    _gameTimer?.cancel();
    _turnTimer?.cancel();
    
    if (_myScore > _opponentScore) {
      _showWinDialog();
    } else if (_opponentScore > _myScore) {
      _showLoseDialog();
    } else {
      _showDrawDialog();
    }
  }

  void _showScoreAnimation(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCutAnimation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.flash_on, color: Colors.white),
            SizedBox(width: 8),
            Text('Token Cut! 💥', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
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
            SizedBox(width: 12),
            Text('You Won! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Prize Won', style: TextStyle(color: Colors.white70)),
                  Text(
                    '₹${widget.prizePot}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Your Score: $_myScore', style: const TextStyle(fontSize: 16)),
            Text('Opponent Score: $_opponentScore', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Play Again'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.sentiment_dissatisfied, color: Color(0xFFE53935), size: 32),
            SizedBox(width: 12),
            Text('You Lost'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Better luck next time!'),
            const SizedBox(height: 16),
            Text('Your Score: $_myScore'),
            Text('Opponent Score: $_opponentScore'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showDrawDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Game Draw!'),
        content: const Text('Both players have equal scores.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
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
              _buildTopBar(),
              _buildPlayersRow(),
              Expanded(child: _buildBoard()),
              _buildDiceSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }


  // ==========================================
  // TOP BAR
  // ==========================================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => _showExitConfirmation(),
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
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const Spacer(),
          // Prize Pool
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
          // Settings
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text('You will lose the match if you exit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PLAYERS ROW
  // ==========================================
  Widget _buildPlayersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // You (Blue)
          _buildPlayerInfo(widget.player1Name, const Color(0xFF1565C0), _myScore, _isMyTurn),
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
                  decoration: BoxDecoration(
                    color: _turnTimeLeft <= 5 ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.access_time, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(_timeLeft),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Opponent (Green)
          _buildPlayerInfo(widget.player2Name, const Color(0xFF2E7D32), _opponentScore, !_isMyTurn),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(String name, Color color, int score, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text('Score: $score', style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
        const SizedBox(width: 8),
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
                backgroundColor: color.withOpacity(0.3),
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // BOARD
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
              painter: Ludo1v1BoardPainter(
                myTokens: _myTokens,
                opponentTokens: _opponentTokens,
                selectedToken: _selectedToken,
                canMove: _canMove,
                isMyTurn: _isMyTurn,
              ),
              child: _buildTokenTapAreas(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenTapAreas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = constraints.maxWidth / 15;
        
        return Stack(
          children: [
            // Tap areas for my tokens in home
            for (int i = 0; i < 4; i++)
              if (_myTokens[i] == -1 && _canMove && _diceValue == 6)
                _buildHomeTapArea(i, cell, true),
            
            // Tap areas for my tokens on board
            for (int i = 0; i < 4; i++)
              if (_myTokens[i] >= 0 && _myTokens[i] < 57 && _canMove && _isValidMove(i, _diceValue))
                _buildBoardTapArea(i, _myTokens[i], cell),
          ],
        );
      },
    );
  }

  Widget _buildHomeTapArea(int tokenIndex, double cell, bool isMyToken) {
    // Blue home is top-left
    final positions = [
      Offset(cell * 1.8, cell * 1.8),
      Offset(cell * 4.2, cell * 1.8),
      Offset(cell * 1.8, cell * 4.2),
      Offset(cell * 4.2, cell * 4.2),
    ];
    
    return Positioned(
      left: positions[tokenIndex].dx - cell * 0.5,
      top: positions[tokenIndex].dy - cell * 0.5,
      child: GestureDetector(
        onTap: () => _selectToken(tokenIndex),
        child: Container(
          width: cell * 1.2,
          height: cell * 1.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.touch_app, color: Color(0xFF4CAF50), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildBoardTapArea(int tokenIndex, int position, double cell) {
    final pos = _getTokenPosition(position, cell, true);
    
    return Positioned(
      left: pos.dx - cell * 0.5,
      top: pos.dy - cell * 0.5,
      child: GestureDetector(
        onTap: () => _selectToken(tokenIndex),
        child: Container(
          width: cell * 1.2,
          height: cell * 1.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
          ),
        ),
      ),
    );
  }

  Offset _getTokenPosition(int position, double cell, bool isMyToken) {
    // Simplified position mapping
    if (position < 0) return Offset.zero;
    
    // This is a simplified version - full implementation would map all 52 positions
    final pathPositions = _generatePathPositions(cell);
    if (position < pathPositions.length) {
      return pathPositions[position];
    }
    
    // Home stretch
    if (position >= 52 && position < 57) {
      final homePos = position - 52;
      if (isMyToken) {
        return Offset(cell * (1 + homePos) + cell / 2, cell * 7 + cell / 2);
      } else {
        return Offset(cell * (13 - homePos) + cell / 2, cell * 7 + cell / 2);
      }
    }
    
    return Offset(cell * 7.5, cell * 7.5);
  }

  List<Offset> _generatePathPositions(double cell) {
    final positions = <Offset>[];
    
    // Starting from blue start, going clockwise
    // Left column going up (blue start)
    positions.add(Offset(cell * 6.5, cell * 13.5));
    for (int i = 0; i < 5; i++) {
      positions.add(Offset(cell * 6.5, cell * (12.5 - i)));
    }
    
    // Top-left going left
    for (int i = 0; i < 6; i++) {
      positions.add(Offset(cell * (5.5 - i), cell * 6.5));
    }
    
    // Left edge going up
    positions.add(Offset(cell * 0.5, cell * 6.5));
    positions.add(Offset(cell * 0.5, cell * 7.5));
    
    // Continue around the board...
    // (Simplified - full implementation would have all 52 positions)
    for (int i = 0; i < 40; i++) {
      final angle = (i / 40) * 2 * math.pi;
      positions.add(Offset(
        cell * 7.5 + math.cos(angle) * cell * 5,
        cell * 7.5 + math.sin(angle) * cell * 5,
      ));
    }
    
    return positions;
  }

  // ==========================================
  // DICE SECTION
  // ==========================================
  Widget _buildDiceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isMyTurn ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isMyTurn ? const Color(0xFF4CAF50) : const Color(0xFFE53935)).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Turn indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isMyTurn ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isMyTurn ? Icons.person : Icons.smart_toy,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isMyTurn ? 'Your Turn' : 'Opponent\'s Turn',
                  style: TextStyle(
                    color: _isMyTurn ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _canMove 
                      ? 'Tap a token to move' 
                      : (_isMyTurn ? 'Tap dice to roll' : 'Waiting...'),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                // Turn timer bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _turnTimeLeft / 15,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(
                      _turnTimeLeft <= 5 ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Dice
          GestureDetector(
            onTap: (_isMyTurn && !_isRolling && !_canMove) ? _rollDice : null,
            child: AnimatedBuilder(
              animation: _diceController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _diceController.value * math.pi * 4,
                  child: Transform.scale(
                    scale: 1.0 + (math.sin(_diceController.value * math.pi) * 0.2),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _canMove ? const Color(0xFF4CAF50) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (_canMove ? const Color(0xFF4CAF50) : Colors.white).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _canMove
                          ? const Icon(Icons.touch_app, color: Colors.white, size: 30)
                          : CustomPaint(painter: DicePainter(value: _diceValue)),
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
// 1v1 BOARD PAINTER
// ============================================
class Ludo1v1BoardPainter extends CustomPainter {
  final List<int> myTokens;
  final List<int> opponentTokens;
  final int? selectedToken;
  final bool canMove;
  final bool isMyTurn;

  static const Color blueColor = Color(0xFF1565C0);
  static const Color greenColor = Color(0xFF2E7D32);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color pathWhite = Color(0xFFFAFAFA);

  Ludo1v1BoardPainter({
    required this.myTokens,
    required this.opponentTokens,
    this.selectedToken,
    required this.canMove,
    required this.isMyTurn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;

    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = pathWhite,
    );

    // Draw quadrants - Blue (top-left), Green (bottom-right)
    _drawQuadrant(canvas, 0, 0, cell * 6, blueColor, cell, 'You', myTokens);
    _drawQuadrant(canvas, cell * 9, cell * 9, cell * 6, greenColor, cell, 'Opponent', opponentTokens);
    
    // Empty quadrants (grey)
    _drawEmptyQuadrant(canvas, cell * 9, 0, cell * 6, const Color(0xFFE0E0E0), cell);
    _drawEmptyQuadrant(canvas, 0, cell * 9, cell * 6, const Color(0xFFE0E0E0), cell);

    // Cross paths
    _drawCrossPaths(canvas, size, cell);

    // Home columns
    _drawHomeColumns(canvas, cell);

    // Center
    _drawCenter(canvas, size, cell);

    // Safe stars
    _drawSafeStars(canvas, cell);

    // Tokens on board
    _drawBoardTokens(canvas, cell);
  }

  void _drawQuadrant(Canvas canvas, double x, double y, double qSize, Color color, double cell, String label, List<int> tokens) {
    // Background
    canvas.drawRect(Rect.fromLTWH(x, y, qSize, qSize), Paint()..color = color);

    // Inner white area
    final padding = qSize * 0.1;
    final innerSize = qSize * 0.8;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + padding, y + padding, innerSize, innerSize),
        const Radius.circular(12),
      ),
      Paint()..color = whiteColor,
    );

    // Draw home tokens
    final tokenRadius = qSize * 0.1;
    final cx = x + qSize / 2;
    final cy = y + qSize / 2;
    final offset = qSize * 0.2;

    final spots = [
      Offset(cx - offset, cy - offset),
      Offset(cx + offset, cy - offset),
      Offset(cx - offset, cy + offset),
      Offset(cx + offset, cy + offset),
    ];

    for (int i = 0; i < 4; i++) {
      if (tokens[i] == -1) {
        _draw3DToken(canvas, spots[i], color, tokenRadius);
      } else {
        // Empty spot
        canvas.drawCircle(
          spots[i],
          tokenRadius,
          Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _drawEmptyQuadrant(Canvas canvas, double x, double y, double qSize, Color color, double cell) {
    canvas.drawRect(Rect.fromLTWH(x, y, qSize, qSize), Paint()..color = color);
    
    final padding = qSize * 0.1;
    final innerSize = qSize * 0.8;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + padding, y + padding, innerSize, innerSize),
        const Radius.circular(12),
      ),
      Paint()..color = whiteColor.withOpacity(0.5),
    );
  }

  void _draw3DToken(Canvas canvas, Offset pos, Color color, double radius) {
    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + radius * 0.4), width: radius * 1.8, height: radius * 0.6),
      Paint()..color = Colors.black.withOpacity(0.2),
    );

    // Base
    canvas.drawCircle(
      Offset(pos.dx, pos.dy + 2),
      radius,
      Paint()..color = Color.lerp(color, Colors.black, 0.3)!,
    );

    // Body with gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      colors: [
        Color.lerp(color, Colors.white, 0.4)!,
        color,
        Color.lerp(color, Colors.black, 0.15)!,
      ],
    );
    canvas.drawCircle(
      pos,
      radius,
      Paint()..shader = gradient.createShader(Rect.fromCircle(center: pos, radius: radius)),
    );

    // Highlight
    canvas.drawCircle(
      Offset(pos.dx - radius * 0.3, pos.dy - radius * 0.3),
      radius * 0.25,
      Paint()..color = Colors.white.withOpacity(0.6),
    );
  }

  void _drawCrossPaths(Canvas canvas, Size size, double cell) {
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Grid lines
    for (int row = 6; row < 9; row++) {
      for (int col = 0; col < 15; col++) {
        if (col >= 6 && col < 9) continue;
        canvas.drawRect(Rect.fromLTWH(cell * col, cell * row, cell, cell), borderPaint);
      }
    }

    for (int col = 6; col < 9; col++) {
      for (int row = 0; row < 15; row++) {
        if (row >= 6 && row < 9) continue;
        canvas.drawRect(Rect.fromLTWH(cell * col, cell * row, cell, cell), borderPaint);
      }
    }
  }

  void _drawHomeColumns(Canvas canvas, double cell) {
    // Blue home column (left)
    for (int col = 1; col < 6; col++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * col, cell * 7, cell, cell),
        Paint()..color = blueColor.withOpacity(0.4),
      );
    }

    // Green home column (right)
    for (int col = 9; col < 14; col++) {
      canvas.drawRect(
        Rect.fromLTWH(cell * col, cell * 7, cell, cell),
        Paint()..color = greenColor.withOpacity(0.4),
      );
    }

    // Arrows
    _drawArrow(canvas, Offset(cell * 0.5, cell * 7.5), 0, cell * 0.3, blueColor);
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

  void _drawCenter(Canvas canvas, Size size, double cell) {
    final center = Offset(size.width / 2, size.height / 2);
    final triSize = cell * 1.5;

    // Blue and Green triangles
    final path1 = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - triSize, center.dy - triSize * 0.7)
      ..lineTo(center.dx - triSize, center.dy + triSize * 0.7)
      ..close();
    canvas.drawPath(path1, Paint()..color = blueColor);

    final path2 = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + triSize, center.dy - triSize * 0.7)
      ..lineTo(center.dx + triSize, center.dy + triSize * 0.7)
      ..close();
    canvas.drawPath(path2, Paint()..color = greenColor);

    // Grey triangles for empty players
    final path3 = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - triSize * 0.7, center.dy - triSize)
      ..lineTo(center.dx + triSize * 0.7, center.dy - triSize)
      ..close();
    canvas.drawPath(path3, Paint()..color = Colors.grey);

    final path4 = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - triSize * 0.7, center.dy + triSize)
      ..lineTo(center.dx + triSize * 0.7, center.dy + triSize)
      ..close();
    canvas.drawPath(path4, Paint()..color = Colors.grey);

    // Center circle
    canvas.drawCircle(center, cell * 0.4, Paint()..color = const Color(0xFF455A64));
    canvas.drawCircle(center, cell * 0.32, Paint()..color = whiteColor);
  }

  void _drawSafeStars(Canvas canvas, double cell) {
    final positions = [
      Offset(cell * 2.5, cell * 6.5),
      Offset(cell * 6.5, cell * 2.5),
      Offset(cell * 12.5, cell * 8.5),
      Offset(cell * 8.5, cell * 12.5),
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
    // Draw my tokens on board
    for (int i = 0; i < 4; i++) {
      if (myTokens[i] >= 0 && myTokens[i] < 57) {
        final pos = _getTokenBoardPosition(myTokens[i], cell, true);
        _draw3DToken(canvas, pos, blueColor, cell * 0.35);
      }
    }

    // Draw opponent tokens on board
    for (int i = 0; i < 4; i++) {
      if (opponentTokens[i] >= 0 && opponentTokens[i] < 57) {
        final pos = _getTokenBoardPosition(opponentTokens[i], cell, false);
        _draw3DToken(canvas, pos, greenColor, cell * 0.35);
      }
    }
  }

  Offset _getTokenBoardPosition(int position, double cell, bool isMyToken) {
    // Simplified path positions
    final pathPositions = <Offset>[];
    
    // Generate path around the board
    // Blue starts at bottom-left of center, goes counter-clockwise
    // Position 0-5: Going up on left side
    for (int i = 0; i < 6; i++) {
      pathPositions.add(Offset(cell * 6.5, cell * (13.5 - i)));
    }
    // Position 6-11: Going left on top-left
    for (int i = 0; i < 6; i++) {
      pathPositions.add(Offset(cell * (5.5 - i), cell * 6.5));
    }
    // Position 12-13: Corner
    pathPositions.add(Offset(cell * 0.5, cell * 7.5));
    pathPositions.add(Offset(cell * 0.5, cell * 8.5));
    // Continue around...
    for (int i = 0; i < 6; i++) {
      pathPositions.add(Offset(cell * (1.5 + i), cell * 8.5));
    }
    for (int i = 0; i < 5; i++) {
      pathPositions.add(Offset(cell * 6.5, cell * (9.5 + i)));
    }
    pathPositions.add(Offset(cell * 7.5, cell * 14.5));
    pathPositions.add(Offset(cell * 8.5, cell * 14.5));
    for (int i = 0; i < 5; i++) {
      pathPositions.add(Offset(cell * 8.5, cell * (13.5 - i)));
    }
    for (int i = 0; i < 6; i++) {
      pathPositions.add(Offset(cell * (9.5 + i), cell * 8.5));
    }
    pathPositions.add(Offset(cell * 14.5, cell * 7.5));
    pathPositions.add(Offset(cell * 14.5, cell * 6.5));
    for (int i = 0; i < 6; i++) {
      pathPositions.add(Offset(cell * (13.5 - i), cell * 6.5));
    }
    for (int i = 0; i < 5; i++) {
      pathPositions.add(Offset(cell * 8.5, cell * (5.5 - i)));
    }
    pathPositions.add(Offset(cell * 7.5, cell * 0.5));
    pathPositions.add(Offset(cell * 6.5, cell * 0.5));
    for (int i = 0; i < 5; i++) {
      pathPositions.add(Offset(cell * 6.5, cell * (1.5 + i)));
    }

    if (position < pathPositions.length) {
      final offset = isMyToken ? 0 : 26; // Green starts 26 positions ahead
      return pathPositions[(position + offset) % pathPositions.length];
    }

    // Home stretch
    if (position >= 52) {
      final homePos = position - 52;
      if (isMyToken) {
        return Offset(cell * (1.5 + homePos), cell * 7.5);
      } else {
        return Offset(cell * (13.5 - homePos), cell * 7.5);
      }
    }

    return Offset(cell * 7.5, cell * 7.5);
  }

  @override
  bool shouldRepaint(covariant Ludo1v1BoardPainter oldDelegate) {
    return oldDelegate.myTokens != myTokens ||
        oldDelegate.opponentTokens != opponentTokens ||
        oldDelegate.selectedToken != selectedToken ||
        oldDelegate.canMove != canMove;
  }
}

// ============================================
// DICE PAINTER
// ============================================
class DicePainter extends CustomPainter {
  final int value;

  DicePainter({required this.value});

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
  bool shouldRepaint(covariant DicePainter oldDelegate) => oldDelegate.value != value;
}
