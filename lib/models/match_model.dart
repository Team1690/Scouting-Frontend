import "dart:math";

import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class Match implements HasuraVars {
  Match({
    this.autoConesTop = 0,
    this.autoConesMid = 0,
    this.autoConesLow = 0,
    this.autoConesFailed = 0,
    this.autoCubesTop = 0,
    this.autoCubesMid = 0,
    this.autoCubesLow = 0,
    this.autoCubesFailed = 0,
    this.teleConesTop = 0,
    this.teleConesMid = 0,
    this.teleConesLow = 0,
    this.teleConesFailed = 0,
    this.teleCubesTop = 0,
    this.teleCubesMid = 0,
    this.teleCubesLow = 0,
    this.teleCubesFailed = 0,
    this.scoutedTeam,
    required this.robotMatchStatusId,
    this.isRematch = false,
  });

  void clear(final BuildContext context) {
    autoConesTop = 0;
    autoConesMid = 0;
    autoConesLow = 0;
    autoConesFailed = 0;
    autoCubesTop = 0;
    autoCubesMid = 0;
    autoCubesLow = 0;
    autoCubesFailed = 0;
    teleConesTop = 0;
    teleConesMid = 0;
    teleConesLow = 0;
    teleConesFailed = 0;
    teleCubesTop = 0;
    teleCubesMid = 0;
    teleCubesLow = 0;
    teleCubesFailed = 0;
    autoBalanceStatus = null;
    endgameBalanceStatus = null;
    scoutedTeam = null;
    scheduleMatch = null;
    isRematch = false;
    robotMatchStatusId =
        IdProvider.of(context).robotMatchStatus.nameToId["Worked"]!;
  }

  bool preScouting = false;
  bool isRematch;
  ScheduleMatch? scheduleMatch;
  int autoConesTop;
  int autoConesMid;
  int autoConesLow;
  int autoConesFailed;
  int autoCubesTop;
  int autoCubesMid;
  int autoCubesLow;
  int autoCubesFailed;
  int teleConesTop;
  int teleConesMid;
  int teleConesLow;
  int teleConesFailed;
  int teleCubesTop;
  int teleCubesMid;
  int teleCubesLow;
  int teleCubesFailed;
  String? name;
  int? autoBalanceStatus;
  int? endgameBalanceStatus;
  int robotMatchStatusId;

  LightTeam? scoutedTeam;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "auto_cones_mid": autoConesMid,
      "auto_cones_top": autoConesTop,
      "auto_cones_low": autoConesLow,
      "auto_cones_failed": autoConesFailed,
      "auto_cubes_mid": autoCubesMid,
      "auto_cubes_top": autoCubesTop,
      "auto_cubes_low": autoCubesLow,
      "auto_cubes_failed": autoCubesFailed,
      "auto_balance_id": autoBalanceStatus,
      "endgame_balance_id": endgameBalanceStatus,
      "team_id": scoutedTeam?.id,
      "tele_cones_mid": teleConesMid,
      "tele_cones_top": teleConesTop,
      "tele_cones_low": teleConesLow,
      "tele_cones_failed": teleConesFailed,
      "tele_cubes_mid": teleCubesMid,
      "tele_cubes_top": teleCubesTop,
      "tele_cubes_low": teleCubesLow,
      "tele_cubes_failed": teleCubesFailed,
      "scouter_name": name,
      "schedule_match_id": scheduleMatch?.id,
      "robot_match_status_id": robotMatchStatusId,
      "is_rematch": isRematch,
    };
  }
}

enum MatchMode { auto, tele }

enum Gamepiece { cone, cube }

enum GridLevel { top, mid, low }

class EffectiveScore {
  EffectiveScore({
    required this.mode,
    required this.piece,
    required this.level,
  });
  final MatchMode mode;
  final Gamepiece piece;
  final GridLevel? level;

  @override
  int get hashCode {
    return Object.hashAll(<Object?>[
      mode,
      piece,
      level,
    ]);
  }

  @override
  bool operator ==(final Object other) {
    return other is EffectiveScore &&
        other.level == level &&
        other.mode == mode &&
        other.piece == piece;
  }
}
