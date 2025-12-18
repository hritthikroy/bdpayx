import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';

class RateChart extends StatefulWidget {
  final double currentRate;

  const RateChart({
    super.key,
    required this.currentRate,
  });

  @override
  State<RateChart> createState() => _RateChartState();
}

class _RateChartState extends State<RateChart> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  List<double> _rates = [];
  Timer? _refreshTimer;
  Timer? _countdownTimer;
  Timer? _liveUpdateTimer;
  bool _isLoading = true;
  int _liveSeconds = 50;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _fetchRateHistory();

    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchRateHistory();
      setState(() => _liveSeconds = 50);
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _liveSeconds > 0) {
        setState(() => _liveSeconds--);
      }
    });

    _liveUpdateTimer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      if (mounted && _rates.isNotEmpty) {
        _addLiveMicroUpdate();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    _liveUpdateTimer?.cancel();
    super.dispose();
  }

  void _addLiveMicroUpdate() {
    if (_rates.isEmpty) return;

    final random = math.Random();
    final lastRate = _rates.last;
    final microChange = (random.nextDouble() - 0.5) * 0.04;
    final newRate = lastRate + microChange;

    setState(() {
      _rates = [..._rates.skip(1), newRate];
    });
  }

  Future<void> _fetchRateHistory() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.rateHistory))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final history = data['history'] as List;
        if (history.isEmpty) {
          _generateChartData();
          return;
        }
        final rates = <double>[];
        for (final entry in history) {
          rates.add(double.parse(entry['rate'].toString()) * 100);
        }
        setState(() {
          _rates = rates;
          _isLoading = false;
        });
      } else {
        _generateChartData();
      }
    } catch (e) {
      _generateChartData();
    }
  }

  void _generateChartData() {
    final baseRate = widget.currentRate * 100;
    final rates = <double>[];
    final random = math.Random();

    for (int i = 0; i < 20; i++) {
      final wave = math.sin(i * 0.35) * 0.12;
      final noise = (random.nextDouble() - 0.5) * 0.05;
      rates.add(baseRate + wave + noise);
    }

    setState(() {
      _rates = rates;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _rates.isEmpty) {
      return _buildLoading();
    }

    final minRate = _rates.reduce(math.min);
    final maxRate = _rates.reduce(math.max);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹ ${(widget.currentRate * 100).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '/100 BDT',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLiveBadge(),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 90,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_pulseController, _shimmerController]),
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(constraints.maxWidth - 50, constraints.maxHeight),
                            painter: _ChartPainter(
                              rates: _rates,
                              minRate: minRate,
                              maxRate: maxRate,
                              pulseValue: _pulseController.value,
                              shimmerValue: _shimmerController.value,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          maxRate.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          minRate.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFF10B981).withOpacity(0.12),
              const Color(0xFF10B981).withOpacity(0.18),
              _pulseController.value,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.4 + (_pulseController.value * 0.3)),
                      blurRadius: 4 + (_pulseController.value * 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE • ${_liveSeconds}s',
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> rates;
  final double minRate;
  final double maxRate;
  final double pulseValue;
  final double shimmerValue;

  _ChartPainter({
    required this.rates,
    required this.minRate,
    required this.maxRate,
    required this.pulseValue,
    required this.shimmerValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rates.isEmpty || size.width <= 0 || size.height <= 0) return;

    final range = maxRate - minRate;
    final effectiveRange = range == 0 ? 1.0 : range;
    const padding = 8.0;

    // Build points
    final points = <Offset>[];
    for (int i = 0; i < rates.length; i++) {
      final x = (i / (rates.length - 1)) * size.width;
      final normalizedY = (rates[i] - minRate) / effectiveRange;
      final y = padding + (1 - normalizedY) * (size.height - padding * 2);
      points.add(Offset(x, y.clamp(padding, size.height - padding)));
    }

    // Create ultra-smooth artistic bezier path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      // Smoother control points for artistic curves (factor of 4 instead of 6)
      final cp1x = p1.dx + (p2.dx - p0.dx) / 4;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 4;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 4;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 4;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Rich gradient fill like demo - more detailed and prominent
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF6366F1).withOpacity(0.35),
        const Color(0xFF8B5CF6).withOpacity(0.25),
        const Color(0xFFA855F7).withOpacity(0.15),
        const Color(0xFF6366F1).withOpacity(0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
    );

    canvas.drawPath(
      fillPath,
      Paint()..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Subtle shadow for depth
    final shadowPath = path.shift(const Offset(0, 2));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = const Color(0xFF6366F1).withOpacity(0.12)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Subtle glow layer - like demo
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6366F1).withOpacity(0.4)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );

    // Main line - clean and defined
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6366F1)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dot at end
    final lastPt = points.last;
    final pulseSize = 10 + (pulseValue * 4);

    // Shadow for dot
    canvas.drawCircle(
      Offset(lastPt.dx, lastPt.dy + 2),
      5,
      Paint()
        ..color = const Color(0xFF6366F1).withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Outer pulse ring
    canvas.drawCircle(
      lastPt,
      pulseSize,
      Paint()..color = const Color(0xFF6366F1).withOpacity(0.12 - (pulseValue * 0.06)),
    );

    // White center
    canvas.drawCircle(lastPt, 5, Paint()..color = Colors.white);

    // Purple border
    canvas.drawCircle(
      lastPt,
      5,
      Paint()
        ..color = const Color(0xFF6366F1)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.rates != rates || old.pulseValue != pulseValue || old.shimmerValue != shimmerValue;
}
