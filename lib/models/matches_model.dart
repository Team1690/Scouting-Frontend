import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/models/map_nullable.dart";

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

  String? getTeamStation(final LightTeam team) {
    int? indexOf(final bool isRed) {
      final int index =
          isRed ? redAlliance.indexOf(team) : blueAlliance.indexOf(team);
      return index == -1 ? null : index;
    }

    return (indexOf(true).mapNullable((final int i) => "red ${i + 1}")) ??
        (indexOf(false).mapNullable((final int i) => "blue ${i + 1}"));
  }
}
