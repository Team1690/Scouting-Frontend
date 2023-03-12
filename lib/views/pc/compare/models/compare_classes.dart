import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class CompareTeam {
  CompareTeam({
    required this.avgEndgameBalancePoints,
    required this.autoBalanceSuccessPercentage,
    required this.avgAutoBalancePoints,
    required this.endgameBalanceSuccessPercentage,
    required this.teleGamepieces,
    required this.autoBalanceVals,
    required this.gamepieces,
    required this.endgameBalanceVals,
    required this.team,
    required this.autoGamepieces,
    required this.totalCones,
    required this.totalCubes,
    required this.avgCycleTime,
    required this.avgFeederTime,
    required this.avgPlacingTime,
    required this.cycleAmount,
    required this.cycleTime,
    required this.feederTime,
    required this.placeTime,
  });
  final LightTeam team;

  final double autoBalanceSuccessPercentage;
  final double endgameBalanceSuccessPercentage;
  final double avgEndgameBalancePoints;
  final double avgAutoBalancePoints;
  final double avgCycleTime;
  final double avgPlacingTime;
  final double avgFeederTime;
  final CompareLineChartData autoGamepieces;
  final CompareLineChartData teleGamepieces;
  final CompareLineChartData gamepieces;
  final CompareLineChartData autoBalanceVals;
  final CompareLineChartData endgameBalanceVals;
  final CompareLineChartData totalCones;
  final CompareLineChartData totalCubes;
  final CompareLineChartData cycleAmount;
  final CompareLineChartData cycleTime;
  final CompareLineChartData feederTime;
  final CompareLineChartData placeTime;
}

class CompareLineChartData {
  CompareLineChartData({
    required this.points,
    required this.matchStatuses,
  });
  final List<int> points;
  final List<RobotMatchStatus> matchStatuses;
}
