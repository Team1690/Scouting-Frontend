import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class Match implements HasuraVars {
  Match({
    this.team,
    this.matchNumber,
    this.autoHigh = 0,
    this.autoLow = 0,
    this.autoMissed = 0,
    this.teleHigh = 0,
    this.teleMissed = 0,
    this.teleLow = 0,
    required this.robotMatchStatusId,
  });

  void clear(final BuildContext context) {
    team = null;
    matchNumber = -1;
    autoHigh = 0;
    autoLow = 0;
    autoMissed = 0;
    teleHigh = 0;
    teleMissed = 0;
    teleLow = 0;
    climbStatus = null;
    name = null;
    matchTypeId = null;
    robotMatchStatusId =
        IdProvider.of(context).robotMatchStatus.nameToId["Worked"]!;
  }

  int? matchNumber;

  int autoHigh;
  int autoMissed;
  int autoLow;
  int? matchTypeId;
  int teleHigh;
  int teleMissed;
  int teleLow;
  String? name;
  int? climbStatus;
  int robotMatchStatusId;

  LightTeam? team;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "auto_lower": autoLow,
      "auto_upper": autoHigh,
      "auto_missed": autoMissed,
      "climb_id": climbStatus,
      "match_number": matchNumber!,
      "team_id": team?.id,
      "tele_lower": teleLow,
      "tele_upper": teleHigh,
      "tele_missed": teleMissed,
      "scouter_name": name,
      "match_type_id": matchTypeId,
    };
  }
}
