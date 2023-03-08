import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";
import "mobile/screens/new_input_view.dart";

class App extends StatelessWidget {
  App({
    required this.teams,
    required this.startingPos,
    required this.balanceIds,
    required this.driveMotorIds,
    required this.drivetrainIds,
    required this.matchTypeIds,
    required this.robotMatchStatusIds,
    required this.faultStatus,
    required this.matches,
    required this.robotActions,
    required this.locations,
  });
  final Map<String, int> startingPos;
  final Map<String, int> robotActions;
  final Map<String, int> locations;
  final List<ScheduleMatch> matches;
  final Map<String, int> robotMatchStatusIds;
  final List<LightTeam> teams;
  final Map<String, int> balanceIds;
  final Map<String, int> drivetrainIds;
  final Map<String, int> driveMotorIds;
  final Map<String, int> matchTypeIds;
  final Map<String, int> faultStatus;
  @override
  Widget build(final BuildContext context) => TeamProvider(
        teams: teams,
        child: MatchesProvider(
          matches: matches,
          child: IdProvider(
            startingPos: startingPos,
            matchTypeIds: matchTypeIds,
            robotActions: robotActions,
            locations: locations,
            balanceIds: balanceIds,
            drivemotorIds: driveMotorIds,
            drivetrainIds: drivetrainIds,
            robotMatchStatusIds: robotMatchStatusIds,
            faultStatus: faultStatus,
            child: MaterialApp(
              title: "Orbit Scouting",
              home: isPC(context) ? TeamInfoScreen() : UserInput2(),
              theme: darkModeTheme,
              debugShowCheckedModeBanner: false,
            ),
          ),
        ),
      );
}
