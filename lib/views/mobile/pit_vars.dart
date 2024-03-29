import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class PitVars implements HasuraVars {
  int? driveTrainType;
  int? driveMotorType;
  int driveMotorAmount = 2;
  bool? hasShifter;
  bool? gearboxPurchased;
  String notes = "";
  String? driveWheelType;
  int? teamId;
  String length = "";
  String width = "";
  String spaceBetweenWheels = "";
  String weight = "";
  bool tippedConesIntake = false;
  bool canScoreTop = false;
  bool groundIntake = false;
  bool singleSubIntake = false;
  bool doubleSubIntake = false;
  @override
  Map<String, dynamic> toHasuraVars() => <String, dynamic>{
        "drivetrain_id": driveTrainType,
        "drivemotor_id": driveMotorType,
        "drive_motor_amount": driveMotorAmount,
        "has_shifter": hasShifter,
        "gearbox_purchased": gearboxPurchased,
        "notes": notes,
        "drive_wheel_type": driveWheelType ?? "",
        "team_id": teamId,
        "width": int.parse(width),
        "length": int.parse(length),
        "space_between_wheels": int.parse(spaceBetweenWheels),
        "weight": int.parse(weight),
        "tipped_cones_intake": tippedConesIntake,
        "can_score_top": canScoreTop,
        "typical_ground_intake": groundIntake,
        "typical_single_intake": singleSubIntake,
        "typical_double_intake": doubleSubIntake,
      };

  void reset() {
    driveTrainType = null;
    driveMotorType = null;
    driveMotorAmount = 2;
    hasShifter = null;
    gearboxPurchased = null;
    notes = "";
    driveWheelType = null;
    teamId = null;
    weight = "";
    width = "";
    spaceBetweenWheels = "";
    length = "";
    tippedConesIntake = false;
    canScoreTop = false;
    groundIntake = false;
    singleSubIntake = false;
    doubleSubIntake = false;
  }
}
