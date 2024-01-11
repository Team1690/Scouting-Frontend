import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

const Color primaryColor = Color(0xFF2697FF);
const Color secondaryColor = Color(0xFF2A2D3E);
const Color bgColor = Color(0xFF212332);
const Color primaryWhite = Colors.white;
const Color secondaryWhite = Colors.white54;

const double defaultPadding = 20.0;

const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(10));

final ThemeData darkModeTheme = ThemeData.dark().copyWith(
  pageTransitionsTheme: PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      for (final TargetPlatform platform in TargetPlatform.values)
        platform: const FadeUpwardsPageTransitionsBuilder(),
    },
  ),
  scaffoldBackgroundColor: bgColor,
  textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
  canvasColor: secondaryColor,
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: defaultBorderRadius),
  ),
  toggleButtonsTheme: const ToggleButtonsThemeData(
    borderRadius: defaultBorderRadius,
  ),
  buttonTheme: const ButtonThemeData(buttonColor: primaryColor),
);

bool isPC(final BuildContext context) {
  return false;
}
