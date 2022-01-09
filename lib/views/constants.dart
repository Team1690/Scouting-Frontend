import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const primaryWhite = Colors.white;
const secondaryWhite = Colors.white54;

const defaultPadding = 20.0;

const defaultBorderRadius = BorderRadius.all(Radius.circular(10));

const colors = [
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
    default:
      return true;
  }
}

final T Function<T>(T) ignore = <T>(final T x) => x;
