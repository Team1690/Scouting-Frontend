import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class PitVars implements HasuraVars {
  int? driveTrainType;
  int? driveMotorType;
  int driveMotorAmount = 2;
  bool? hasShifter;
  bool? gearboxPurchased;
  String notes = "";
  String driveWheelType = "";
  double driveTrainReliability = 1;
  double electronicsReliability = 1;
  double robotReliability = 1;
  int? teamId;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "drivetrain_id": driveTrainType,
      "drivemotor_id": driveMotorType,
      "drive_motor_amount": driveMotorAmount,
      "has_shifter": hasShifter,
      "gearbox_purchased": gearboxPurchased,
      "notes": notes,
      "drive_wheel_type": driveWheelType,
      "drive_train_reliability": driveTrainReliability,
      "electronics_reliability": electronicsReliability,
      "robot_reliability": robotReliability,
      "team_id": teamId
    };
  }

  void reset() {
    driveTrainType = null;
    driveMotorType = null;
    driveMotorAmount = 2;
    hasShifter = null;
    gearboxPurchased = null;
    notes = "";
    driveWheelType = "";
    driveTrainReliability = 1.0;
    electronicsReliability = 1.0;
    robotReliability = 1.0;
    teamId = null;
  }
}
