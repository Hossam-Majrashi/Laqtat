import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('verify package:image operations', () {
    final image = img.Image(width: 400, height: 300);
    img.fill(image, color: img.ColorRgb8(33, 35, 39));
    final tile = img.Image(width: 100, height: 60);
    img.fill(tile, color: img.ColorRgb8(200, 100, 50));
    img.compositeImage(image, tile, dstX: 10, dstY: 10);
    final pngBytes = img.encodePng(image);
    final jpgBytes = img.encodeJpg(image, quality: 90);
    expect(pngBytes.isNotEmpty, true);
    expect(jpgBytes.isNotEmpty, true);
  });
}
