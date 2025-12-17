import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedAvatar extends StatefulWidget {
  final double size;
  final String? userName;

  const AnimatedAvatar({
    super.key,
    required this.size,
    this.userName,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _glowController;
  late AnimationController _breatheController;
  late AnimationController _lookAroundController;
  late AnimationController _eyeMovementController;
  
  late Animation<double> _blinkAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _lookAroundAnimation;
  late Animation<double> _eyeMovementAnimation;



  @override
  void initState() {
    super.initState();

    // Blinking animation - natural eye blinks
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.1).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Glow pulsing animation - subtle breathing glow
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Breathing animation - subtle size changes
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // Look around animation - subtle head movements
    _lookAroundController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );
    _lookAroundAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _lookAroundController, curve: Curves.easeInOut),
    );

    // Eye movement animation - pupils looking around
    _eyeMovementController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _eyeMovementAnimation = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(parent: _eyeMovementController, curve: Curves.easeInOut),
    );

    _startRealisticAnimations();
  }



  void _startRealisticAnimations() {
    // Start all realistic animations
    _startBlinking();
    _startBreathing();
    _startLookingAround();
    _startEyeMovement();
    _startGlowing();
  }

  void _startBlinking() {
    // Random blink intervals (2-6 seconds) - more human-like
    final nextBlink = 2000 + math.Random().nextInt(4000);
    Future.delayed(Duration(milliseconds: nextBlink), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 50), () {
            _blinkController.reverse().then((_) {
              _startBlinking();
            });
          });
        });
      }
    });
  }

  void _startBreathing() {
    if (mounted) {
      _breatheController.repeat(reverse: true);
    }
  }

  void _startLookingAround() {
    if (mounted) {
      _lookAroundController.repeat(reverse: true);
    }
  }

  void _startEyeMovement() {
    if (mounted) {
      _eyeMovementController.repeat(reverse: true);
    }
  }

  void _startGlowing() {
    if (mounted) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _glowController.dispose();
    _breatheController.dispose();
    _lookAroundController.dispose();
    _eyeMovementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _blinkAnimation,
          _glowAnimation,
          _breatheAnimation,
          _lookAroundAnimation,
          _eyeMovementAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Large outer glow rings (screen glow effect)
              ...List.generate(4, (i) {
                final scale = 1.3 + (i * 0.3 * _glowAnimation.value);
                return Positioned(
                  child: Container(
                    width: widget.size * scale,
                    height: widget.size * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.5 * _glowAnimation.value / (i + 1)),
                          const Color(0xFF7C3AED).withOpacity(0.4 * _glowAnimation.value / (i + 1)),
                          const Color(0xFF6366F1).withOpacity(0.2 * _glowAnimation.value / (i + 1)),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                );
              }),
              
              // Purple glowing ring around avatar
              Positioned(
                child: Container(
                  width: widget.size * 1.2,
                  height: widget.size * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.8 * _glowAnimation.value),
                      width: widget.size * 0.08,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.7 * _glowAnimation.value),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Main avatar with realistic movements
              Transform.scale(
                scale: _breatheAnimation.value, // Subtle breathing
                child: Transform.rotate(
                  angle: _lookAroundAnimation.value, // Subtle head tilt
                  child: Container(
                    width: widget.size * 0.85,
                    height: widget.size * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Pure white - no gradients
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: widget.size * 0.05,
                      ),
                      boxShadow: [
                        // Purple glow that pulses with breathing
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.6 * _glowAnimation.value),
                          blurRadius: 25 * _breatheAnimation.value,
                          spreadRadius: 4 * _breatheAnimation.value,
                        ),
                        // Dynamic shadow that moves with head tilt
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(
                            _lookAroundAnimation.value * 10,
                            5 + (_lookAroundAnimation.value.abs() * 3),
                          ),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Eyes with realistic movement
                          Positioned(
                            top: widget.size * 0.3,
                            left: widget.size * 0.2 + (_eyeMovementAnimation.value * widget.size * 0.02),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Left eye with pupil movement
                                Container(
                                  width: widget.size * 0.12,
                                  height: widget.size * 0.2 * _blinkAnimation.value,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF9333EA),
                                        Color(0xFF7C3AED),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withOpacity(0.7 * _glowAnimation.value),
                                        blurRadius: 8 * _breatheAnimation.value,
                                        spreadRadius: 2 * _breatheAnimation.value,
                                      ),
                                    ],
                                  ),
                                  child: _blinkAnimation.value > 0.3 ? Center(
                                    child: Transform.translate(
                                      offset: Offset(_eyeMovementAnimation.value * 2, 0),
                                      child: Container(
                                        width: widget.size * 0.04,
                                        height: widget.size * 0.08 * _blinkAnimation.value,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                      ),
                                    ),
                                  ) : null,
                                ),
                                SizedBox(width: widget.size * 0.15),
                                // Right eye with pupil movement
                                Container(
                                  width: widget.size * 0.12,
                                  height: widget.size * 0.2 * _blinkAnimation.value,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF9333EA),
                                        Color(0xFF7C3AED),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withOpacity(0.7 * _glowAnimation.value),
                                        blurRadius: 8 * _breatheAnimation.value,
                                        spreadRadius: 2 * _breatheAnimation.value,
                                      ),
                                    ],
                                  ),
                                  child: _blinkAnimation.value > 0.3 ? Center(
                                    child: Transform.translate(
                                      offset: Offset(_eyeMovementAnimation.value * 2, 0),
                                      child: Container(
                                        width: widget.size * 0.04,
                                        height: widget.size * 0.08 * _blinkAnimation.value,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                      ),
                                    ),
                                  ) : null,
                                ),
                              ],
                            ),
                          ),
                          

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
