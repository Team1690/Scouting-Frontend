import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class Match implements HasuraVars {
  Match({
    this.team,
    this.autoHigh = 0,
    this.autoLow = 0,
    this.autoMissed = 0,
    this.teleHigh = 0,
    this.teleMissed = 0,
    this.teleLow = 0,
    required this.robotMatchStatusId,
    this.isRematch = false,
  });

  void clear(final BuildContext context) {
    team = null;
    match = null;
    autoHigh = 0;
    autoLow = 0;
    autoMissed = 0;
    teleHigh = 0;
    teleMissed = 0;
    teleLow = 0;
    climbStatus = null;
    isRematch = false;
    robotMatchStatusId =
        IdProvider.of(context).robotMatchStatus.nameToId["Worked"]!;
  }

  bool preScouting = false;
  bool isRematch;
  ScheduleMatch? match;
  int autoHigh;
  int autoMissed;
  int autoLow;
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
      "team_id": team?.id,
      "tele_lower": teleLow,
      "tele_upper": teleHigh,
      "tele_missed": teleMissed,
      "scouter_name": name,
      "matches_id": match?.id,
      "robot_match_status_id": robotMatchStatusId,
      "is_rematch": isRematch,
    };
  }
}
