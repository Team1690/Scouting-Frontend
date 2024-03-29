import "dart:io";

import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/fetch_matches.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/app.dart";

import "package:scouting_frontend/firebase_options.dart";
import "package:scouting_frontend/models/id_helpers.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb || Platform.isAndroid || Platform.isMacOS || Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  final Map<String, Map<String, int>> enums = await fetchEnums(<String>[
    "_2023_balance",
    "drivetrain",
    "drivemotor",
    "robot_match_status",
    "fault_status",
    "_2023_starting_position",
    "defense",
  ], <String>[
    "match_type",
  ]);

  final Map<String, int> balances = enums["_2023_balance"]!;
  final Map<String, int> driveTrains = enums["drivetrain"]!;
  final Map<String, int> driveMotors = enums["drivemotor"]!;
  final Map<String, int> matchTypes = enums["match_type"]!;
  final Map<String, int> robotMatchStatuses = enums["robot_match_status"]!;
  final Map<String, int> faultStatus = enums["fault_status"]!;
  final Map<String, int> startingPositionIds =
      enums["_2023_starting_position"]!;
  final Map<String, int> defense = enums["defense"]!;
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
      startingPositionIds: startingPositionIds,
      defense: defense,
    ),
  );
}
