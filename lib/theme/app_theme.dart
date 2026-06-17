import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portal_news/service/app_constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
      ),
      textTheme: GoogleFonts.urbanistTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: AppConstants.cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.backgroundColor,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: AppConstants.primaryColor,
      ),
    );
  }
}
