import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFEC947D);
  static const Color bgSoft = Color(0xFFF7F7F7);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFFEDEDED);

  static ThemeData theme = ThemeData(
    fontFamily: "Pretendard",
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgSoft,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.black87,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      thumbColor: primaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected)
            ? primaryColor
            : Colors.grey.shade400,
      ),
      trackColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected)
            ? primaryColor.withOpacity(0.4)
            : Colors.grey.shade300,
      ),
    ),
  );
}
