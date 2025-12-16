import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class ProfessionalLudoBoard extends StatefulWidget {
  final String opponentName;
  final String betAmount;
  final String gameMode;

  const ProfessionalLudoBoard({
    super.key,
    required this.opponentName,
    required this.betAmount,
    required this.gameMode,
  });

  @override
  State<ProfessionalLudoBoard> createState() => _ProfessionalLudoBoardState();
}

class _ProfessionalLudoBoardState extends State<ProfessionalLudoBoard>
    with TickerProviderStateMixin {
  int _diceValue = 1;
  bool _isRolling = false;
  bool _isMyTurn = true;
  int _myPosition = -1;
  int _opponentPosition = -1;
  bool _canMove = false;
  int _timeLeft = 15;
  Timer? _turnTimer;
  late AnimationController _diceController;
  late AnimationController _tokenController;
  late AnimationController _pulseController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgMusicPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _tokenController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
