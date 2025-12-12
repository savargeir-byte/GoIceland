import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Premium hero weather banner with animated aurora gradient background,
/// glass morphism, and decorative wave shapes.
class PremiumWeatherBanner extends StatefulWidget {
  const PremiumWeatherBanner({
    super.key,
    required this.temperature,
    required this.description,
    this.location = 'Reykjavík',
    this.onRefresh,
  });

  final double temperature;
  final String description;
  final String location;
  final VoidCallback? onRefresh;

  @override
  State<PremiumWeatherBanner> createState() => _PremiumWeatherBannerState();
}

class _PremiumWeatherBannerState extends State<PremiumWeatherBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _waveAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF00D4AA), Color(0xFF6B5CE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated aurora waves
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AuroraWavePainter(
                    wavePhase: _waveAnimation.value,
                  ),
                );
              },
            ),
          ),
          // Noise texture overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                painter: _NoisePainter(),
              ),
            ),
          ),
          // Glass content card
          Positioned(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.location,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      if (widget.onRefresh != null)
                        IconButton(
                          icon: const Icon(Icons.refresh,
                              color: Colors.white, size: 20),
                          onPressed: widget.onRefresh,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${widget.temperature.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuroraWavePainter extends CustomPainter {
  _AuroraWavePainter({required this.wavePhase});

  final double wavePhase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.1);

    final path = Path();
    const waveHeight = 30.0;
    const waveWidth = 150.0;

    path.moveTo(0, size.height * 0.6);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.6 +
          math.sin((x / waveWidth) * 2 * math.pi + wavePhase) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.05);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.7 +
          math.sin((x / waveWidth) * 2 * math.pi + wavePhase + math.pi / 2) *
              waveHeight *
              0.8;
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_AuroraWavePainter oldDelegate) =>
      oldDelegate.wavePhase != wavePhase;
}

class _NoisePainter extends CustomPainter {
  final _random = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < 800; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final opacity = _random.nextDouble() * 0.6;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
