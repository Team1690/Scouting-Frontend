library flutter_radar;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';

const _defaultXAxisTextStyle = TextStyle(color: primaryWhite, fontSize: 12);

const _defaultYAxisTextStyle = TextStyle(color: Color(0xff333333), fontSize: 9);

/// coordinate style
class CoordinateStyle {
  /// line width
  final double lineWidth;

  /// line color
  final Color lineColor;

  /// x axis textStyle default [_defaultXAxisTextStyle]
  final TextStyle xAxisTextStyle;

  /// y axis textStyle default [_defaultYAxisTextStyle]
  final TextStyle yAxisTextStyle;

  /// cell's spacing
  final double gridSpace;

  /// whether show x axis's text
  bool showXAxisText;

  /// whether show y axis's text
  bool showYAxisText;

  /// default value is [xAxisTexts.length].
  /// If you don't want to show the text of th x-axis and you don't pass the xAxisTexts value,
  /// you must set this value
  int xScaleCount;

  /// defalut value is [yAxisTexts.length]
  /// If you don't want to show the text of th y-axis and you don't pass the yAxisTexts value,
  /// you must set this value
  /// contain origin point
  int yScaleCount;

  final List<String> xAxisTexts;

  final List<String> yAxisTexts;

  /// the scale of y-axis.
  final double yScale;

  CoordinateStyle(this.yScale,
      {this.lineWidth = 0.5,
      this.lineColor = const Color(0xffdddddd),
      this.xAxisTextStyle = _defaultXAxisTextStyle,
      this.yAxisTextStyle = _defaultYAxisTextStyle,
      this.gridSpace = 22,
      this.showXAxisText,
      this.showYAxisText,
      this.xAxisTexts,
      this.yAxisTexts,
      this.xScaleCount,
      this.yScaleCount}) {
    showXAxisText ??= xAxisTexts == null ? false : true;
    showYAxisText ??= yAxisTexts == null ? false : true;
    assert(xScaleCount != null || xAxisTexts != null,
        "set xScaleCount or xAxisTexts");
    assert(yScaleCount != null || yAxisTexts != null,
        "set xScaleCount or xAxisTexts");
    xScaleCount ??= xAxisTexts.length;
    yScaleCount ??= yAxisTexts.length;
    assert(xScaleCount != 0, "set xScaleCount or xAxisTexts");
    if (xAxisTexts != null) {
      assert(
          xScaleCount == xAxisTexts.length, "xScaleCount != xAxisTexts.length");
    }
    assert(yScaleCount != 0, "set yScaleCount or yAxisTexts");
    if (yAxisTexts != null) {
      assert(
          yScaleCount == yAxisTexts.length, "yScaleCount != yAxisTexts.length");
    }
  }
}

class RadarDataSourceConfig {
  /// Clockwise from the y-axis 12-point direction
  /// values's max value must less than or equal [yScale * yScaleCount] and more than 0.0
  final List<double> values;

  /// whether to fill
  final bool fill;

  /// fill area's color
  /// When you set this value, you must set fill = true
  final Color fillColor;

  /// whether show dot
  final bool showDot;

  /// whether show line
  final bool showLine;

  /// line width
  final double lineWidth;

  /// line color
  final Color lineColor;

  /// defalut is equal to lineColor
  final Color dotColor;

  /// radius of the dot.
  final double dotRadius;

  RadarDataSourceConfig(this.values,
      {this.fill = false,
      this.fillColor,
      this.showDot = true,
      this.showLine = true,
      this.lineWidth = 2,
      this.lineColor = Colors.red,
      this.dotColor,
      this.dotRadius = 5});
}

class Radar extends StatelessWidget {
  final CoordinateStyle coordinateStyle;

  final List<RadarDataSourceConfig> dataSource;

  final Size size;

  Radar({
    @required this.dataSource,
    @required this.coordinateStyle,
    @required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: RadarPainter(coordinateStyle, dataSource),
    );
  }
}

class RadarPainter extends CustomPainter {
  final CoordinateStyle coordinateStyle;

  final List<RadarDataSourceConfig> dataSource;

  RadarPainter(this.coordinateStyle, this.dataSource) {
    for (RadarDataSourceConfig config in dataSource) {
      assert(coordinateStyle.xScaleCount == config.values.length,
          "coordinateStyle.xScaleCount != config.values.length");
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint coorPaint = Paint()
      ..color = coordinateStyle.lineColor
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = true
      ..strokeWidth = coordinateStyle.lineWidth
      ..style = PaintingStyle.stroke;
    List<Offset> vertexs = List();
    for (int j = 0; j < coordinateStyle.yAxisTexts.length - 1; j++) {
      Path path;
      for (int i = 0; i < coordinateStyle.xScaleCount + 1; i++) {
        double radian =
            math.pi * 2 * (i / coordinateStyle.xScaleCount) - math.pi / 2;
        double y =
            center.dy + math.sin(radian) * coordinateStyle.gridSpace * (j + 1);
        double x =
            center.dx + math.cos(radian) * coordinateStyle.gridSpace * (j + 1);
        if (i == 0) {
          path = new Path()..moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        canvas.drawPath(path, coorPaint);
        if (j == coordinateStyle.yScaleCount - 2) {
          vertexs.add(Offset(x, y));
        }
      }
    }

    for (int i = 0; i < coordinateStyle.xScaleCount; i++) {
      Path path = new Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(vertexs[i].dx, vertexs[i].dy);
      canvas.drawPath(path, coorPaint);
    }

    if (coordinateStyle.showXAxisText) {
      for (int i = 0; i < coordinateStyle.xScaleCount; i++) {
        int c = coordinateStyle.xAxisTexts[i].length < 4
            ? coordinateStyle.xAxisTexts[i].length
            : 4;
        double maxWidth = coordinateStyle.xAxisTextStyle.fontSize * 1.0 * c;
        double maxHeight = 20;
        double radian =
            math.pi * 2 * (i / coordinateStyle.xScaleCount) - math.pi / 2;
        double space = 5;
        double y = center.dy +
            math.sin(radian) *
                (coordinateStyle.gridSpace * (coordinateStyle.yScaleCount - 1) +
                    maxWidth / 2 +
                    space);
        double x = center.dx +
            math.cos(radian) *
                (coordinateStyle.gridSpace * (coordinateStyle.yScaleCount - 1) +
                    maxWidth / 2 +
                    space);
        Offset origin = Offset(x - maxWidth / 2, y - maxHeight / 2);
        TextPainter(
            text: TextSpan(
                text: coordinateStyle.xAxisTexts[i],
                style: coordinateStyle.xAxisTextStyle),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLines: 2)
          ..layout(maxWidth: maxWidth, minWidth: 0)
          ..paint(canvas, origin);
      }
    }

    if (coordinateStyle.showYAxisText) {
      for (int i = 0; i < coordinateStyle.yScaleCount; i++) {
        double maxWidth = coordinateStyle.yAxisTextStyle.fontSize *
            0.4 *
            coordinateStyle.yScaleCount;
        double maxHeight = coordinateStyle.yAxisTextStyle.fontSize * 1.5;
        Offset origin = Offset(center.dx + 5,
            center.dy - (i * coordinateStyle.gridSpace) - maxHeight / 2);
        TextPainter(
          text: TextSpan(
              text: coordinateStyle.yAxisTexts[i],
              style: coordinateStyle.yAxisTextStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
        )
          ..layout(maxWidth: maxWidth, minWidth: maxWidth)
          ..paint(canvas, origin);
      }
    }

    for (RadarDataSourceConfig config in dataSource) {
      List<Offset> points = List();

      Paint pointPaint = Paint()
        ..color = config.dotColor ?? config.lineColor
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..strokeWidth = config.dotRadius * 2
        ..style = PaintingStyle.stroke;
      Paint linePaint = Paint()
        ..color = config.lineColor
        ..strokeCap = StrokeCap.square
        ..isAntiAlias = true
        ..strokeWidth = config.lineWidth
        ..style = PaintingStyle.stroke;
      Paint lineFillPaint;
      if (config.fill) {
        lineFillPaint = Paint()
          ..color = config.fillColor ?? config.lineColor.withOpacity(0.5)
          ..strokeCap = StrokeCap.square
          ..isAntiAlias = true
          ..strokeWidth = 0.5
          ..style = PaintingStyle.fill;
      }

      Path path;
      for (int i = 0; i < coordinateStyle.xScaleCount + 1; i++) {
        double radian =
            math.pi * 2 * (i / coordinateStyle.xScaleCount) - math.pi / 2;
        double x = config.values[i % coordinateStyle.xScaleCount] /
                (coordinateStyle.yScale * coordinateStyle.yScaleCount) *
                coordinateStyle.gridSpace *
                (coordinateStyle.yScaleCount - 1) *
                math.cos(radian) +
            center.dx;
        double y = config.values[i % coordinateStyle.xScaleCount] /
                (coordinateStyle.yScale * coordinateStyle.yScaleCount) *
                coordinateStyle.gridSpace *
                (coordinateStyle.yScaleCount - 1) *
                math.sin(radian) +
            center.dy;
        if (i < coordinateStyle.xScaleCount) {
          Offset p = Offset(x, y);
          points.add(p);
        }
        if (i == 0) {
          path = new Path()..moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        if (config.showLine) canvas.drawPath(path, linePaint);
      }
      if (config.fill) canvas.drawPath(path, lineFillPaint);
      if (config.showDot)
        canvas.drawPoints(PointMode.points, points, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
