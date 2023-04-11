import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class SpecificVars implements HasuraVars {
  LightTeam? team;
  String? drivetrainAndDriving;
  String? intake;
  String? placement;
  String? defense;
  String? generalNotes;
  ScheduleMatch? scheduleMatch;
  String name = "";
  bool isRematch = false;
  int defenseAmount = 1;

  String? faultMessage;
  @override
  Map<String, dynamic> toHasuraVars() => <String, dynamic>{
        "team_id": team?.id,
        "drivetrain_and_driving": drivetrainAndDriving,
        "intake": intake,
        "placement": placement,
        "defense": defense,
        "general_notes": generalNotes,
        "is_rematch": isRematch,
        "schedule_match_id": scheduleMatch?.id,
        "scouter_name": name,
        "defense_amount_id": defenseAmount,
        if (faultMessage != null) "match_number": scheduleMatch?.matchNumber,
        if (faultMessage != null) "match_type_id": scheduleMatch?.matchTypeId,
        if (faultMessage != null) "fault_message": faultMessage,
      };

  void reset(final BuildContext context) {
    isRematch = false;
    scheduleMatch = null;
    faultMessage = null;
    team = null;
    drivetrainAndDriving = null;
    intake = null;
    placement = null;
    defense = null;
    generalNotes = null;
    defenseAmount = IdProvider.of(context).defense.nameToId["No Defense"]!;
  }
}
