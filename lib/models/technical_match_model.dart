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
  auto("auto"),
  tele("tele");

  const MatchMode(this.title);
  final String title;
}

enum Gamepiece {
  cone("cones"),
  cube("cubes");

  const Gamepiece(this.title);
  final String title;
}

enum ActionType {
  scored("scored"),
  delivered("delivered"),
  failed("failed");

  const ActionType(this.title);
  final String title;
}

class GamepieceAction {
  const GamepieceAction({
    required this.mode,
    required this.piece,
    required this.action,
  });
  final MatchMode mode;
  final Gamepiece piece;
  final ActionType action;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        mode,
        piece,
        action,
      ]);

  @override
  bool operator ==(final Object other) =>
      other is GamepieceAction &&
      other.action == action &&
      other.mode == mode &&
      other.piece == piece;
}

List<GamepieceAction> coneAndCube(
  final ActionType action,
  final MatchMode mode,
) =>
    <GamepieceAction>[
      GamepieceAction(
        mode: mode,
        piece: Gamepiece.cone,
        action: action,
      ),
      GamepieceAction(
        mode: mode,
        piece: Gamepiece.cube,
        action: action,
      ),
    ];

List<GamepieceAction> allLevel(final MatchMode mode) => <GamepieceAction>[
      ...ActionType.values
          .map((final ActionType action) => coneAndCube(action, mode))
          .expand(identity)
          .toList()
    ];

double getPieces(final Map<GamepieceAction, double> countedValues) =>
    countedValues.keys.fold(
      0,
      (final double gamepieces, final GamepieceAction gamepieceAction) =>
          countedValues[gamepieceAction]! + gamepieces,
    );

Map<GamepieceAction, double> parseByMode(
  final MatchMode mode,
  final dynamic data,
) =>
    Map<GamepieceAction, double>.fromEntries(
      allLevel(mode).map(
        (final GamepieceAction e) => MapEntry<GamepieceAction, double>(
          e,
          data["${e.mode.title}_${e.piece.title}_${e.action.title}"] as double,
        ),
      ),
    ); //we define these values, therefore they are not null (see 'allLevel()')

Map<GamepieceAction, double> parseMatch(
  final dynamic data,
) =>
    <GamepieceAction, double>{
      ...parseByMode(MatchMode.auto, data),
      ...parseByMode(MatchMode.tele, data)
    };
