import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Cinematic Logo-Inspired Hero Animation
/// 1. Globe appears with subtle scale & pulse
/// 2. Gold flight path draws smoothly along a Bézier trajectory
/// 3. Gold airplane glides smoothly along the path
/// 4. Subtle stardust particles floating around
class HeroFlightAnimation extends StatefulWidget {
  final double size;
  const HeroFlightAnimation({super.key, this.size = 380});

  @override
  State<HeroFlightAnimation> createState() => _HeroFlightAnimationState();
}

class _HeroFlightAnimationState extends State<HeroFlightAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _flightController;
  late final AnimationController _globeController;
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // Globe scale and gentle floating
    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Flight path and airplane travel loop
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();

    // Stardust floating particles loop
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _flightController.dispose();
    _globeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _flightController,
          _globeController,
          _particleController,
        ]),
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _HeroFlightPainter(
              flightProgress: _flightController.value,
              globePulse: _globeController.value,
              particleProgress: _particleController.value,
            ),
          );
        },
      ),
    );
  }
}

class _HeroFlightPainter extends CustomPainter {
  final double flightProgress;
  final double globePulse;
  final double particleProgress;

  _HeroFlightPainter({
    required this.flightProgress,
    required this.globePulse,
    required this.particleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.46, size.height * 0.52);
    final globeRadius = size.width * 0.26 + (globePulse * 3.0);

    // ── 1. Globe Ambient Glow ──────────────────────────────────────────────
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        globeRadius * 1.5,
        [
          AppColors.royalBlue.withValues(alpha: 0.35),
          AppColors.royalBlueLight.withValues(alpha: 0.1),
          Colors.transparent,
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawCircle(center, globeRadius * 1.45, glowPaint);

    // ── 2. Globe Sphere (Deep Navy Gradient) ────────────────────────────────
    final globePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(center.dx - globeRadius * 0.35, center.dy - globeRadius * 0.35),
        globeRadius * 1.3,
        [
          const Color(0xFF1E3A6E),
          const Color(0xFF0F2347),
          const Color(0xFF071224),
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawCircle(center, globeRadius, globePaint);

    // Globe Rim Light / Border
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = ui.Gradient.linear(
        Offset(center.dx - globeRadius, center.dy - globeRadius),
        Offset(center.dx + globeRadius, center.dy + globeRadius),
        [
          AppColors.gold.withValues(alpha: 0.8),
          AppColors.royalBlueLight.withValues(alpha: 0.6),
          AppColors.royalBlueDark.withValues(alpha: 0.1),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, globeRadius, rimPaint);

    // ── 3. Stylized Latitude & Longitude Arcs ───────────────────────────────
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = AppColors.royalBlueLight.withValues(alpha: 0.22);

    // Equator & parallels
    canvas.drawOval(
      Rect.fromCenter(center: center, width: globeRadius * 1.9, height: globeRadius * 0.7),
      gridPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - globeRadius * 0.4),
        width: globeRadius * 1.6,
        height: globeRadius * 0.45,
      ),
      gridPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + globeRadius * 0.4),
        width: globeRadius * 1.6,
        height: globeRadius * 0.45,
      ),
      gridPaint,
    );

    // Meridians
    canvas.drawOval(
      Rect.fromCenter(center: center, width: globeRadius * 0.8, height: globeRadius * 1.95),
      gridPaint,
    );

    // ── 4. Golden Flight Path (Bézier Trajectory) ───────────────────────────
    final p0 = Offset(size.width * 0.08, size.height * 0.78);
    final p1 = Offset(size.width * 0.28, size.height * 0.15);
    final p2 = Offset(size.width * 0.72, size.height * 0.25);
    final p3 = Offset(size.width * 0.92, size.height * 0.68);

    final fullPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    final pathMetrics = fullPath.computeMetrics().toList();
    if (pathMetrics.isNotEmpty) {
      final metric = pathMetrics.first;
      final totalLength = metric.length;
      final currentLength = totalLength * flightProgress.clamp(0.0, 1.0);

      final animatedPath = metric.extractPath(0.0, currentLength);

      // Outer glow for gold path
      final pathGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..color = AppColors.gold.withValues(alpha: 0.25);
      canvas.drawPath(animatedPath, pathGlowPaint);

      // Core crisp gold dashed/solid line
      final pathPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          p0,
          p3,
          [
            AppColors.goldLight.withValues(alpha: 0.2),
            AppColors.gold,
            AppColors.goldLight,
          ],
          [0.0, 0.7, 1.0],
        );
      canvas.drawPath(animatedPath, pathPaint);

      // ── 5. Golden Airplane & Vapor Trail ──────────────────────────────────
      if (currentLength > 2.0) {
        final tangent = metric.getTangentForOffset(currentLength);
        if (tangent != null) {
          final planePos = tangent.position;
          final angle = tangent.angle;

          // Airplane glow pulse
          final planeGlow = Paint()
            ..shader = ui.Gradient.radial(
              planePos,
              22.0,
              [
                AppColors.gold.withValues(alpha: 0.7),
                AppColors.goldLight.withValues(alpha: 0.2),
                Colors.transparent,
              ],
              [0.0, 0.5, 1.0],
            );
          canvas.drawCircle(planePos, 22.0, planeGlow);

          // Draw oriented Airplane
          canvas.save();
          canvas.translate(planePos.dx, planePos.dy);
          canvas.rotate(angle);

          _drawAirplane(canvas);

          canvas.restore();
        }
      }
    }

    // ── 6. Floating Gold Stardust Particles ─────────────────────────────────
    final random = math.Random(42);
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 16; i++) {
      final px0 = size.width * (0.15 + random.nextDouble() * 0.7);
      final py0 = size.height * (0.15 + random.nextDouble() * 0.7);
      final pRadius = 1.0 + random.nextDouble() * 2.0;

      final pOffset = math.sin((particleProgress * math.pi * 2) + i) * 6.0;
      final alpha = (0.3 + 0.5 * math.sin((particleProgress * math.pi * 2) + i * 2)).clamp(0.0, 1.0);

      particlePaint.color = AppColors.goldLight.withValues(alpha: alpha);
      canvas.drawCircle(Offset(px0, py0 + pOffset), pRadius, particlePaint);
    }
  }

  void _drawAirplane(Canvas canvas) {
    final planeBodyPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final planeGoldPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    // Fuselage
    final fuselage = Path()
      ..moveTo(14, 0)
      ..lineTo(-8, -3.5)
      ..lineTo(-12, 0)
      ..lineTo(-8, 3.5)
      ..close();
    canvas.drawPath(fuselage, planeBodyPaint);

    // Main Wings
    final wings = Path()
      ..moveTo(2, 0)
      ..lineTo(-5, -16)
      ..lineTo(-8, -16)
      ..lineTo(-3, 0)
      ..lineTo(-8, 16)
      ..lineTo(-5, 16)
      ..close();
    canvas.drawPath(wings, planeGoldPaint);

    // Tail Fin
    final tail = Path()
      ..moveTo(-9, 0)
      ..lineTo(-14, -7)
      ..lineTo(-16, -7)
      ..lineTo(-13, 0)
      ..lineTo(-16, 7)
      ..lineTo(-14, 7)
      ..close();
    canvas.drawPath(tail, planeGoldPaint);

    // Cabin highlight
    final noseTip = Paint()..color = AppColors.goldLight;
    canvas.drawCircle(const Offset(11, 0), 2.0, noseTip);
  }

  @override
  bool shouldRepaint(covariant _HeroFlightPainter oldDelegate) {
    return oldDelegate.flightProgress != flightProgress ||
        oldDelegate.globePulse != globePulse ||
        oldDelegate.particleProgress != particleProgress;
  }
}
