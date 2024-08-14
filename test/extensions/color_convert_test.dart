import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wurmapi/extensions/color_convert.dart';

void main() async {
  // ColorConvert Tests
  test('test happy path string color from', () {
    expect(ColorConvert.from("#00ff00"), const Color(0xff00ff00));
    expect(ColorConvert.from("#0f0"), const Color(0xff00ff00));
    expect(ColorConvert.from("00ff00"), const Color(0xff00ff00));
    expect(ColorConvert.from("0f0"), const Color(0xff00ff00));
    expect(ColorConvert.from("rgb(0,255,0)"), const Color(0xff00ff00));
  });
  test('test sad path string color from', () {
    expect(() => ColorConvert.from("rgb(0,255,0,0)"), throwsFormatException);
    expect(() => ColorConvert.from("rgb(0,255,0"), throwsFormatException);
    expect(() => ColorConvert.from("#badColor"), throwsFormatException);
    expect(() => ColorConvert.from("badColor"), throwsFormatException);
  });
  test('test happy path Color to img.Color', () {
    expect(ColorConvert.toImageColor(const Color(0xff00ff00)), img.ColorUint32.rgba(0, 255, 0, 255));
  });
}
