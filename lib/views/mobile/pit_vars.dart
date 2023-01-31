import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class PitVars implements HasuraVars {
  int? driveTrainType;
  int? driveMotorType;
  int driveMotorAmount = 2;
  bool? hasShifter;
  bool? gearboxPurchased;
  String notes = "";
  String driveWheelType = "";
  int? teamId;
  String length = "";
  String width = "";
  String weight = "";
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
      "team_id": teamId,
      "width": width,
      "length": length,
      "weight": weight,
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
    teamId = null;
    weight = "";
    width = "";
    length = "";
  }
}
