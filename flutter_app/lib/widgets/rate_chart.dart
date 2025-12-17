import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

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
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  List<FlSpot> _spots = [];
  double _minY = 0;
  double _maxY = 0;
  double _percentChange = 0;
  
  @override
  void initState() {
    super.initState();
    _generateChartData();
    
    // Main chart animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    // Shimmer effect for the gradient
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    
    // Pulse effect for the badge
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _generateChartData() {
    // Generate realistic looking rate fluctuation data for the last 24 hours
    final random = math.Random(42); // Fixed seed for consistent data
    final baseRate = widget.currentRate;
    final spots = <FlSpot>[];
    
    // Generate 24 data points (hourly) with more realistic patterns
    double previousRate = baseRate * 0.998; // Start slightly lower
    for (int i = 0; i < 24; i++) {
      // Create realistic fluctuation with momentum
      final momentum = (random.nextDouble() - 0.5) * 0.003 * baseRate;
      final meanReversion = (baseRate - previousRate) * 0.1;
      final rate = previousRate + momentum + meanReversion;
      spots.add(FlSpot(i.toDouble(), rate));
      previousRate = rate;
    }
    
    // Calculate min and max for Y axis
    final rates = spots.map((spot) => spot.y).toList();
    _minY = rates.reduce(math.min) * 0.9995;
    _maxY = rates.reduce(math.max) * 1.0005;
    
    // Calculate percent change
    final firstRate = spots.first.y;
    final lastRate = spots.last.y;
    _percentChange = ((lastRate - firstRate) / firstRate) * 100;
    
    setState(() {
      _spots = spots;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_spots.isEmpty) {
      return SizedBox(
        height: 260,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    
    final isPositive = _percentChange >= 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _shimmerAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF8FAFC),
                const Color(0xFFF1F5F9),
                const Color(0xFFE0E7FF),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Animated shimmer background
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: CustomPaint(
                      painter: ShimmerPainter(
                        animation: _shimmerAnimation.value,
                      ),
                    ),
                  ),
                ),
                
                // Main content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF6366F1).withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.auto_graph_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Exchange Rate',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Live 24h Trend',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Animated badge - More Eye-Catching
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isPositive
                                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                      : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                        .withOpacity(0.5),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                  BoxShadow(
                                    color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                        .withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '₹${(widget.currentRate * 100).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text(
                                        'per 100 BDT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Chart
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: (_maxY - _minY) / 4,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 6,
                                  getTitlesWidget: (value, meta) {
                                    final style = TextStyle(
                                      fontSize: 10,
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                    );
                                    if (value == 0) return Text('Now', style: style);
                                    if (value == 6) return Text('6h', style: style);
                                    if (value == 12) return Text('12h', style: style);
                                    if (value == 18) return Text('18h', style: style);
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  interval: (_maxY - _minY) / 4,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Text(
                                        (value * 100).toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: 23,
                            minY: _minY,
                            maxY: _maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _spots.map((spot) {
                                  return FlSpot(
                                    spot.x,
                                    _minY + (spot.y - _minY) * _animation.value,
                                  );
                                }).toList(),
                                isCurved: true,
                                curveSmoothness: 0.45,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF8B5CF6),
                                    const Color(0xFFA855F7),
                                    isPositive ? const Color(0xFF10B981) : const Color(0xFFEC4899),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    // Show dot only on last point
                                    if (index == _spots.length - 1) {
                                      return FlDotCirclePainter(
                                        radius: 5,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        strokeColor: isPositive ? const Color(0xFF10B981) : const Color(0xFFEC4899),
                                      );
                                    }
                                    return FlDotCirclePainter(
                                      radius: 0,
                                      color: Colors.transparent,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF6366F1).withOpacity(0.35 * _animation.value),
                                      const Color(0xFF8B5CF6).withOpacity(0.25 * _animation.value),
                                      const Color(0xFFA855F7).withOpacity(0.15 * _animation.value),
                                      const Color(0xFFA855F7).withOpacity(0.0),
                                    ],
                                  ),
                                ),
                                shadow: const Shadow(
                                  color: Color(0xFF6366F1),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: isDark ? colorScheme.surface : const Color(0xFF1E293B),
                                tooltipRoundedRadius: 12,
                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    final hoursAgo = (23 - barSpot.x).toInt();
                                    return LineTooltipItem(
                                      '₹${(barSpot.y * 100).toStringAsFixed(2)}\n',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: hoursAgo == 0 ? 'Now • per 100 BDT' : '${hoursAgo}h ago • per 100 BDT',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                              ),
                              handleBuiltInTouches: true,
                              getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                                return spotIndexes.map((spotIndex) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: colorScheme.primary.withOpacity(0.4),
                                      strokeWidth: 2.5,
                                      dashArray: [6, 4],
                                    ),
                                    FlDotData(
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 7,
                                          color: isDark ? colorScheme.surface : Colors.white,
                                          strokeWidth: 3.5,
                                          strokeColor: colorScheme.primary,
                                        );
                                      },
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.linear,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for shimmer effect
class ShimmerPainter extends CustomPainter {
  final double animation;
  
  ShimmerPainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF6366F1).withOpacity(0.0),
          const Color(0xFF6366F1).withOpacity(0.05),
          const Color(0xFF8B5CF6).withOpacity(0.05),
          const Color(0xFFA855F7).withOpacity(0.0),
        ],
        stops: [
          (animation - 0.3).clamp(0.0, 1.0),
          (animation - 0.1).clamp(0.0, 1.0),
          (animation + 0.1).clamp(0.0, 1.0),
          (animation + 0.3).clamp(0.0, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
  
  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) => animation != oldDelegate.animation;
}
