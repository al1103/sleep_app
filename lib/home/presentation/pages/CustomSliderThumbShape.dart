// Custom slider thumb with emoji indicator
import 'package:flutter/material.dart';

class CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final int quality;

  const CustomSliderThumbShape({
    required this.thumbRadius,
    required this.quality,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw thumb circle
    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);

    // Draw emoji based on quality
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _getEmoji(),
        style: TextStyle(
          fontSize: thumbRadius * 1.2,
          fontFamily: 'Emoji',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  String _getEmoji() {
    if (quality <= 3) return '😫';
    if (quality <= 5) return '😐';
    if (quality <= 7) return '🙂';
    if (quality <= 9) return '😊';
    return '😁';
  }
}
