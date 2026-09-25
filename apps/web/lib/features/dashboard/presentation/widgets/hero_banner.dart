import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  int _index = 0;

  static const _slides = [
    'KEEP UP WITH YOUR BUSINESS NEEDS',
    'SHIP FASTER ACROSS 300+ COUNTRIES',
    'TRACK EVERY PARCEL IN REAL TIME',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.navyBanner,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _StripePainter())),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 20, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _slides[_index],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                              height: 1.2,
                              letterSpacing: 0.3,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const SizedBox(
                      width: 160,
                      height: 130,
                      child: CustomPaint(painter: _ParcelGlobePainter()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final active = i == _index;
            return GestureDetector(
              onTap: () => setState(() => _index = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 10 : 8,
                height: active ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.navy : AppColors.border,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StripePainter extends CustomPainter {
  const _StripePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    for (var i = -size.height.toInt(); i < size.width.toInt() + size.height.toInt(); i += 36) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ParcelGlobePainter extends CustomPainter {
  const _ParcelGlobePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.55;
    final cy = size.height * 0.48;
    final r = size.width * 0.28;

    final globePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4ADE80).withValues(alpha: 0.85),
          const Color(0xFF166534),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, globePaint);

    final latPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = -2; i <= 2; i++) {
      final rect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: r * 2,
        height: r * (0.35 + i.abs() * 0.2),
      );
      canvas.drawOval(rect.shift(Offset(0, i * 8.0)), latPaint);
    }
    canvas.drawCircle(Offset(cx, cy), r, latPaint);

    void drawBox(Offset origin, double w, double h, Color color) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy + h * 0.25)
        ..lineTo(origin.dx + w * 0.5, origin.dy)
        ..lineTo(origin.dx + w, origin.dy + h * 0.25)
        ..lineTo(origin.dx + w * 0.5, origin.dy + h * 0.5)
        ..close();
      canvas.drawPath(path, Paint()..color = color);

      final front = Path()
        ..moveTo(origin.dx, origin.dy + h * 0.25)
        ..lineTo(origin.dx + w * 0.5, origin.dy + h * 0.5)
        ..lineTo(origin.dx + w * 0.5, origin.dy + h)
        ..lineTo(origin.dx, origin.dy + h * 0.75)
        ..close();
      canvas.drawPath(
        front,
        Paint()..color = Color.lerp(color, Colors.black, 0.15)!,
      );

      final side = Path()
        ..moveTo(origin.dx + w * 0.5, origin.dy + h * 0.5)
        ..lineTo(origin.dx + w, origin.dy + h * 0.25)
        ..lineTo(origin.dx + w, origin.dy + h * 0.75)
        ..lineTo(origin.dx + w * 0.5, origin.dy + h)
        ..close();
      canvas.drawPath(
        side,
        Paint()..color = Color.lerp(color, Colors.black, 0.28)!,
      );
    }

    drawBox(Offset(8, size.height * 0.42), 46, 52, const Color(0xFFD4A574));
    drawBox(Offset(28, size.height * 0.28), 40, 46, const Color(0xFFC4894A));
    drawBox(
      Offset(size.width * 0.62, size.height * 0.55),
      42,
      48,
      const Color(0xFFE0B07A),
    );

    // Soft highlight
    canvas.drawCircle(
      Offset(cx - r * 0.3, cy - r * 0.35),
      r * 0.18,
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );

    // Tiny orbit ring
    final orbit = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-math.pi / 8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 2.4, height: r * 0.9),
      orbit,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
