import "dart:io";

import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_enums.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/fetch_matches.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/app.dart";

import "firebase_options.dart";
import "models/id_helpers.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb || Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  final Map<String, List<dynamic>> enums = await fetchEnums(<String>[
    "_2023_balance",
    "drivetrain",
    "drivemotor",
    "robot_match_status",
    "fault_status",
    "match_type"
  ]);
  final Map<MatchType, int> matchTypes = parseTable(
    enums["match_type"]!,
    (final String title) => MatchType.values.firstWhere(
      (final MatchType matchType) => matchType.title == title,
      orElse: () => throw Exception("Got an undefined match type, $title"),
    ),
  );

  final Map<Balance, int> balances = parseTable(
    enums["_2023_balance"]!,
    (final String title) => Balance.values.firstWhere(
      (final Balance balance) => balance.title == title,
      orElse: () => throw Exception("Got an undefined balance type"),
    ),
  );
  final Map<DriveTrain, int> driveTrains = parseTable(
    enums["drivetrain"]!,
    (final String title) => DriveTrain.values.firstWhere(
      (final DriveTrain driveTrain) => driveTrain.title == title,
      orElse: () =>
          throw Exception("Got an undefined drive train type, $title"),
    ),
  );
  final Map<DriveMotor, int> driveMotors = parseTable(
    enums["drivemotor"]!,
    (final String title) => DriveMotor.values.firstWhere(
      (final DriveMotor driveMotor) => driveMotor.title == title,
      orElse: () =>
          throw Exception("Got an undefined drive motor type, $title"),
    ),
  );
  final Map<RobotMatchStatus, int> robotMatchStatuses = parseTable(
    enums["robot_match_status"]!,
    (final String title) => RobotMatchStatus.values.firstWhere(
      (final RobotMatchStatus robotMatchStatus) =>
          robotMatchStatus.title == title,
      orElse: () =>
          throw Exception("Got an undefined robot match status type, $title"),
    ),
  );
  final Map<FaultStatus, int> faultStatus = parseTable(
    enums["fault_status"]!,
    (final String title) => FaultStatus.values.firstWhere(
      (final FaultStatus faultStatus) => faultStatus.title == title,
      orElse: () => throw Exception("Got an undefined fault status, $title"),
    ),
  );
  final List<ScheduleMatch> matches = await fetchMatches();
  final List<LightTeam> teams = await fetchTeams();

  runApp(
    App(
      matches: matches,
      faultStatus: faultStatus,
      matchTypeIds: matchTypes,
      teams: teams,
      drivetrainIds: driveTrains,
      balanceIds: balances,
      driveMotorIds: driveMotors,
      robotMatchStatusIds: robotMatchStatuses,
    ),
  );
}
