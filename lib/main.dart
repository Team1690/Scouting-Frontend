import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/match_model.dart';
import 'package:scouting_frontend/views/app.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ClimbHelper.queryclimbId();
  runApp(App());
}
