import 'package:flutter/material.dart';

class IngredientArtIcon extends StatelessWidget {
  const IngredientArtIcon({
    super.key,
    required this.kind,
    required this.color,
    this.size = 34,
    this.strokeWidth = 1.8,
  });

  final IngredientArtKind kind;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return _buildCustomPaint();
  }

  Widget _buildCustomPaint() {
    return CustomPaint(
      size: Size.square(size),
      painter: _IngredientArtPainter(
        kind: kind,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

enum IngredientArtKind {
  tofu,
  tempeh,
  carrot,
  bowl,
  milk,
  box,
  darkBottle,
  basket,
  chili,
  cabbage,
  salt,
  egg,
  cucumber,
  onion,
  drumstick,
  rice,
  soySauce,
  leafy,
  unknown,
}

class _IngredientArtPainter extends CustomPainter {
  _IngredientArtPainter({
    required this.kind,
    required this.color,
    required this.strokeWidth,
  });

  final IngredientArtKind kind;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withAlpha((0.12 * 255).toInt())
      ..style = PaintingStyle.fill;

    switch (kind) {
      case IngredientArtKind.tofu:
        _drawTofu(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.tempeh:
        _drawTempeh(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.carrot:
        _drawCarrot(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.bowl:
        _drawBowl(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.milk:
        _drawMilk(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.box:
        _drawBox(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.darkBottle:
        _drawDarkBottle(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.basket:
        _drawBasket(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.chili:
        _drawChili(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.cabbage:
        _drawCabbage(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.salt:
        _drawSalt(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.egg:
        _drawEgg(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.cucumber:
        _drawCucumber(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.onion:
        _drawOnion(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.drumstick:
        _drawDrumstick(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.rice:
        _drawRice(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.soySauce:
        _drawSoySauce(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.leafy:
        _drawLeafy(canvas, size, paint, fillPaint);
        break;
      case IngredientArtKind.unknown:
        _drawUnknown(canvas, size, paint, fillPaint);
        break;
    }
  }

  void _drawTofu(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.18,
        size.width * 0.64,
        size.height * 0.5,
      ),
      Radius.circular(size.shortestSide * 0.08),
    );
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, paint);
    for (final dot in [
      Offset(size.width * 0.36, size.height * 0.32),
      Offset(size.width * 0.5, size.height * 0.42),
      Offset(size.width * 0.64, size.height * 0.34),
    ]) {
      canvas.drawCircle(
        dot,
        size.shortestSide * 0.025,
        paint..style = PaintingStyle.fill,
      );
      paint.style = PaintingStyle.stroke;
    }
  }

  void _drawTempeh(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.2,
        size.width * 0.64,
        size.height * 0.6,
      ),
      Radius.circular(size.shortestSide * 0.08),
    );
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, paint);

    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.2),
      Offset(size.width * 0.36, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.54, size.height * 0.2),
      Offset(size.width * 0.54, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.2),
      Offset(size.width * 0.72, size.height * 0.8),
      paint,
    );

    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    final dots = [
      Offset(size.width * 0.26, size.height * 0.35),
      Offset(size.width * 0.28, size.height * 0.6),
      Offset(size.width * 0.44, size.height * 0.3),
      Offset(size.width * 0.46, size.height * 0.65),
      Offset(size.width * 0.62, size.height * 0.45),
      Offset(size.width * 0.64, size.height * 0.7),
      Offset(size.width * 0.76, size.height * 0.3),
      Offset(size.width * 0.78, size.height * 0.55),
    ];

    for (final dot in dots) {
      canvas.drawCircle(dot, size.shortestSide * 0.03, dotPaint);
    }
  }

  void _drawCarrot(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.5,
        size.width * 0.7,
        size.height * 0.16,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.05,
        size.width * 0.84,
        size.height * 0.12,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.2,
        size.width * 0.8,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.56,
        size.height * 0.78,
        size.width * 0.26,
        size.height * 0.84,
      )
      ..close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(size.width * 0.46, size.height * 0.3),
      Offset(size.width * 0.65, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.42),
      Offset(size.width * 0.58, size.height * 0.58),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.68, size.height * 0.24),
      Offset(size.width * 0.88, size.height * 0.18),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.14),
      Offset(size.width * 0.75, size.height * 0.02),
      paint,
    );
  }

  void _drawBowl(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final bowl = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.32,
        size.width * 0.68,
        size.height * 0.44,
      ),
      Radius.circular(size.shortestSide * 0.16),
    );
    canvas.drawRRect(bowl, fillPaint);
    canvas.drawRRect(bowl, paint);
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.18,
        size.width * 0.48,
        size.height * 0.28,
      ),
      3.15,
      2.9,
      false,
      paint,
    );
  }

  void _drawMilk(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.2,
        size.width * 0.48,
        size.height * 0.64,
      ),
      Radius.circular(size.shortestSide * 0.08),
    );
    canvas.drawRRect(body, fillPaint);
    canvas.drawRRect(body, paint);
    final top = Path()
      ..moveTo(size.width * 0.34, size.height * 0.2)
      ..lineTo(size.width * 0.5, size.height * 0.06)
      ..lineTo(size.width * 0.66, size.height * 0.2);
    canvas.drawPath(top, paint);
    canvas.drawLine(
      Offset(size.width * 0.34, size.height * 0.38),
      Offset(size.width * 0.66, size.height * 0.38),
      paint,
    );
  }

  void _drawBox(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.24,
        size.width * 0.6,
        size.height * 0.52,
      ),
      Radius.circular(size.shortestSide * 0.07),
    );
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, paint);
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.42),
      Offset(size.width * 0.8, size.height * 0.42),
      paint,
    );
  }

  void _drawDarkBottle(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.32,
        size.height * 0.16,
        size.width * 0.36,
        size.height * 0.66,
      ),
      Radius.circular(size.shortestSide * 0.11),
    );
    canvas.drawRRect(body, fillPaint);
    canvas.drawRRect(body, paint);
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.16),
      Offset(size.width * 0.42, size.height * 0.08),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.16),
      Offset(size.width * 0.58, size.height * 0.08),
      paint,
    );
  }

  void _drawBasket(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final body = Path()
      ..moveTo(size.width * 0.16, size.height * 0.42)
      ..lineTo(size.width * 0.84, size.height * 0.42)
      ..lineTo(size.width * 0.76, size.height * 0.8)
      ..lineTo(size.width * 0.24, size.height * 0.8)
      ..close();
    canvas.drawPath(body, fillPaint);
    canvas.drawPath(body, paint);
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.06,
        size.width * 0.48,
        size.height * 0.34,
      ),
      0.0,
      3.14,
      false,
      paint,
    );
  }

  void _drawChili(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.64)
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.82,
        size.width * 0.76,
        size.height * 0.34,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.22,
        size.width * 0.9,
        size.height * 0.24,
      )
      ..quadraticBezierTo(
        size.width * 0.86,
        size.height * 0.42,
        size.width * 0.8,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        size.width * 0.54,
        size.height * 0.9,
        size.width * 0.2,
        size.height * 0.74,
      );
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(size.width * 0.76, size.height * 0.3),
      Offset(size.width * 0.86, size.height * 0.16),
      paint,
    );
  }

  void _drawCabbage(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final outer = Offset(size.width * 0.5, size.height * 0.52);
    canvas.drawCircle(outer, size.shortestSide * 0.28, fillPaint);
    canvas.drawCircle(outer, size.shortestSide * 0.28, paint);
    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.45),
      size.shortestSide * 0.12,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.47),
      size.shortestSide * 0.12,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.32,
        size.height * 0.26,
        size.width * 0.36,
        size.height * 0.28,
      ),
      3.15,
      3.0,
      false,
      paint,
    );
  }

  void _drawSalt(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final shaker = Path()
      ..moveTo(size.width * 0.28, size.height * 0.26)
      ..lineTo(size.width * 0.72, size.height * 0.26)
      ..lineTo(size.width * 0.62, size.height * 0.82)
      ..lineTo(size.width * 0.38, size.height * 0.82)
      ..close();
    canvas.drawPath(shaker, fillPaint);
    canvas.drawPath(shaker, paint);
    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.18),
      Offset(size.width * 0.64, size.height * 0.18),
      paint,
    );
    for (final hole in [
      Offset(size.width * 0.43, size.height * 0.39),
      Offset(size.width * 0.5, size.height * 0.35),
      Offset(size.width * 0.57, size.height * 0.39),
    ]) {
      canvas.drawCircle(
        hole,
        size.shortestSide * 0.02,
        paint..style = PaintingStyle.fill,
      );
      paint.style = PaintingStyle.stroke;
    }
  }

  void _drawEgg(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final egg = Path()
      ..moveTo(size.width * 0.5, size.height * 0.16)
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.16,
        size.width * 0.74,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.86,
        size.width * 0.5,
        size.height * 0.86,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.86,
        size.width * 0.26,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.16,
        size.width * 0.5,
        size.height * 0.16,
      )
      ..close();
    canvas.drawPath(egg, fillPaint);
    canvas.drawPath(egg, paint);
  }

  void _drawCucumber(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final path = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.14,
        size.height * 0.34,
        size.width * 0.72,
        size.height * 0.3,
      ),
      Radius.circular(size.shortestSide * 0.18),
    );
    canvas.drawRRect(path, fillPaint);
    canvas.drawRRect(path, paint);
    canvas.drawLine(
      Offset(size.width * 0.26, size.height * 0.48),
      Offset(size.width * 0.72, size.height * 0.48),
      paint,
    );
  }

  void _drawOnion(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.shortestSide * 0.26,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.shortestSide * 0.26,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.36,
        size.height * 0.22,
        size.width * 0.28,
        size.height * 0.18,
      ),
      3.1,
      3.1,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.22),
      Offset(size.width * 0.5, size.height * 0.08),
      paint,
    );
  }

  void _drawDrumstick(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final meat = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.24,
        size.width * 0.56,
        size.height * 0.42,
      ),
      Radius.circular(size.shortestSide * 0.18),
    );
    canvas.drawRRect(meat, fillPaint);
    canvas.drawRRect(meat, paint);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.66),
      size.shortestSide * 0.12,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.66),
      size.shortestSide * 0.12,
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.54),
      Offset(size.width * 0.92, size.height * 0.74),
      paint,
    );
  }

  void _drawRice(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final bowl = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.42,
        size.width * 0.68,
        size.height * 0.28,
      ),
      Radius.circular(size.shortestSide * 0.16),
    );
    canvas.drawRRect(bowl, fillPaint);
    canvas.drawRRect(bowl, paint);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.26),
      size.shortestSide * 0.12,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.26),
      size.shortestSide * 0.12,
      paint,
    );
  }

  void _drawSoySauce(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.34,
        size.height * 0.14,
        size.width * 0.32,
        size.height * 0.7,
      ),
      Radius.circular(size.shortestSide * 0.08),
    );
    canvas.drawRRect(body, fillPaint);
    canvas.drawRRect(body, paint);
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.14),
      Offset(size.width * 0.42, size.height * 0.06),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.14),
      Offset(size.width * 0.58, size.height * 0.06),
      paint,
    );
  }

  void _drawLeafy(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final leaf = Path()
      ..moveTo(size.width * 0.5, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.26,
        size.width * 0.8,
        size.height * 0.66,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.88,
        size.width * 0.5,
        size.height * 0.86,
      )
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.88,
        size.width * 0.2,
        size.height * 0.66,
      )
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.26,
        size.width * 0.5,
        size.height * 0.12,
      )
      ..close();
    canvas.drawPath(leaf, fillPaint);
    canvas.drawPath(leaf, paint);
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.78),
      paint,
    );
  }

  void _drawUnknown(Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.2,
        size.width * 0.64,
        size.height * 0.52,
      ),
      Radius.circular(size.shortestSide * 0.08),
    );
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _IngredientArtPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

IngredientArtKind ingredientArtKindForName(String name, String category) {
  final value = '$name $category'.toLowerCase();

  if (value.contains('tahu')) return IngredientArtKind.tofu;
  if (value.contains('tempe')) return IngredientArtKind.tempeh;
  if (value.contains('wortel')) return IngredientArtKind.carrot;
  if (value.contains('nasi') ||
      value.contains('mie') ||
      value.contains('kentang')) {
    return IngredientArtKind.bowl;
  }
  if (value.contains('susu')) {
    return IngredientArtKind.milk;
  }
  if (value.contains('kotak') || value.contains('box')) {
    return IngredientArtKind.box;
  }
  if (value.contains('kecap')) {
    return IngredientArtKind.soySauce;
  }
  if (value.contains('minyak')) {
    return IngredientArtKind.darkBottle;
  }
  if (value.contains('garam')) {
    return IngredientArtKind.salt;
  }
  if (value.contains('bumbu') || value.contains('pantry')) {
    return IngredientArtKind.basket;
  }
  if (value.contains('cabai')) {
    return IngredientArtKind.chili;
  }
  if (value.contains('kol') || value.contains('brokoli')) {
    return IngredientArtKind.cabbage;
  }
  if (value.contains('telur')) {
    return IngredientArtKind.egg;
  }
  if (value.contains('tomat') || value.contains('timun')) {
    return IngredientArtKind.cucumber;
  }
  if (value.contains('bawang')) {
    return IngredientArtKind.onion;
  }
  if (value.contains('ayam') || value.contains('daging')) {
    return IngredientArtKind.drumstick;
  }
  if (value.contains('daun bawang') ||
      value.contains('bayam') ||
      value.contains('sawi')) {
    return IngredientArtKind.leafy;
  }
  if (value.contains('beras')) {
    return IngredientArtKind.rice;
  }

  return IngredientArtKind.unknown;
}
