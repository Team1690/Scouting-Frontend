import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

import "map_nullable.dart";

class TechnicalMatch implements HasuraVars {
  TechnicalMatch({
    this.autoConesTop = 0,
    this.autoConesMid = 0,
    this.autoConesLow = 0,
    this.autoCubesTop = 0,
    this.autoCubesMid = 0,
    this.autoCubesLow = 0,
    this.teleConesTop = 0,
    this.teleConesMid = 0,
    this.teleConesLow = 0,
    this.teleCubesTop = 0,
    this.teleCubesMid = 0,
    this.teleCubesLow = 0,
    this.scoutedTeam,
    required this.robotMatchStatusId,
    this.isRematch = false,
    this.startingPosId,
  });

  void clear(final BuildContext context) {
    autoConesTop = 0;
    autoConesMid = 0;
    autoConesLow = 0;
    autoCubesTop = 0;
    autoCubesMid = 0;
    autoCubesLow = 0;
    teleConesTop = 0;
    teleConesMid = 0;
    teleConesLow = 0;
    teleCubesTop = 0;
    teleCubesMid = 0;
    teleCubesLow = 0;
    autoBalanceStatus = null;
    endgameBalanceStatus = null;
    scoutedTeam = null;
    scheduleMatch = null;
    isRematch = false;
    robotMatchStatusId =
        IdProvider.of(context).robotMatchStatus.nameToId["Worked"]!;
    startingPosId = null;
  }

  bool preScouting = false;
  bool isRematch;
  ScheduleMatch? scheduleMatch;
  int autoConesTop;
  int autoConesMid;
  int autoConesLow;
  int autoCubesTop;
  int autoCubesMid;
  int autoCubesLow;
  int teleConesTop;
  int teleConesMid;
  int teleConesLow;
  int teleCubesTop;
  int teleCubesMid;
  int teleCubesLow;
  String? name;
  int? autoBalanceStatus;
  int? endgameBalanceStatus;
  int robotMatchStatusId;
  int? startingPosId;

  LightTeam? scoutedTeam;
  @override
  Map<String, dynamic> toHasuraVars() => <String, dynamic>{
        "auto_cones_mid": autoConesMid,
        "auto_cones_top": autoConesTop,
        "auto_cones_low": autoConesLow,
        "auto_cubes_mid": autoCubesMid,
        "auto_cubes_top": autoCubesTop,
        "auto_cubes_low": autoCubesLow,
        "auto_balance_id": autoBalanceStatus,
        "endgame_balance_id": endgameBalanceStatus,
        "team_id": scoutedTeam?.id,
        "tele_cones_mid": teleConesMid,
        "tele_cones_top": teleConesTop,
        "tele_cones_low": teleConesLow,
        "tele_cubes_mid": teleCubesMid,
        "tele_cubes_top": teleCubesTop,
        "tele_cubes_low": teleCubesLow,
        "scouter_name": name,
        "schedule_match_id": scheduleMatch?.id,
        "robot_match_status_id": robotMatchStatusId,
        "is_rematch": isRematch,
        "starting_position_id": startingPosId,
      };
}

enum MatchMode {
  auto(1, "auto"),
  tele(0, "tele");

  const MatchMode(this.pointAddition, this.title);
  final int pointAddition;
  final String title;
}

enum Gamepiece {
  cone("cones"),
  cube("cubes");

  const Gamepiece(this.title);
  final String title;
}

enum GridLevel {
  top(5, "top"),
  mid(3, "mid"),
  low(2, "low");

  const GridLevel(this.points, this.title);
  final int points;
  final String title;
}

class EffectiveScore {
  const EffectiveScore({
    required this.mode,
    required this.piece,
    required this.level,
  });
  final MatchMode mode;
  final Gamepiece piece;
  final GridLevel? level;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        mode,
        piece,
        level,
      ]);

  @override
  bool operator ==(final Object other) =>
      other is EffectiveScore &&
      other.level == level &&
      other.mode == mode &&
      other.piece == piece;
}

List<EffectiveScore> coneAndCube(final GridLevel level, final MatchMode mode) =>
    <EffectiveScore>[
      EffectiveScore(
        mode: mode,
        piece: Gamepiece.cone,
        level: level,
      ),
      EffectiveScore(
        mode: mode,
        piece: Gamepiece.cube,
        level: level,
      ),
    ];

List<EffectiveScore> allLevel(final MatchMode mode) => <EffectiveScore>[
      ...GridLevel.values
          .map((final GridLevel level) => coneAndCube(level, mode))
          .expand(identity)
          .toList()
    ];

final Map<EffectiveScore, int> score = <EffectiveScore, int>{
  ...MatchMode.values.map(allLevel).expand(identity).toList().asMap().map(
        (final _, final EffectiveScore effectiveScore) =>
            MapEntry<EffectiveScore, int>(
          effectiveScore,
          effectiveScore.level!.points +
              effectiveScore.mode
                  .pointAddition, //this can be null since we define each EffectiveScore here to have a level (aka not missed)
        ),
      )
};

double getPoints(final Map<EffectiveScore, double> countedValues) =>
    countedValues.keys.fold(
      0,
      (final double points, final EffectiveScore effectiveScore) =>
          countedValues[effectiveScore]! * score[effectiveScore]! + points,
    );

double getPieces(final Map<EffectiveScore, double> countedValues) =>
    countedValues.keys.fold(
      0,
      (final double gamepieces, final EffectiveScore effectiveScore) =>
          countedValues[effectiveScore]! + gamepieces,
    );

Map<EffectiveScore, double> parseByMode(
  final MatchMode mode,
  final dynamic data,
) =>
    Map<EffectiveScore, double>.fromEntries(
      allLevel(mode).map(
        (final EffectiveScore e) => MapEntry<EffectiveScore, double>(
          e,
          data["${e.mode.title}_${e.piece.title}_${e.level!.title}"] as double,
        ),
      ),
    ); //we define these values, therefore they are not null (see 'allLevel()')

Map<EffectiveScore, double> parseMatch(
  final dynamic data,
) =>
    <EffectiveScore, double>{
      ...parseByMode(MatchMode.auto, data),
      ...parseByMode(MatchMode.tele, data)
    };
