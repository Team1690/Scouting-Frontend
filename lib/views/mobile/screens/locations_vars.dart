import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class LocationVars implements HasuraVars {
  LocationVars({
    this.isRematch = false,
    this.startingLocationId,
    required this.robotMatchStatusId,
    this.scheduleMatch,
    this.team,
  });
  void clear(final BuildContext context) {
    scheduleMatch = null;
    team = null;
    startingLocationId = null;
    robotMatchStatusId =
        IdProvider.of(context).robotMatchStatus.nameToId["Worked"] as int;
    isRematch = false;
  }

  LightTeam? team;
  ScheduleMatch? scheduleMatch;
  String scouterName = "";
  int? startingLocationId;
  bool isRematch = false;
  int robotMatchStatusId;

  @override
  Map<String, dynamic> toHasuraVars() => <String, dynamic>{
        "scouter_name": scouterName,
        "is_rematch": isRematch,
        "starting_position_id": startingLocationId,
        "robot_match_status_id": robotMatchStatusId,
        "schedule_match_id": scheduleMatch?.id,
        "team_id": team?.id,
      };
}
