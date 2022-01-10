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
  const Color(0xff19B7E9),
  const Color(0xff02d39a),
  const Color(0xffffb443),
  const Color(0xffff7b43),
  const Color(0xffff4343),
  const Color(0xffff43CA),
  const Color(0xff982ABE),
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

T identity<T>(final T x) => x;
void ignore<T>(final T _) {}
void empty() {}
