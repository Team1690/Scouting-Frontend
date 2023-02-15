import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class CompareTeam {
  CompareTeam({
    required this.avgAutoGamepiecePoints,
    required this.avgTeleGamepiecesPoints,
    required this.avgEndgameBalancePoints,
    required this.autoBalanceSuccessPercentage,
    required this.avgAutoBalancePoints,
    required this.endgameBalanceSuccessPercentage,
    required this.teleGamepieces,
    required this.autoBalanceVals,
    required this.gamepieces,
    required this.endgameBalanceVals,
    required this.points,
    required this.team,
    required this.autoGamepieces,
    required this.totalCones,
    required this.totalCubes,
  });
  final LightTeam team;
  final double avgTeleGamepiecesPoints;
  final double avgAutoGamepiecePoints;
  final double autoBalanceSuccessPercentage;
  final double endgameBalanceSuccessPercentage;
  final double avgEndgameBalancePoints;
  final double avgAutoBalancePoints;
  final CompareLineChartData autoGamepieces;
  final CompareLineChartData teleGamepieces;
  final CompareLineChartData gamepieces;
  final CompareLineChartData points;
  final CompareLineChartData autoBalanceVals;
  final CompareLineChartData endgameBalanceVals;
  final CompareLineChartData totalCones;
  final CompareLineChartData totalCubes;
}

class CompareLineChartData {
  CompareLineChartData({
    required this.points,
    required this.matchStatuses,
  });
  final List<int> points;
  final List<RobotMatchStatus> matchStatuses;
}
