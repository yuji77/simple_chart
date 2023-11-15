library simple_chart;

import 'dart:math';

import 'package:flutter/material.dart';

class PieChart extends CustomPainter {
  const PieChart({
    required this.data,
    this.max,
  });

  final List<double> data;
  final double? max;

  @override
  void paint(Canvas canvas, Size size) {
    drawPieChart(canvas, size, max, data);

    final center = Offset(size.width / 2, size.height / 2);
    drawCenterText(
      canvas,
      center,
    );
  }

  // TODO
  @override
  bool shouldRepaint(PieChart oldDelegate) => false;
}

void drawCenterText(
  Canvas canvas,
  Offset center,
) {
  final text1 = TextPainter(
    text: const TextSpan(
      text: '摂取カロリー',
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout();

  final text2 = TextPainter(
    text: const TextSpan(
      children: [
        TextSpan(
          text: 'bbbbbbbbbb',
        ),
        TextSpan(
          text: 'nnnnnnnnnn',
        )
      ],
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout();

  final text3 = TextPainter(
    text: const TextSpan(
      text: 'cccccccc',
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout();

  final text4 = TextPainter(
    text: const TextSpan(
      children: [
        TextSpan(
          text: 'aaa',
        ),
      ],
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout();

  const paddingTop = 5;
  const paddingMiddle = 25;
  const paddingbottom = 5;

  final startY = center.dy - (text1.height + text2.height + paddingTop) / 2;

  text1.paint(
    canvas,
    Offset(
      center.dx - text2.width / 2,
      startY,
    ),
  );
  text1.paint(
    canvas,
    Offset(
      center.dx - text1.width / 2,
      startY + text2.height + paddingTop,
    ),
  );
  text2.paint(
    canvas,
    Offset(
      center.dx - text3.width / 2,
      startY + text1.height + text2.height + paddingTop + paddingMiddle,
    ),
  );
  text3.paint(
    canvas,
    Offset(
      center.dx - text4.width / 2,
      startY +
          text1.height +
          text2.height +
          text3.height +
          paddingTop +
          paddingMiddle +
          paddingbottom,
    ),
  );
}

void drawPieChart(
  Canvas canvas,
  Size size,
  double? max,
  List<double> data,
) {
  const initial = 0.0;
  final sum = data.fold(initial, (pre, e) => pre + e);
  final remain = max == null ? 0.0 : max - sum;

  final originalData = [...data, remain].reversed.toList();

  final rateList = data.map((e) => calculateRate(e, sum, max)).toList();
  final remainRate = calculateRemainRate(sum, max);

  final center = Offset(size.width / 2, size.height / 2);
  final radius = size.width / 2.5;
  final innerRadius = size.width / 3.2;

  final originalPercentages =
      <double>[...rateList, remainRate].reversed.toList();

  // 円の80％を最大値に設定（下部に20％の空欄を作るため）
  const bottomSpaceRate = 0.8;
  final adjustedPercentages = <double>[
    for (var percentage in originalPercentages) percentage * bottomSpaceRate
  ];

  final colors = <Color>[
    Colors.red,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.amber,
    Colors.purple,
  ].reversed.toList();

  // 下部10％開けた右下地点からスタート
  var startAngle = 90.0 - (0.1 * 360);

  final textRadius = radius * 1.2;
  final textPainter = TextPainter(textDirection: TextDirection.ltr);

  for (var i = 0; i < adjustedPercentages.length; i++) {
    final sweepAngle = -adjustedPercentages[i] * 360;

    final paint = Paint()
      ..color = colors[i]
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius - innerRadius;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
      startAngle * (pi / 180),
      sweepAngle * (pi / 180),
      false,
      paint,
    );

    final midAngle = startAngle + sweepAngle / 2;

    final textOffset = Offset(
      center.dx + textRadius * cos(midAngle * pi / 180),
      center.dy + textRadius * sin(midAngle * pi / 180),
    );

    textPainter
      ..text = TextSpan(
        children: [
          if (originalData[i] != 0 && originalData[i] != remain) ...[
            TextSpan(
              text: (originalData[i]).toStringAsFixed(0),
            ),
            const TextSpan(
              text: 'kcal',
            )
          ]
        ],
      )
      ..layout()
      ..paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );

    startAngle += sweepAngle;
  }
}

double calculateRate(double value, double sum, double? max) {
  if (sum == 0) {
    return 0;
  }

  if (max == null || max < sum) {
    return value / sum;
  }

  return value / max;
}

double calculateRemainRate(double sum, double? max) {
  if (max == null || sum >= max) {
    return 0;
  }

  return (max - sum) / max;
}
