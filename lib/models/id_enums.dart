enum RobotMatchStatus {
  worked,
  didntComeToField,
  didntWorkOnField,
}

enum DriveMotor { falcon, neo, cim, miniCim, other }

enum DriveTrain { swerve, westCoast, kitChassis, customTank, mecanumOrH, other }

enum Balance { noAttempt, failed, unbalanced, balanced }

enum FaultStatus { fixed, unknown, inProgress, noProgress }

enum MatchType {
  quals,
  quarterFinals,
  semiFinals,
  finals,
  roundRobin,
  practice,
  preScouting,
  einsteinFinals
}
