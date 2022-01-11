import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class PitVars implements HasuraVars {
  String driveTrainType = driveTrainInitialValue;
  String driveMotorType = driveMotorInitialValue;
  int driveMotorAmount = 2;
  String shifter = "Not Answered";
  String gearbox = "Not Answered";
  String notes = "";
  String driveWheelType = "";
  double driveTrainReliability = 1;
  double electronicsReliability = 1;
  double robotReliability = 1;
  int? teamId;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "drive_train_type": driveTrainType,
      "drive_motor_type": driveMotorType,
      "drive_motor_amount": driveMotorAmount,
      "shifter": shifter,
      "gearbox": gearbox,
      "notes": notes,
      "drive_wheel_type": driveWheelType,
      "drive_train_reliability": driveTrainReliability,
      "electronics_reliability": electronicsReliability,
      "robot_reliability": robotReliability,
      "team_id": teamId
    };
  }

  void reset() {
    driveTrainType = driveTrainInitialValue;
    driveMotorType = driveMotorInitialValue;
    driveMotorAmount = 2;
    shifter = "No Shifter Selected";
    gearbox = "No Gearbox Selected";
    notes = "";
    driveWheelType = "";
    driveTrainReliability = 1.0;
    electronicsReliability = 1.0;
    robotReliability = 1.0;
    teamId = null;
  }

  static const String driveTrainInitialValue = "Choose a DriveTrain";
  static const String driveMotorInitialValue = "Choose a Drive Motor";
}
