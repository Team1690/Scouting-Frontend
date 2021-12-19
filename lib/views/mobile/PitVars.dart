class PitVars {
  String driveTrainType = driveMotorInitialValue;
  String driveMotorType = driveMotorInitialValue;
  int driveMotorAmount = 2;
  String shifter;
  String gearbox;
  String notes = '';
  String driveWheelType;
  double driveTrainReliability = 1;
  double electronicsReliability = 1;
  double robotReliability = 1;
  int teamId;
  Map<String, dynamic> toHasuraVars() {
    return {
      'drive_train_type': driveTrainType,
      'drive_motor_type': driveMotorType,
      'drive_motor_amount': driveMotorAmount,
      'shifter': shifter,
      'gearbox': gearbox,
      'notes': notes,
      'drive_wheel_type': driveWheelType,
      'drive_train_reliability': driveTrainReliability,
      'electronics_reliability': driveTrainReliability,
      'robot_reliability': driveTrainReliability,
      'team_id': teamId
    };
  }

  void reset() {
    driveTrainType = driveTrainInitialValue;
    driveMotorType = driveMotorInitialValue;
    driveMotorAmount = 2;
    shifter = null;
    gearbox = null;
    notes = '';
    driveWheelType = '';
    driveTrainReliability = 1.0;
    electronicsReliability = 1.0;
    robotReliability = 1.0;
    teamId = null;
  }
}

const String driveTrainInitialValue = 'Choose a DriveTrain';
const String driveMotorInitialValue = 'Choose a Drive Motor';
