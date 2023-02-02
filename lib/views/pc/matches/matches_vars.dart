import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";

class MatchesVars {
  MatchesVars({
    this.matchesIdToUpdate,
    this.matchNumber,
    this.blue0,
    this.blue1,
    this.blue2,
    this.blue3,
    this.happened = false,
    this.matchTypeId,
    this.red0,
    this.red1,
    this.red2,
    this.red3,
  });

  MatchesVars.fromScheduleMatch(
    final ScheduleMatch match,
  ) : this(
          blue0: match.blueAlliance[0],
          blue1: match.blueAlliance[1],
          blue2: match.blueAlliance[2],
          blue3: match.blueAlliance.length == 4 ? match.blueAlliance[3] : null,
          happened: match.happened,
          matchNumber: match.matchNumber,
          matchTypeId: match.matchTypeId,
          matchesIdToUpdate: match.id,
          red0: match.redAlliance[0],
          red1: match.redAlliance[1],
          red2: match.redAlliance[2],
          red3: match.redAlliance.length == 4 ? match.redAlliance[3] : null,
        );
  int? matchNumber;
  int? matchTypeId;
  final int? matchesIdToUpdate;
  LightTeam? blue0;
  LightTeam? blue1;
  LightTeam? blue2;
  LightTeam? blue3;
  LightTeam? red0;
  LightTeam? red1;
  LightTeam? red2;
  LightTeam? red3;
  bool happened;

  void reset() {
    matchNumber = null;
    matchTypeId = null;
    blue0 = null;
    blue1 = null;
    blue2 = null;
    blue3 = null;
    red0 = null;
    red1 = null;
    red2 = null;
    red3 = null;
    happened = false;
  }
}
