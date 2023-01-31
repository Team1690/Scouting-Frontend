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
  final Map<String, Map<String, dynamic>> enums = await fetchEnums(<String>[
    "_2023_balance",
    "drivetrain",
    "drivemotor",
    "robot_match_status",
    "fault_status",
    "match_type"
  ]);

  final Map<MatchType, int> matchTypes =
      parseTable(enums["match_type"]!, "match_type", (final String title) {
    switch (title) {
      case "Quals":
        return MatchType.quals;
      case "Quarter finals":
        return MatchType.quarterFinals;
      case "Semi finals":
        return MatchType.semiFinals;
      case "Finals":
        return MatchType.finals;
      case "Round robin":
        return MatchType.roundRobin;
      case "Practice":
        return MatchType.practice;
      case "Pre scouting":
        return MatchType.preScouting;
      case "Einstein finals":
        return MatchType.einsteinFinals;
    }
    throw Exception("Got an undefined match type");
  });

  final Map<Balance, int> balances = parseTable(
      enums["_2023_balance"]!, "_2023_balance", (final String title) {
    switch (title) {
      case "No Attempt":
        return Balance.noAttempt;
      case "Failed":
        return Balance.failed;
      case "Unbalanced":
        return Balance.unbalanced;
      case "Balanced":
        return Balance.balanced;
    }
    throw Exception("");
  });
  final Map<DriveTrain, int> driveTrains =
      parseTable(enums["drivetrain"]!, "drivetrain", (final String title) {
    switch (title) {
      case "Swerve":
        return DriveTrain.swerve;
      case "West Coast":
        return DriveTrain.westCoast;
      case "Kit Chassis":
        return DriveTrain.kitChassis;
      case "Custom Tank":
        return DriveTrain.customTank;
      case "Mecanum/H":
        return DriveTrain.mecanumOrH;
      case "Other":
        return DriveTrain.other;
    }
    throw Exception("Got an undefined drive train type");
  });
  final Map<DriveMotor, int> driveMotors =
      parseTable(enums["drivemotor"]!, "drivemotor", (final String title) {
    switch (title) {
      case "Falcon":
        return DriveMotor.falcon;
      case "NEO":
        return DriveMotor.neo;
      case "CIM":
        return DriveMotor.cim;
      case "Mini CIM":
        return DriveMotor.miniCim;
      case "Other":
        return DriveMotor.other;
    }
    throw Exception("Got an undefined drive motor type");
  });
  final Map<RobotMatchStatus, int> robotMatchStatuses = parseTable(
      enums["robot_match_status"]!, "robot_match_status", (final String title) {
    switch (title) {
      case "Worked":
        return RobotMatchStatus.worked;
      case "Didn't come to field":
        return RobotMatchStatus.didntComeToField;
      case "Didn't work on field":
        return RobotMatchStatus.didntWorkOnField;
    }
    throw Exception("");
  });
  final Map<FaultStatus, int> faultStatus =
      parseTable(enums["fault_status"]!, "fault_status", (final String title) {
    switch (title) {
      case "Fixed":
        return FaultStatus.fixed;
      case "Unknown":
        return FaultStatus.unknown;
      case "In progress":
        return FaultStatus.inProgress;
      case "No progress":
        return FaultStatus.noProgress;
    }
    throw Exception("Got an undefined fault status");
  });
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
