import "package:collection/collection.dart";
import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/average_or_null.dart";
import "package:scouting_frontend/models/cycle_model.dart";
import "package:scouting_frontend/models/event_model.dart";
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
  delivered("delivered");

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

List<MatchEvent> getEvents(
  final List<dynamic> data,
  final String title,
) {
  final List<MatchEvent> events = <MatchEvent>[];
  if (data.isNotEmpty) {
    if ((data[0][title] as List<dynamic>).isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        for (int j = 0; j < (data[i][title] as List<dynamic>).length; j++) {
          if ((data[i][title] as List<dynamic>).isNotEmpty) {
            if ((data[i][title][j] as Map<String, dynamic>).isNotEmpty) {
              events.add(
                MatchEvent(
                  eventTypeId: data[i][title][j]["event_type_id"] as int,
                  timestamp: data[i][title][j]["timestamp"] as int,
                  matchId: data[i]["schedule_match_id"] as int,
                ),
              );
            }
          }
        }
      }
    }
  }
  return events;
}

int getFailedInCommunity(
  final List<MatchEvent> locations,
  final List<MatchEvent> robotEvents,
  final BuildContext context,
) {
  final List<MatchEvent> failed = robotEvents
      .where(
        (final MatchEvent robotEvent) =>
            robotEvent.eventTypeId ==
                IdProvider.of(context).robotActionIds.nameToId["Failed Cone"] ||
            robotEvent.eventTypeId ==
                IdProvider.of(context).robotActionIds.nameToId["Failed Cube"],
      )
      .toList();
  final List<MatchEvent> failedInCommunity = failed
      .map(
        (final MatchEvent fail) => locations
                    .where(
                      (final MatchEvent element) =>
                          fail.matchId == element.matchId,
                    )
                    .where(
                      (final MatchEvent element) =>
                          element.timestamp < fail.timestamp,
                    )
                    .fold(
                      MatchEvent(eventTypeId: 1, timestamp: 0),
                      (final MatchEvent value, final MatchEvent element) =>
                          value.timestamp < element.timestamp ? element : value,
                    )
                    .eventTypeId ==
                IdProvider.of(context).locationIds.nameToId["Entered Community"]
            ? fail
            : null,
      )
      .whereType<MatchEvent>()
      .toList();
  return failedInCommunity.length;
}

double getPlacingTime(
  final List<MatchEvent> locations,
  final List<MatchEvent> robotEvents,
  final BuildContext context,
) {
  final List<MatchEvent> placingEvents = robotEvents
      .where(
        (final MatchEvent element) =>
            element.eventTypeId ==
                IdProvider.of(context).robotActionIds.nameToId["Scored Cone"] ||
            element.eventTypeId ==
                IdProvider.of(context).robotActionIds.nameToId["Scored Cube"],
      )
      .toList();
  final List<int> placeTime = placingEvents
      .map(
        (final MatchEvent placeEvent) => Cycle(
          endTime: placeEvent.timestamp,
          startingTime: <int>[
            locations
                .where(
                  (final MatchEvent element) =>
                      element.matchId == placeEvent.matchId,
                )
                .where(
                  (final MatchEvent element) =>
                      element.timestamp < placeEvent.timestamp,
                )
                .where(
                  (final MatchEvent element) =>
                      element.eventTypeId ==
                      IdProvider.of(context)
                          .locationIds
                          .nameToId["Entered Community"],
                )
                .fold(
                  MatchEvent(eventTypeId: 1, timestamp: 0),
                  (final MatchEvent value, final MatchEvent element) =>
                      value.timestamp < element.timestamp ? element : value,
                )
                .timestamp,
            robotEvents
                .where(
                  (final MatchEvent element) =>
                      element.matchId == placeEvent.matchId,
                )
                .where(
                  (final MatchEvent element) =>
                      element.eventTypeId ==
                          IdProvider.of(context)
                              .robotActionIds
                              .nameToId["Intake Cone"] ||
                      element.eventTypeId ==
                          IdProvider.of(context)
                              .robotActionIds
                              .nameToId["Intake Cube"],
                )
                .where(
                  (final MatchEvent element) =>
                      element.timestamp < placeEvent.timestamp,
                )
                .fold(
                  MatchEvent(eventTypeId: 1, timestamp: 0),
                  (final MatchEvent value, final MatchEvent element) =>
                      value.timestamp < element.timestamp ? element : value,
                )
                .timestamp
          ].max,
        ).getLength(),
      )
      .toList();
  return placeTime.averageOrNull ?? double.nan;
}

double getFeederTime(
  final List<MatchEvent> locations,
  final BuildContext context,
) {
  final List<MatchEvent> feederEntries = locations
      .where(
        (final MatchEvent location) =>
            location.eventTypeId ==
            IdProvider.of(context).locationIds.nameToId["Entered Feeder"],
      )
      .toList();
  final List<int> feederTime =
      feederEntries.map((final MatchEvent feederEntry) {
    final MatchEvent nextLocation = locations
        .where(
          (final MatchEvent location) =>
              location.matchId == feederEntry.matchId,
        )
        .where(
          (final MatchEvent location) =>
              location.eventTypeId !=
              IdProvider.of(context).locationIds.nameToId["Entered Feeder"],
        )
        .where(
          (final MatchEvent location) =>
              location.timestamp > feederEntry.timestamp,
        )
        .fold(
          feederEntry,
          (final MatchEvent value, final MatchEvent element) =>
              value.timestamp != feederEntry.timestamp &&
                      value.timestamp < element.timestamp
                  ? value
                  : element,
        );
    locations.remove(nextLocation);
    return nextLocation.timestamp - feederEntry.timestamp;
  }).toList();
  return feederTime.averageOrNull ?? double.nan;
}

List<Cycle> getCycles(
  final List<MatchEvent> robotEvents,
  final List<MatchEvent> locations,
  final BuildContext context,
) {
  final List<Cycle> cycles = <Cycle>[];
  final Map<String, int> provider =
      IdProvider.of(context).robotActionIds.nameToId;
  final List<int> endingCycles = <int>[
    provider["Delivered Cone"]!,
    provider["Delivered Cube"]!,
    provider["Scored Cube"]!,
    provider["Scored Cone"]!,
  ];
  //a list of all match ids, toSet() removes the duplicated ones
  final List<int> matchIds = robotEvents.isNotEmpty
      ? robotEvents
          .map((final MatchEvent event) => event.matchId!)
          .toSet()
          .toList()
      : <int>[];
  for (final int matchId in matchIds) {
    while (locations.isNotEmpty &&
        robotEvents
                .where(
                  (final MatchEvent robotEvent) =>
                      robotEvent.matchId == matchId,
                )
                .firstWhereOrNull(
                  (final MatchEvent robotEvent) =>
                      (provider["Intaked Cone"] == robotEvent.eventTypeId ||
                          provider["Intaked Cube"] == robotEvent.eventTypeId) &&
                      locations
                              .where(
                                (final MatchEvent location) =>
                                    location.matchId == matchId,
                              )
                              .where(
                                (final MatchEvent location) =>
                                    location.timestamp < robotEvent.timestamp,
                              )
                              .fold(
                                MatchEvent(eventTypeId: 1, timestamp: 0),
                                (
                                  final MatchEvent value,
                                  final MatchEvent element,
                                ) =>
                                    value.timestamp < element.timestamp
                                        ? element
                                        : value,
                              )
                              .eventTypeId !=
                          IdProvider.of(context)
                              .locationIds
                              .nameToId["Entered Community"],
                ) !=
            null) {
      final MatchEvent currentIntake = robotEvents
          .where((final MatchEvent robotEvent) => robotEvent.matchId == matchId)
          .firstWhere(
            (final MatchEvent robotEvent) =>
                (provider["Intaked Cone"] == robotEvent.eventTypeId ||
                    provider["Intaked Cube"] == robotEvent.eventTypeId) &&
                locations
                        .where(
                          (final MatchEvent location) =>
                              location.matchId == matchId,
                        )
                        .where(
                          (final MatchEvent location) =>
                              location.timestamp < robotEvent.timestamp,
                        )
                        .fold(
                          MatchEvent(eventTypeId: 1, timestamp: 0),
                          (final MatchEvent value, final MatchEvent element) =>
                              value.timestamp < element.timestamp
                                  ? element
                                  : value,
                        )
                        .eventTypeId !=
                    IdProvider.of(context)
                        .locationIds
                        .nameToId["Entered Community"],
          );
      if (robotEvents
              .where(
                (final MatchEvent robotEvent) => robotEvent.matchId == matchId,
              )
              .firstWhereOrNull(
                (final MatchEvent robotEvent) =>
                    endingCycles.contains(robotEvent.eventTypeId) &&
                    currentIntake.timestamp < robotEvent.timestamp,
              ) !=
          null) {
        final MatchEvent startingLocation = locations
            .where((final MatchEvent element) => element.matchId == matchId)
            .where(
              (final MatchEvent location) =>
                  location.timestamp < currentIntake.timestamp,
            )
            .fold(
              MatchEvent(eventTypeId: 1, timestamp: 0),
              (final MatchEvent value, final MatchEvent element) =>
                  value.timestamp < element.timestamp ? element : value,
            );
        final MatchEvent currentCycleEnder = robotEvents
            .where(
              (final MatchEvent robotEvent) => robotEvent.matchId == matchId,
            )
            .firstWhere(
              (final MatchEvent robotEvent) =>
                  endingCycles.contains(robotEvent.eventTypeId) &&
                  currentIntake.timestamp < robotEvent.timestamp,
            );
        cycles.add(
          Cycle(
            endTime: currentCycleEnder.timestamp,
            startingTime: startingLocation.timestamp,
          ),
        );
        locations.remove(startingLocation);
        robotEvents.remove(currentCycleEnder);
      }
      robotEvents.remove(currentIntake);
    }
  }
  return cycles;
}
