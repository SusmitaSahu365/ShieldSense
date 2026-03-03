// lib/widgets/psi_gauge.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/risk_model.dart';

class PSIGauge extends StatefulWidget {
  final double psi; // 0.0 to 1.0
  final RiskLevel level;
  final bool isAnimating;

  const PSIGauge({
    super.key,
    required this.psi,
    required this.level,
    this.isAnimating = true,
  });

  @override
  State<PSIGauge> createState() => _PSIGaugeState();
}

class _PSIGaugeState extends State<PSIGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.level.colorValue);
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _GaugePainter(
              psi: widget.psi,
              color: color,
              pulseScale: widget.level.index >= 3 ? _pulseAnim.value : 1.0,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: widget.psi),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (_, v, __) => Text(
                      '${(v * 100).round()}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                  Text(
                    'PSI SCORE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(
                      widget.level.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double psi;
  final Color color;
  final double pulseScale;

  _GaugePainter({
    required this.psi,
    required this.color,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // Glow ring
    if (pulseScale > 0.9) {
      final glowPaint = Paint()
        ..color = color.withOpacity((pulseScale - 0.85) * 2 * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        _degToRad(135),
        _degToRad(270 * psi),
        false,
        glowPaint,
      );
    }

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      _degToRad(135),
      _degToRad(270),
      false,
      trackPaint,
    );

    // Gradient fill
    if (psi > 0) {
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
      final gradient = SweepGradient(
        startAngle: _degToRad(135),
        endAngle: _degToRad(135 + 270),
        colors: [
          const Color(0xFF00E5A0),
          const Color(0xFF8BC34A),
          const Color(0xFFFFD166),
          const Color(0xFFFF9F1C),
          const Color(0xFFFF3366),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        tileMode: TileMode.clamp,
        transform: const GradientRotation(0),
      );

      final fillPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        _degToRad(135),
        _degToRad(270 * psi),
        false,
        fillPaint,
      );
    }

    // Inner ring decoration
    final innerPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), r * 0.82, innerPaint);

    // Needle tip dot
    final angle = _degToRad(135 + 270 * psi);
    final tipX = cx + r * cos(angle);
    final tipY = cy + r * sin(angle);
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(tipX, tipY), 5, dotPaint);
  }

  double _degToRad(double deg) => deg * pi / 180;

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.psi != psi || old.color != color || old.pulseScale != pulseScale;
}
