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
  Color(0),
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
  Color(0xff60d658),
  Color(0xff8b93e5),
  Color(0xffc1e3d0),
  Color(0xff9a95b3),
  Color(0xfffdb659),
  Color(0xff9c1294),
  Color(0xffbc66e1),
  Color(0xff32b7ec),
  Color(0xffe28255),
  Color(0xfff80719),
  Color(0xfff4146c),
  Color(0xff1a1e13),
  Color(0xff212e32),
  Color(0xffcf57af),
  Color(0xff7d6633),
  Color(0xffb1fee3),
  Color(0xff83a2e6),
  Color(0xff000969),
  Color(0xff62b77b),
  Color(0xff3a0ce6),
  Color(0xff6eff67),
  Color(0xff801f75),
  Color(0xff3fac50),
  Color(0xffcc9178),
  Color(0xff16f048),
  Color(0xffe8fa92),
  Color(0xff05ef26),
  Color(0xffa992c1),
  Color(0xff918a1b),
  Color(0xff24548d),
  Color(0xff7c8998),
  Color(0xff25c56c),
  Color(0xffe50814),
  Color(0xffe99914),
  Color(0xff09f6db),
  Color(0xffea0611),
  Color(0xffa68a2f),
  Color(0xff9bcc3c),
  Color(0xffc336da),
  Color(0xff605438),
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
