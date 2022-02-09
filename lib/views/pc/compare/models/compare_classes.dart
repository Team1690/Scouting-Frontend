import "package:scouting_frontend/models/team_model.dart";

class CompareTeam<E extends num> {
  CompareTeam({
    required this.autoUpperScoredPercentage,
    required this.avgAutoUpperScored,
    required this.avgClimbPoints,
    required this.avgTeleUpperScored,
    required this.climbPercentage,
    required this.teleUpperScoredPercentage,
    required this.climbData,
    required this.upperScoredDataAuto,
    required this.upperScoredDataTele,
    required this.missedDataAuto,
    required this.missedDataTele,
    required this.team,
  });
  final LightTeam team;
  final double avgAutoUpperScored;
  final double autoUpperScoredPercentage;
  final double avgTeleUpperScored;
  final double teleUpperScoredPercentage;
  final double avgClimbPoints;
  final double climbPercentage;
  final CompareLineChartData<E> climbData;
  final CompareLineChartData<E> upperScoredDataTele;
  final CompareLineChartData<E> missedDataTele;
  final CompareLineChartData<E> upperScoredDataAuto;
  final CompareLineChartData<E> missedDataAuto;
}

class CompareLineChartData<E extends num> {
  CompareLineChartData({required this.points, required this.title});
  final String title;
  final List<E> points;
}