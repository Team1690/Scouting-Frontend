import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class PitVars implements HasuraVars {
  int? driveTrainType;
  int? driveMotorType;
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
  Map<String, dynamic> toHasuraVars(final BuildContext context) {
    return <String, dynamic>{
      "drivetrain_id": driveTrainType,
      "drivemotor_id": driveMotorType,
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
    driveTrainType = null;
    driveMotorType = null;
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
}
