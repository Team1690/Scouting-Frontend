import "package:scouting_frontend/models/team_model.dart";

class QuickData {
  QuickData({
    required this.avgAutoLowScored,
    required this.avgAutoMissed,
    required this.avgAutoUpperScored,
    required this.avgBallPoints,
    required this.avgClimbPoints,
    required this.avgTeleLowScored,
    required this.avgTeleMissed,
    required this.avgTeleUpperScored,
    required this.scorePercentAuto,
    required this.scorePercentTele,
  });
  final double avgBallPoints;
  final double avgClimbPoints;
  final double avgAutoUpperScored;
  final double avgAutoMissed;
  final double avgAutoLowScored;
  final double scorePercentAuto;
  final double avgTeleUpperScored;
  final double avgTeleMissed;
  final double avgTeleLowScored;
  final double scorePercentTele;
}

class SpecificData {
  SpecificData(this.msg);
  final List<String> msg;
}

class LineChartData<E extends num> {
  LineChartData({
    required this.points,
    required this.title,
    required this.gameNumbers,
  });
  List<List<E>> points;
  List<int> gameNumbers;
  String title = "";
}

class PitData {
  PitData({
    required this.driveTrainType,
    required this.driveMotorAmount,
    required this.driveMotorType,
    required this.driveTrainReliability,
    required this.driveWheelType,
    required this.electronicsReliability,
    required this.gearboxPurchased,
    required this.notes,
    required this.robotReliability,
    required this.hasShifer,
    required this.url,
  });
  final String driveTrainType;
  final int driveMotorAmount;
  final String driveWheelType;
  final bool? hasShifer;
  final bool? gearboxPurchased;
  final String driveMotorType;
  final int driveTrainReliability;
  final int electronicsReliability;
  final int robotReliability;
  final String notes;
  final String url;
}

class Team<E extends num> {
  Team({
    required this.team,
    required this.specificData,
    required this.pitViewData,
    required this.quickData,
    required this.climbData,
    required this.scoredMissedDataTele,
    required this.scoredMissedDataAuto,
  });
  final LightTeam team;
  final SpecificData specificData;
  final PitData? pitViewData;
  final QuickData quickData;
  final LineChartData<E> climbData;
  final LineChartData<E> scoredMissedDataTele;
  final LineChartData<E> scoredMissedDataAuto;
}