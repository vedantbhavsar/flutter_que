import 'package:flutter/material.dart';
import 'package:que/resources/font_manager.dart';

TextStyle _getTextStyle(
    String fontFamily, FontWeight fontWeight, double fontSize, Color color) {
  return TextStyle(
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    fontSize: fontSize,
    color: color,
  );
}

TextStyle getRegularFont(
    {double fontSize = FontSize.s12, required Color color}) {
  return _getTextStyle(
      FontManager.fontFamily, FontWeightManager.regular, fontSize, color);
}

TextStyle getLightFont({double fontSize = FontSize.s12, required Color color}) {
  return _getTextStyle(
      FontManager.fontFamily, FontWeightManager.light, fontSize, color);
}

TextStyle getMediumFont(
    {double fontSize = FontSize.s12, required Color color}) {
  return _getTextStyle(
      FontManager.fontFamily, FontWeightManager.medium, fontSize, color);
}

TextStyle getSemiBoldFont(
    {double fontSize = FontSize.s12, required Color color}) {
  return _getTextStyle(
      FontManager.fontFamily, FontWeightManager.semiBold, fontSize, color);
}

TextStyle getBoldFont({double fontSize = FontSize.s12, required Color color}) {
  return _getTextStyle(
      FontManager.fontFamily, FontWeightManager.bold, fontSize, color);
}
