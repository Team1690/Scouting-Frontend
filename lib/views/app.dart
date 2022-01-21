import "package:scouting_frontend/login_screen.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:flutter/material.dart";

class App extends StatelessWidget {
  App({
    required this.teams,
    required this.climdIds,
    required this.driveMotorIds,
    required this.drivetrainIds,
  });
  final List<LightTeam> teams;
  final Map<String, int> climdIds;
  final Map<String, int> drivetrainIds;
  final Map<String, int> driveMotorIds;
  @override
  Widget build(final BuildContext context) {
    return TeamProvider(
      teams: teams,
      child: IdProvider(
        climbIds: climdIds,
        drivemotorIds: driveMotorIds,
        drivetrainIds: drivetrainIds,
        child: MaterialApp(
          title: "Orbit Scouting",
          home: LoginScreen(),
          theme: darkModeTheme,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
