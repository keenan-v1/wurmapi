import 'dart:ui';
import 'package:image/image.dart' as img;

extension ColorConvert on Color {
  static Color from(String colorString) {
    if (colorString.startsWith('rgb')) {
      return fromRGB(colorString);
    } else if (colorString.startsWith('#') || colorString.length == 3 || colorString.length == 6) {
      return fromHex(colorString);
    } else {
      throw FormatException('Invalid color string: $colorString');
    }
  }

  static Color fromRGB(String rgbString) {
    final regex = RegExp(r'rgb\((\d+),(\d+),(\d+)\)');
    final match = regex.firstMatch(rgbString);
    if (match != null) {
      final red = int.parse(match.group(1)!);
      final green = int.parse(match.group(2)!);
      final blue = int.parse(match.group(3)!);
      return Color.fromARGB(255, red, green, blue);
    }
    throw FormatException('Invalid RGB string: $rgbString');
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    hexString = hexString.toUpperCase().replaceAll('#', '');
    if (hexString.length == 3) hexString = _convert3To6(hexString);
    if (hexString.length == 6) buffer.write('ff');
    buffer.write(hexString);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String _convert3To6(String hex) {
    if (hex.length == 3) {
      return hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }
    return hex;
  }

  static img.Color toImageColor(Color color) {
    return img.ColorUint32.rgba(color.red, color.green, color.blue, color.alpha);
  }
}