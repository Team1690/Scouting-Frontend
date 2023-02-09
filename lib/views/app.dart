import "package:scouting_frontend/drive_motor/drive_motor.dart";
import "package:scouting_frontend/models/id_enums.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/screens/input_view.dart";
import "package:scouting_frontend/views/constants.dart";
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
  final List<ScheduleMatch> matches;
  final Map<RobotMatchStatus, int> robotMatchStatusIds;
  final List<LightTeam> teams;
  final Map<Balance, int> balanceIds;
  final Map<DriveTrain, int> drivetrainIds;
  final Map<DriveMotor, int> driveMotorIds;
  final Map<MatchType, int> matchTypeIds;
  final Map<FaultStatus, int> faultStatus;
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
