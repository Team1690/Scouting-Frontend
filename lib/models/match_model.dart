import "package:graphql/client.dart";
import 'package:scouting_frontend/models/team_model.dart';
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

import 'id_helpers.dart';

class Match implements HasuraVars {
  Match({
    this.team,
    this.matchNumber,
    this.autoHigh = 0,
    this.autoLow = 0,
    this.autoHighMissed = 0,
    this.teleHigh = 0,
    this.teleHighMissed = 0,
    this.teleLow = 0,
    this.climbStatus = "Choose a climb result",
  });

  @override
  String toString() {
    return """
    number: $matchNumber
    auto: $autoHigh $autoHighMissed $autoLow
    tele: $teleHigh $teleHighMissed $teleLow
    climb: $climbStatus ${ClimbHelper.climbId(climbStatus)}
    """;
  }

  void clear() {
    team = null;
    matchNumber = -1;
    autoHigh = 0;
    autoLow = 0;
    autoHighMissed = 0;
    teleHigh = 0;
    teleHighMissed = 0;
    teleLow = 0;
    climbStatus = "Choose a climb result";
  }

  int? matchNumber;

  int autoHigh;
  int autoHighMissed;
  int autoLow;

  int teleHigh;
  int teleHighMissed;
  int teleLow;

  String climbStatus;

  LightTeam? team;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "auto_lower": autoLow,
      "auto_upper": autoHigh,
      "auto_upper_missed": autoHighMissed,
      "climb_id": ClimbHelper.climbId(climbStatus),
      "match_number": matchNumber!,
      "team_id": team?.id,
      "tele_lower": teleLow,
      "tele_upper": teleHigh,
      "tele_upper_missed": teleHighMissed
    };
  }
}
