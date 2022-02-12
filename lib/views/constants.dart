import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

const Color primaryColor = Color(0xFF2697FF);
const Color secondaryColor = Color(0xFF2A2D3E);
const Color bgColor = Color(0xFF212332);
const Color primaryWhite = Colors.white;
const Color secondaryWhite = Colors.white54;

const double defaultPadding = 20.0;

const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(10));

const List<Color> colors = <Color>[
  Color(0xFF19B7E9),
  Color(0xffff4343),
  Color(0xffffb443),
  Color(0xff02d39a),
  Color(0xffff7b43),
  Color(0xffff43CA),
  Color(0xff982ABE),
  Color(0xF6B0ECD8),
  Color(0xFF633408),
  Color(0xFF504D4D),
  Color(0xFF230BF5),
  Color(0xFFFFF45B),
];

final ThemeData darkModeTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: bgColor,
  textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
  canvasColor: secondaryColor,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: defaultBorderRadius),
  ),
  toggleButtonsTheme: ToggleButtonsThemeData(
    borderRadius: defaultBorderRadius,
  ),
  buttonTheme: ButtonThemeData(buttonColor: primaryColor),
);

bool isPC(final BuildContext context) {
  switch (Theme.of(context).platform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return false;

    case TargetPlatform.windows:
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return true;
  }
}
