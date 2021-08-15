import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const primaryWhite = Colors.white;
const secondaryWhite = Colors.white54;

const defaultPadding = 20.0;

const defaultBorderRadius = BorderRadius.all(Radius.circular(10));

ThemeData darkModeTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: bgColor,
  textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
  canvasColor: secondaryColor,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: defaultBorderRadius),
  ),
  toggleButtonsTheme: ToggleButtonsThemeData(
    borderRadius: defaultBorderRadius,
  ),
);
