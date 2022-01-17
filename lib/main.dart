import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:scouting_frontend/views/app.dart";
import "package:scouting_frontend/views/mobile/team_selection_future.dart";

import "firebase_options.dart";
import "models/id_helpers.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: "dev.env");
  ClimbHelper.queryclimbId();
  DrivetrainHelper.queryDrivetrainId();
  DriveMotorHelper.queryDrivemotorId();
  TeamHelper.fetchTeams().then<void>((final void _) => runApp(App()));
}
