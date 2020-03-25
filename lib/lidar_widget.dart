import 'dart:math' as Math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:livox/lidar_data_model.dart';

class LidarPainter extends CustomPainter {
  /// 雷达数据
  final LidarData data;

  /// 文字画笔
  TextPainter _textPainter = new TextPainter(
      textAlign: TextAlign.left, textDirection: TextDirection.ltr);

  /// 圆环画笔
  Paint _circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.grey[800]
    ..strokeWidth = (0.5);

  /// 刻度画笔
  Paint _domainPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.grey
    ..strokeWidth = (1);

  /// 原点画笔
  Paint _pointPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.grey[600]
    ..strokeWidth = (1);

  /// 目标物体画笔
  Paint _targetPaint = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 10
    ..color = Colors.green;

  /// 圆环个数
  int circleCount = 5;

  /// 现实中最大半径
  int maxRealRadius = 10;

  LidarPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    // 中心点
    final Offset offsetCenter = Offset(size.width / 2, size.height / 2);
    // 多个圆环
    for (var i = 0; i < circleCount; i++) {
      canvas.drawCircle(
          offsetCenter, (size.width / 2 / circleCount * (i + 1)), _circlePaint);
    }
    // 横竖两条线
    canvas.drawLine(Offset(0, size.width / 2),
        Offset(size.width, size.width / 2), _circlePaint);
    canvas.drawLine(Offset(size.width / 2, 0),
        Offset(size.width / 2, size.width), _circlePaint);
    // 中间一个点
    canvas.drawCircle(offsetCenter, 2, _pointPaint);
    // 定义最大半径为10m
    int maxRadius = maxRealRadius * 1000;
    // 雷达界面最大半径
    double maxViewRadius = size.width / 2;
    // 实际距离与雷达画布的比例
    double scale = maxRadius / maxViewRadius;
    // 画出物体
    if (double.parse(data.radius) != 0) {
      double radius = double.parse(data.radius);
      // double elevationAngle = double.parse(data.elevationAngle);
      double angle = double.parse(data.horizontalAngle) * Math.pi / 180;
      double x = Math.cos(angle) * radius / scale;
      double y = Math.sin(angle) * radius / scale;
      Offset tOffset = Offset(
        offsetCenter.dx + x,
        offsetCenter.dy + y,
      );
      canvas.drawPoints(PointMode.points, [tOffset], _targetPaint);
    }
    // 刻度
    for (var i = 0; i < circleCount + 1; i++) {
      double x1 = offsetCenter.dx + (size.width / 2 / circleCount) * i;
      double y1 = offsetCenter.dy;
      double x2 = x1;
      double y2 = y1 - 5;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), _domainPaint);
    }
    // 单位
    for (var i = 0; i < circleCount + 1; i++) {
      _textPainter.text = TextSpan(
          style: new TextStyle(color: Colors.grey, fontSize: 12),
          text:
              '${maxRealRadius ~/ circleCount * i}${i == circleCount ? 'm' : ''}');
      _textPainter.layout();
      _textPainter.paint(
          canvas,
          Offset(offsetCenter.dx + (size.width / 2 / circleCount) * i,
              offsetCenter.dy));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class LidarWidget extends StatelessWidget {
  final LidarData data;

  const LidarWidget({Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 60;
    return Center(
        child:
            CustomPaint(size: Size(width, width), painter: LidarPainter(data)));
  }
}
