import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

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
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _blinkAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Gentle floating animation (subtle up/down)
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Glow pulsing animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startBlinking();
    _startFloating();
    _startGlowing();
    _startAccelerometer();
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (mounted) {
          setState(() {
            _tiltX = (event.x / 10).clamp(-1.0, 1.0);
            _tiltY = (event.y / 10).clamp(-1.0, 1.0);
          });
        }
      },
      onError: (error) {},
    );
  }

  void _startBlinking() {
    Future.delayed(Duration(seconds: 2 + math.Random().nextInt(3)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  void _startFloating() {
    if (mounted) {
      _floatController.repeat(reverse: true);
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
    _floatController.dispose();
    _glowController.dispose();
    _accelerometerSubscription?.cancel();
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
          _floatAnimation,
          _glowAnimation,
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
              
              // Main avatar with realistic 3D movement
              Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Add 3D perspective
                    ..rotateY(math.sin(_floatAnimation.value * 0.5) * 0.2) // Look left/right naturally
                    ..rotateX(math.cos(_floatAnimation.value * 0.3) * 0.15), // Nod up/down naturally
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
                        // Purple glow
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.6 * _glowAnimation.value),
                          blurRadius: 25,
                          spreadRadius: 4,
                        ),
                        // 3D drop shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(
                            math.sin(_floatAnimation.value * 0.5) * 5,
                            5 + math.cos(_floatAnimation.value * 0.3) * 3,
                          ),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Eyes with 3D positioning
                          Positioned(
                            top: widget.size * 0.3,
                            left: widget.size * 0.2 + (math.sin(_floatAnimation.value * 0.5) * widget.size * 0.05),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Left eye
                                Transform.scale(
                                  scale: 1.0 - (math.sin(_floatAnimation.value * 0.5).abs() * 0.1),
                                  child: Container(
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
                                          color: const Color(0xFF8B5CF6).withOpacity(0.7),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: widget.size * 0.15),
                                // Right eye
                                Transform.scale(
                                  scale: 1.0 - (math.sin(_floatAnimation.value * 0.5).abs() * 0.1),
                                  child: Container(
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
                                          color: const Color(0xFF8B5CF6).withOpacity(0.7),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
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
