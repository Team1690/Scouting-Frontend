import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class MatchesVars implements HasuraVars {
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
          blue0: match.blue0,
          blue1: match.blue1,
          blue2: match.blue2,
          blue3: match.blue3,
          happened: match.happened,
          matchNumber: match.matchNumber,
          matchTypeId: match.matchTypeId,
          matchesIdToUpdate: match.id,
          red0: match.red0,
          red1: match.red1,
          red2: match.red2,
          red3: match.red3,
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
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      if (matchesIdToUpdate != null) "id": matchesIdToUpdate,
      "match": <String, dynamic>{
        "match_number": matchNumber,
        "match_type_id": matchTypeId,
        "blue_0_id": blue0?.id,
        "blue_1_id": blue1?.id,
        "blue_2_id": blue2?.id,
        "blue_3_id": blue3?.id,
        "red_0_id": red0?.id,
        "red_1_id": red1?.id,
        "red_2_id": red2?.id,
        "red_3_id": red3?.id,
        "happened": happened,
      }
    };
  }

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
