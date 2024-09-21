import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedConnector extends StatefulWidget {
  const AnimatedConnector({
    super.key,
    required this.startY,
    required this.endY,
    required this.containerHeight,
    required this.boxSize,
    required this.color,
  });

  final double startY;
  final double endY;
  final Color color;
  final double containerHeight;
  final double boxSize;

  @override
  State<AnimatedConnector> createState() => _AnimatedConnectorState();
}

class _AnimatedConnectorState extends State<AnimatedConnector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConnectorPainter(
        _controller,
        startY: widget.startY,
        endY: widget.endY,
        containerHeight: widget.containerHeight,
        boxSize: widget.boxSize,
        color: widget.color,
      ),
    );
  }
}

class ConnectorPainter extends CustomPainter {
  final Animation<double> _animation;

  late double startY;
  late double endY;
  late Color color;
  late double containerHeight;
  late double boxSize;

  ConnectorPainter(
    this._animation, {
    required this.startY,
    required this.endY,
    required this.color,
    required this.containerHeight,
    required this.boxSize,
  }) : super(repaint: _animation);

  Path _createPath(Size size) {
    double startTargetY = startY - containerHeight;
    double endTargetY = endY - containerHeight;

    double halfBoxsSize = boxSize / 2;

    double startPointY = startTargetY + halfBoxsSize;
    double halfy =
        ((startTargetY + boxSize) - endTargetY).abs() / 2 + halfBoxsSize;

    Path path;

    if (startTargetY < endTargetY) {
      path = Path()
        ..moveTo(0, startPointY)
        ..relativeQuadraticBezierTo(size.width / 3, 0, size.width / 2, halfy)
        ..relativeQuadraticBezierTo(
            size.width / 7, halfy + 10, size.width / 2, halfy);
    } else if (startTargetY == endTargetY) {
      path = Path()
        ..moveTo(0, startPointY)
        ..lineTo(size.width, endTargetY + halfBoxsSize);
    } else {
      path = Path()
        ..moveTo(0, startPointY)
        ..relativeQuadraticBezierTo(
            size.width / 3, 0, size.width / 2, -halfy + boxSize)
        ..relativeQuadraticBezierTo(
            size.width / 7, -halfy + boxSize, size.width / 2, -halfy + boxSize);
    }

    return path;
  }

  Path createAnimatedPath(
    Path originalPath,
    double animationPercent,
  ) {
    final totalLength = originalPath
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    final currentLength = totalLength * animationPercent;

    return extractPathUntilLength(originalPath, currentLength);
  }

  Path extractPathUntilLength(
    Path originalPath,
    double length,
  ) {
    var currentLength = 0.0;

    final path = Path();

    var metricsIterator = originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;

      var nextLength = currentLength + metric.length;

      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0.0, remainingLength);

        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        final pathSegment = metric.extractPath(0.0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final animationPecentage = _animation.value;

    var paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final path = createAnimatedPath(_createPath(size), animationPecentage);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConnectorPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ConnectorPainter oldDelegate) => false;
}
