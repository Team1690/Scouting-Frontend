import "package:scouting_frontend/models/team_model.dart";

class ScheduleMatch {
  ScheduleMatch({
    required this.matchNumber,
    required this.matchTypeId,
    required this.red0,
    required this.red1,
    required this.red2,
    required this.red3,
    required this.blue0,
    required this.blue1,
    required this.blue2,
    required this.blue3,
    required this.id,
    required this.happened,
  });
  final bool happened;
  final int id;
  final int matchNumber;
  final int matchTypeId;
  final LightTeam red0;
  final LightTeam red1;
  final LightTeam red2;
  final LightTeam? red3;
  final LightTeam blue0;
  final LightTeam blue1;
  final LightTeam blue2;
  final LightTeam? blue3;
}
