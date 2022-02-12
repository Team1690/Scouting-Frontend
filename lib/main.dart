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
  if (kIsWeb || Platform.isAndroid) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  final Map<String, int> climbs = await fetchEnum("climb_2022");
  final Map<String, int> driveTrains = await fetchEnum("drivetrain");
  final Map<String, int> driveMotors = await fetchEnum("drivemotor");
  final List<LightTeam> teams = await fetchTeams();

  runApp(
    App(
      teams: teams,
      drivetrainIds: driveTrains,
      climdIds: climbs,
      driveMotorIds: driveMotors,
    ),
  );
}
