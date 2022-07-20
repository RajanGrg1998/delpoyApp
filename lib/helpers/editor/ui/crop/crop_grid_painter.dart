import 'package:flutter/material.dart';

import '../../domain/entities/crop_style.dart';

class CropGridPainter extends CustomPainter {
  CropGridPainter(
    this.rect, {
    this.style,
    this.showGrid = false,
    this.showCenterRects = true,
  });

  final Rect rect;
  final CropGridStyle? style;
  final bool showGrid, showCenterRects;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    if (showGrid) {
      _drawGrid(canvas, size);
      _drawBoundaries(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = showGrid ? style!.croppingBackground : style!.background;

    //TOP
    canvas.drawRect(
      Rect.fromLTWH(0.0, -5.0, size.width, rect.top + 5.0),
      paint,
    );
    //BOTTOM
    canvas.drawRect(
      Rect.fromPoints(
        Offset(0.0, rect.bottom),
        Offset(size.width, size.height + 5.0),
      ),
      paint,
    );
    //LEFT
    canvas.drawRect(
      Rect.fromPoints(Offset(-5.0, rect.topLeft.dy), rect.bottomLeft),
      paint,
    );
    //RIGHT
    canvas.drawRect(
      Rect.fromPoints(rect.topRight, Offset(size.width + 5.0, rect.bottom)),
      paint,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final int gridSize = style!.gridSize;
    final Paint paint = Paint()
      ..strokeWidth = style!.gridLineWidth
      ..color = style!.gridLineColor;

    for (int i = 1; i < gridSize; i++) {
      double rowDy = rect.topLeft.dy + (rect.height / gridSize) * i;
      double columnDx = rect.topLeft.dx + (rect.width / gridSize) * i;
      canvas.drawLine(
        Offset(columnDx, rect.topLeft.dy),
        Offset(columnDx, rect.bottomLeft.dy),
        paint,
      );
      canvas.drawLine(
        Offset(rect.topLeft.dx, rowDy),
        Offset(rect.topRight.dx, rowDy),
        paint,
      );
    }
  }

  void _drawBoundaries(Canvas canvas, Size size) {
    final double width = style!.boundariesWidth;
    final double lenght = style!.boundariesLength;
    final Paint paint = Paint()..color = style!.boundariesColor;

    //----//
    //EDGE//
    //----//
    //TOP LEFT |-
    canvas.drawRect(
      Rect.fromPoints(
        rect.topLeft,
        rect.topLeft + Offset(width, lenght),
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromPoints(
        rect.topLeft + Offset(width, 0.0),
        rect.topLeft + Offset(lenght, width),
      ),
      paint,
    );

    //TOP RIGHT -|
    canvas.drawRect(
      Rect.fromPoints(
        rect.topRight - Offset(lenght, 0.0),
        rect.topRight + Offset(0.0, width),
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromPoints(
        rect.topRight + Offset(0.0, width),
        rect.topRight - Offset(width, -lenght),
      ),
      paint,
    );

    //BOTTOM RIGHT _|
    canvas.drawRect(
      Rect.fromPoints(
        rect.bottomRight - Offset(width, lenght),
        rect.bottomRight,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromPoints(
        rect.bottomRight - Offset(width, 0.0),
        rect.bottomRight - Offset(lenght, width),
      ),
      paint,
    );

    //BOTOM LEFT |_
    canvas.drawRect(
      Rect.fromPoints(
        rect.bottomLeft - Offset(-width, lenght),
        rect.bottomLeft,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromPoints(
        rect.bottomLeft - Offset(-width, 0.0),
        rect.bottomLeft + Offset(lenght, -width),
      ),
      paint,
    );

    //------//
    //CENTER//
    //------//
    if (showCenterRects) {
      //TOPCENTER
      canvas.drawRect(
        Rect.fromPoints(
          rect.topCenter + Offset(-lenght / 2, 0.0),
          rect.topCenter + Offset(lenght / 2, width),
        ),
        paint,
      );

      //BOTTOMCENTER
      canvas.drawRect(
        Rect.fromPoints(
          rect.bottomCenter + Offset(-lenght / 2, 0.0),
          rect.bottomCenter + Offset(lenght / 2, -width),
        ),
        paint,
      );

      //CENTERLEFT
      canvas.drawRect(
        Rect.fromPoints(
          rect.centerLeft + Offset(0.0, -lenght / 2),
          rect.centerLeft + Offset(width, lenght / 2),
        ),
        paint,
      );

      //CENTERRIGHT
      canvas.drawRect(
        Rect.fromPoints(
          rect.centerRight + Offset(-width, -lenght / 2),
          rect.centerRight + Offset(0.0, lenght / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CropGridPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CropGridPainter oldDelegate) => false;
}
