import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

import "map_nullable.dart";

class TechnicalMatch implements HasuraVars {
  TechnicalMatch({
    this.autoConesScored = 0,
    this.autoConesDelivered = 0,
    this.autoConesFailed = 0,
    this.autoCubesScored = 0,
    this.autoCubesDelivered = 0,
    this.autoCubesFailed = 0,
    this.teleConesScored = 0,
    this.teleConesDelivered = 0,
    this.teleConesFailed = 0,
    this.teleCubesScored = 0,
    this.teleCubesDelivered = 0,
    this.teleCubesFailed = 0,
    this.scoutedTeam,
    required this.robotMatchStatusId,
    this.isRematch = false,
  });

  void clear(final BuildContext context) {
    autoConesScored = 0;
    autoConesDelivered = 0;
    autoConesFailed = 0;
    autoCubesScored = 0;
    autoCubesDelivered = 0;
    autoCubesFailed = 0;
    teleConesScored = 0;
    teleConesDelivered = 0;
    teleConesFailed = 0;
    teleCubesScored = 0;
    teleCubesDelivered = 0;
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
  int autoConesScored;
  int autoConesFailed;
  int autoConesDelivered;
  int autoCubesScored;
  int autoCubesFailed;
  int autoCubesDelivered;
  int teleConesScored;
  int teleConesFailed;
  int teleConesDelivered;
  int teleCubesScored;
  int teleCubesFailed;
  int teleCubesDelivered;
  String? name;
  int? autoBalanceStatus;
  int? endgameBalanceStatus;
  int robotMatchStatusId;

  LightTeam? scoutedTeam;
  @override
  Map<String, dynamic> toHasuraVars() => <String, dynamic>{
        "auto_cones_delivered": autoConesDelivered,
        "auto_cones_scored": autoConesScored,
        "auto_cones_failed": autoConesFailed,
        "auto_cubes_delivered": autoCubesDelivered,
        "auto_cubes_scored": autoCubesScored,
        "auto_cubes_failed": autoCubesFailed,
        "auto_balance_id": autoBalanceStatus,
        "endgame_balance_id": endgameBalanceStatus,
        "team_id": scoutedTeam?.id,
        "tele_cones_delivered": teleConesDelivered,
        "tele_cones_scored": teleConesScored,
        "tele_cones_failed": teleConesFailed,
        "tele_cubes_delivered": teleCubesDelivered,
        "tele_cubes_scored": teleCubesScored,
        "tele_cubes_failed": teleCubesFailed,
        "scouter_name": name,
        "schedule_match_id": scheduleMatch?.id,
        "robot_match_status_id": robotMatchStatusId,
        "is_rematch": isRematch,
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

//TODO get rid of this. points are irrelevant now...
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
