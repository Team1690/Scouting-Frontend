import "package:scouting_frontend/models/team_model.dart";

class ScheduleMatch {
  ScheduleMatch({
    required this.matchNumber,
    required this.matchTypeId,
    required this.id,
    required this.happened,
    required this.redAlliance,
    required this.blueAlliance,
  });
  final bool happened;
  final int id;
  final int matchNumber;
  final int matchTypeId;
  final List<LightTeam> redAlliance;
  final List<LightTeam> blueAlliance;
}
