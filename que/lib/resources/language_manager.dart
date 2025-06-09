import 'package:flutter/material.dart';

enum LanguageType { ENGLISH, HINDI }

const String ASSET_PATH = 'assets/translations';
const String ENGLISH = 'en';
const String HINDI = 'hi';
const Locale ENGLISH_LOCAL = Locale('en', 'US');
const Locale HINDI_LOCAL = Locale('hi', 'IN');

extension LanguageTypeExtension on LanguageType {
  String getValue() {
    switch (this) {
      case LanguageType.ENGLISH:
        return ENGLISH;
      case LanguageType.HINDI:
        return HINDI;
    }
  }
}
