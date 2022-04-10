import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class CompareTeam {
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
    required this.allBallsScored,
    required this.pointsData,
  });
  final LightTeam team;
  final double avgAutoUpperScored;
  final double autoUpperScoredPercentage;
  final double avgTeleUpperScored;
  final double teleUpperScoredPercentage;
  final double avgClimbPoints;
  final double climbPercentage;
  final CompareLineChartData allBallsScored;
  final CompareLineChartData climbData;
  final CompareLineChartData upperScoredDataTele;
  final CompareLineChartData missedDataTele;
  final CompareLineChartData upperScoredDataAuto;
  final CompareLineChartData missedDataAuto;
  final CompareLineChartData pointsData;
}

class CompareLineChartData {
  CompareLineChartData({
    required this.points,
    required this.matchStatuses,
  });
  final List<int> points;
  final List<RobotMatchStatus> matchStatuses;
}
