import 'package:flutter/material.dart';

class AppPallete {
  static const Color backgroundColor = Colors.black;
  static const Color primaryColor = Color(0xFFFF0033); // Neon Red
  static const Color secondaryColor = Color(0xFFC0C0C0); // Silver
  static const Color surfaceColor = Color(0xFF1E1E1E); // Dark Grey for Cards
  static const Color errorColor = Colors.redAccent;
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
}
class AppTheme {
  static ThemeData getDarkTheme(Color primaryColor) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppPallete.backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        surface: AppPallete.surfaceColor,
        background: AppPallete.backgroundColor,
        secondary: primaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5, color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryColor;
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryColor.withOpacity(0.5);
          return null;
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData getLightTheme(Color primaryColor) {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        secondary: primaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5, color: Colors.black),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryColor;
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryColor.withOpacity(0.5);
          return null;
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
