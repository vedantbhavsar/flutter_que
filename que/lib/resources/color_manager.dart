import 'package:flutter/material.dart';

class ColorManager {
  static Color primary = Colors.blue[800]!;
  static Color primaryOpacity70 = Colors.blue[500]!;
  static Color darkGrey = Colors.grey[800]!;
  static Color grey = Colors.grey[600]!;
  static Color lightGrey = Colors.grey[400]!;
  static Color accentColor = Colors.black12;

  static Color darkPrimary = HexColor.fromHex('#d17d11');
  static Color grey1 = HexColor.fromHex('#707070');
  static Color grey2 = HexColor.fromHex('#797979');
  static Color white = HexColor.fromHex('#FFFFFF');
  static Color black = HexColor.fromHex('#000000');
  static Color error = HexColor.fromHex('#e61f34');
}

extension HexColor on Color {
  static Color fromHex(String color) {
    color = color.replaceAll('#', '');
    if (color.length == 6) {
      color = 'FF' + color; // char 8 with opacity 100%
    }
    return Color(int.parse(color, radix: 16));
  }
}
