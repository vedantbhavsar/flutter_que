import 'package:flutter/material.dart';
import 'package:que/resources/color_manager.dart';
import 'package:que/resources/font_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/resources/value_manager.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    // Main Colors of the App
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.primaryOpacity70,
    primaryColorDark: ColorManager.darkPrimary,
    disabledColor: ColorManager.grey1, // used in case button disable
    hintColor: ColorManager.grey,

    // Ripple Color
    splashColor: ColorManager.primaryOpacity70,

    // Card View Theme
    cardTheme: CardTheme(
      color: ColorManager.white,
      shadowColor: ColorManager.grey,
      elevation: AppSize.s4,
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      color: ColorManager.primary,
      elevation: AppSize.s4,
      shadowColor: ColorManager.primaryOpacity70,
      titleTextStyle: getRegularFont(
        color: ColorManager.white, fontSize: FontSize.s16,
      ),
    ),

    // Button Theme
    buttonTheme: ButtonThemeData(
      shape: StadiumBorder(),
      disabledColor: ColorManager.grey1,
      buttonColor: ColorManager.primary,
      splashColor: ColorManager.primaryOpacity70,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: getRegularFont(
          color: ColorManager.white,
        ),
        backgroundColor: ColorManager.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12),
        ),
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: getSemiBoldFont(
        color: ColorManager.darkGrey,
        fontSize: FontSize.s16,
      ),
      displayMedium: getRegularFont(
        color: ColorManager.white,
        fontSize: FontSize.s16,
      ),
      displaySmall: getBoldFont(
        color: ColorManager.primary,
        fontSize: FontSize.s16,
      ),
      headlineMedium: getRegularFont(
        color: ColorManager.primary,
        fontSize: FontSize.s14,
      ),
      titleMedium: getMediumFont(
        color: ColorManager.lightGrey,
        fontSize: FontSize.s14,
      ),
      bodySmall: getRegularFont(
        color: ColorManager.grey1,
      ),
      bodyLarge: getRegularFont(
        color: ColorManager.grey,
      ),
    ),

    // Input Decoration Theme (Text Form Field)
    indicatorColor: ColorManager.primaryOpacity70,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(AppPadding.p8),
      hintStyle: getRegularFont(
        color: ColorManager.grey1,
      ),
      labelStyle: getMediumFont(
        color: ColorManager.darkGrey,
      ),
      errorStyle: getRegularFont(
        color: ColorManager.error,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.grey,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSize.s8)
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.primary,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(
            Radius.circular(AppSize.s8)
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.error,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(
            Radius.circular(AppSize.s8)
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.primary,
          width: AppSize.s1_5,
        ),
        borderRadius: const BorderRadius.all(
            Radius.circular(AppSize.s8)
        ),
      ),
    ),
  );
}