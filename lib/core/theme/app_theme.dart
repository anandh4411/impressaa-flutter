import 'package:flutter/material.dart' show Brightness;
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  // Available color schemes from shadcn
  static const colorSchemes = [
    'blue',
    'gray',
    'green',
    'neutral',
    'orange',
    'red',
    'rose',
    'slate',
    'stone',
    'violet',
    'yellow',
    'zinc'
  ];

  static ShadThemeData lightTheme(String colorName) {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: ShadColorScheme.fromName(colorName),
    );
  }

  static ShadThemeData darkTheme(String colorName) {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme:
          ShadColorScheme.fromName(colorName, brightness: Brightness.dark),
    );
  }
}
