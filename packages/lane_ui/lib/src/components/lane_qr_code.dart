// LaneQrCode: a QR code a UPI app can scan (PLAN.md §10 U13, §12.9).
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// [data] as a QR code: always black modules on white with a 4-module quiet zone (scanners
/// need that contrast in every mode, like [PlateChip]'s fixed colours). Medium error
/// correction survives a scratched or dim screen. Screen readers hear [semanticLabel] only.
class LaneQrCode extends StatelessWidget {
  const LaneQrCode({super.key, required this.data, required this.semanticLabel, this.size = 200});

  static const dark = Color(0xFF000000);
  static const light = Color(0xFFFFFFFF);

  /// QR spec: a quiet zone of 4 modules on every side.
  static const quietModules = 4;

  final String data;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = QrImage(QrCode(payload: QrPayload.fromString(data)));
    return Semantics(
      container: true,
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(painter: _QrPainter(image)),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final count = image.moduleCount + 2 * LaneQrCode.quietModules;
    final module = size.shortestSide / count;
    canvas.drawRect(Offset.zero & size, Paint()..color = LaneQrCode.light);
    final paint = Paint()
      ..color = LaneQrCode.dark
      ..isAntiAlias = false;
    for (var row = 0; row < image.moduleCount; row++) {
      for (var col = 0; col < image.moduleCount; col++) {
        if (!image.isDark(row, col)) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            (col + LaneQrCode.quietModules) * module,
            (row + LaneQrCode.quietModules) * module,
            module,
            module,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => !identical(old.image, image);
}
