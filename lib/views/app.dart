import "package:google_fonts/google_fonts.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/screens/input_view.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";

class App extends StatelessWidget {
  App({
    required this.teams,
    required this.balanceIds,
    required this.driveMotorIds,
    required this.drivetrainIds,
    required this.matchTypeIds,
    required this.robotMatchStatusIds,
    required this.faultStatus,
    required this.matches,
  });
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

  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(10));
  final List<ScheduleMatch> matches;
  final Map<String, int> robotMatchStatusIds;
  final List<LightTeam> teams;
  final Map<String, int> balanceIds;
  final Map<String, int> drivetrainIds;
  final Map<String, int> driveMotorIds;
  final Map<String, int> matchTypeIds;
  final Map<String, int> faultStatus;
  final ThemeData darkModeTheme = ThemeData.dark().copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        for (final TargetPlatform platform in TargetPlatform.values)
          platform: FadeUpwardsPageTransitionsBuilder()
      },
    ),
    scaffoldBackgroundColor: Color(0xFF212332),
    textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
    canvasColor: Color(0xFF2A2D3E),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: borderRadius),
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      borderRadius: borderRadius,
    ),
    buttonTheme: ButtonThemeData(buttonColor: Color(0xFF2697FF)),
  );
  @override
  Widget build(final BuildContext context) {
    return TeamProvider(
      teams: teams,
      child: MatchesProvider(
        matches: matches,
        child: IdProvider(
          matchTypeIds: matchTypeIds,
          balanceIds: balanceIds,
          drivemotorIds: driveMotorIds,
          drivetrainIds: drivetrainIds,
          robotMatchStatusIds: robotMatchStatusIds,
          faultStatus: faultStatus,
          child: MaterialApp(
            title: "Orbit Scouting",
            home: isPC(context) ? TeamInfoScreen() : UserInput(),
            theme: darkModeTheme,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}
