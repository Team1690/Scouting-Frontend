enum RobotMatchStatus {
  worked("Worked"),
  didntComeToField("Didn't come to field"),
  didntWorkOnField("Didn't work on field");

  const RobotMatchStatus(this.title);
  final String title;
}

enum DriveMotor {
  falcon("Falcon"),
  neo("NEO"),
  cim("CIM"),
  miniCim("Mini CIM"),
  other("Other");

  const DriveMotor(this.title);
  final String title;
}

enum DriveTrain {
  swerve("Swerve"),
  westCoast("West Coast"),
  kitChassis("Kit Chassis"),
  customTank("Custom Tank"),
  mecanumOrH("Mecanum/H"),
  other("Other");

  const DriveTrain(this.title);
  final String title;
}

enum Balance {
  noAttempt("No Attempt"),
  failed("Failed"),
  unbalanced("Unbalanced"),
  balanced("Balanced");

  const Balance(this.title);
  final String title;
}

enum FaultStatus {
  fixed("Fixed"),
  unknown("Unknown"),
  inProgress("In progress"),
  noProgress("No progress");

  const FaultStatus(this.title);
  final String title;
}

enum MatchType {
  quals("Quals"),
  quarterFinals("Quarter finals"),
  semiFinals("Semi finals"),
  finals("Finals"),
  roundRobin("Round robin"),
  practice("Practice"),
  preScouting("Pre scouting"),
  einsteinFinals("Einstein finals");

  const MatchType(this.title);
  final String title;
}
