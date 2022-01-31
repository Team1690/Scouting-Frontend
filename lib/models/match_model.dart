import "package:flutter/cupertino.dart";
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
  });

  void clear() {
    team = null;
    matchNumber = -1;
    autoHigh = 0;
    autoLow = 0;
    autoMissed = 0;
    teleHigh = 0;
    teleMissed = 0;
    teleLow = 0;
    climbStatus = null;
  }

  int? matchNumber;

  int autoHigh;
  int autoMissed;
  int autoLow;

  int teleHigh;
  int teleMissed;
  int teleLow;

  int? climbStatus;

  LightTeam? team;
  @override
  Map<String, dynamic> toHasuraVars(final BuildContext context) {
    return <String, dynamic>{
      "auto_lower": autoLow,
      "auto_upper": autoHigh,
      "auto_missed": autoMissed,
      "climb_id": climbStatus,
      "match_number": matchNumber!,
      "team_id": team?.id,
      "tele_lower": teleLow,
      "tele_upper": teleHigh,
      "tele_missed": teleMissed
    };
  }
}
