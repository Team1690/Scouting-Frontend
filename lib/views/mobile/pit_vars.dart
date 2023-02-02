class PitVars {
  int? driveTrainType;
  int? driveMotorType;
  int driveMotorAmount = 2;
  bool? hasShifter;
  bool? gearboxPurchased;
  String notes = "";
  String driveWheelType = "";
  String length = "";
  String width = "";
  String weight = "";

  void reset() {
    driveTrainType = null;
    driveMotorType = null;
    driveMotorAmount = 2;
    hasShifter = null;
    gearboxPurchased = null;
    notes = "";
    driveWheelType = "";
    weight = "";
    width = "";
    length = "";
  }
}
