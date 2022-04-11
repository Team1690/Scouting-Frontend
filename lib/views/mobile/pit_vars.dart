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
  bool? canPassLowRung;
  int weight = 0;
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
      "can_pass_low_rung": canPassLowRung,
      "weight": weight
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
    weight = 0;
  }
}
