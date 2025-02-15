import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Headline Styles
  static TextStyle headline1(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
    );
  }

  static TextStyle headline2(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white70
          : Colors.black87,
    );
  }

  // Body Text Styles
  static TextStyle bodyText1(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white60
          : Colors.black87,
    );
  }

  static TextStyle bodyText2(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white54
          : Colors.black54,
    );
  }

  // Caption Style
  static TextStyle caption(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[300]
          : Colors.grey[700],
    );
  }

  // Button Text Style
  static TextStyle button(BuildContext context) {
    return GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
    );
  }
}
