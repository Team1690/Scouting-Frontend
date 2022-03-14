import "dart:io";

import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
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
  final Map<String, Map<String, int>> enums = await fetchEnums(
    <String>[
      "climb_2022",
      "drivetrain",
      "drivemotor",
      "match_type",
      "robot_match_status",
    ],
  );
  final Map<String, int> climbs = enums["climb_2022"]!;
  final Map<String, int> driveTrains = enums["drivetrain"]!;
  final Map<String, int> driveMotors = enums["drivemotor"]!;
  final Map<String, int> matchTypes = enums["match_type"]!;
  final Map<String, int> robotMatchStatuses = enums["robot_match_status"]!;
  final List<LightTeam> teams = await fetchTeams();

  runApp(
    App(
      matchTypeIds: matchTypes,
      teams: teams,
      drivetrainIds: driveTrains,
      climdIds: climbs,
      driveMotorIds: driveMotors,
      robotMatchStatusIds: robotMatchStatuses,
    ),
  );
}
