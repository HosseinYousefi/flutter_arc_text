import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum StartAngleAlignment { start, center, end }

class ArcText extends StatelessWidget {
  const ArcText({
    Key key,
    @required this.radius,
    @required this.text,
    @required this.textStyle,
    this.startAngle = 0,
    this.startAngleAlignment = StartAngleAlignment.start,
  }) : super(key: key);

  /// Radius of the arc along which the text will be drawn.
  final double radius;

  /// Text to draw.
  final String text;

  /// TextStyle that will be applied to the text.
  final TextStyle textStyle;

  /// Initial angle (0 is top center, positive angle is clockwise).
  final double startAngle;

  /// Text alignment around [startAngle]
  /// [StartAngleAlignment.start] text will starts from [startAngle]
  /// [StartAngleAlignment.center] text will be centered on [startAngle]
  /// [StartAngleAlignment.end] text will ends on [startAngle]
  final StartAngleAlignment startAngleAlignment;

  double _textAngle() {
    if (startAngleAlignment == StartAngleAlignment.start) {
      return startAngle;
    }
    var textPainter = TextPainter(textDirection: TextDirection.ltr);
    var angle = 0.0;
    for (String letter in text.split("")) {
      textPainter.text = TextSpan(text: letter, style: textStyle);
      textPainter.layout(
        minWidth: 0,
        maxWidth: double.maxFinite,
      );
      angle += 2 * math.asin(textPainter.width / (2 * radius));
    }
    if (startAngleAlignment == StartAngleAlignment.center) {
      return startAngle - angle / 2;
    }
    // startAngleAlignment == StartAngleAlignment.end
    return startAngle - angle;
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _Painter(
          radius,
          text,
          textStyle,
          initialAngle: _textAngle(),
        ),
      );
}

class _Painter extends CustomPainter {
  _Painter(this.radius, this.text, this.textStyle, {this.initialAngle = 0});

  final num radius;
  final String text;
  final double initialAngle;
  final TextStyle textStyle;

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2 - radius);

    if (initialAngle != 0) {
      final d = 2 * radius * math.sin(initialAngle / 2);
      final rotationAngle = _calculateRotationAngle(0, initialAngle);
      canvas.rotate(rotationAngle);
      canvas.translate(d, 0);
    }

    double angle = initialAngle;
    for (int i = 0; i < text.length; i++) {
      angle = _drawLetter(canvas, text[i], angle);
    }
  }

  double _drawLetter(Canvas canvas, String letter, double prevAngle) {
    _textPainter.text = TextSpan(text: letter, style: textStyle);
    _textPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );

    final double d = _textPainter.width;
    final double alpha = 2 * math.asin(d / (2 * radius));

    final newAngle = _calculateRotationAngle(prevAngle, alpha);
    canvas.rotate(newAngle);

    _textPainter.paint(canvas, Offset(0, -_textPainter.height));
    canvas.translate(d, 0);

    return alpha;
  }

  double _calculateRotationAngle(double prevAngle, double alpha) =>
      (alpha + prevAngle) / 2;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
