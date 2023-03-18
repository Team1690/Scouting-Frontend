import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/status/status_screen.dart";
import "package:collection/collection.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

Stream<List<StatusItem<LightTeam, String>>> fetchPreScoutingStatus(
  final bool isSpecific,
) =>
    fetchBase(
      getSubscription(isSpecific, true),
      isSpecific,
      (final dynamic scoutedMatchTable) =>
          LightTeam.fromJson(scoutedMatchTable["team"]),
      (final dynamic scoutedMatchTable) =>
          scoutedMatchTable["scouter_name"] as String,
      (final __, final _) => <String>[],
    );

Stream<List<StatusItem<I, V>>> fetchBase<I, V>(
  final String subscription,
  final bool isSpecific,
  final I Function(dynamic) parseI,
  final V Function(dynamic) parseV,
  final List<V> Function(I identifier, List<V> currentValues) getMissing,
) =>
    getClient()
        .subscribe(
          SubscriptionOptions<List<StatusItem<I, V>>>(
            document: gql(subscription),
            parserFn: (final Map<String, dynamic> data) {
              final List<dynamic> matches =
                  data[isSpecific ? "_2023_specific" : "_2023_technical_match"]
                      as List<dynamic>;
              final Map<I, List<dynamic>> identifierToMatch =
                  matches.groupListsBy(
                parseI,
              );
              return identifierToMatch
                  .map(
                    (final I key, final List<dynamic> value) =>
                        MapEntry<I, List<V>>(
                      key,
                      value.map(parseV).toList(),
                    ),
                  )
                  .entries
                  .map<StatusItem<I, V>>(
                    (final MapEntry<I, List<V>> statusCard) => StatusItem<I, V>(
                      missingValues: getMissing(
                        statusCard.key,
                        statusCard.value,
                      ),
                      values: statusCard.value,
                      identifier: statusCard.key,
                    ),
                  )
                  .toList();
            },
          ),
        )
        .map(
          (final QueryResult<List<StatusItem<I, V>>> event) =>
              event.mapQueryResult(),
        );

Stream<List<StatusItem<MatchIdentifier, StatusMatch>>> fetchStatus(
  final bool isSpecific,
  final BuildContext context,
) =>
    fetchBase(
      getSubscription(isSpecific, false),
      isSpecific,
      (final dynamic matchTable) => MatchIdentifier(
        number: matchTable["match"]["match_number"] as int,
        type: matchTable["match"]["match_type"]["title"] as String,
        isRematch: matchTable["is_rematch"] as bool,
      ),
      (final dynamic scoutedMatchTable) {
        final LightTeam team = LightTeam.fromJson(scoutedMatchTable["team"]);
        final ScheduleMatch scheduleMatch = (MatchesProvider.of(context)
            .matches
            .where(
              (final ScheduleMatch match) =>
                  match.matchNumber ==
                  scoutedMatchTable["match"]["match_number"] as int,
            )
            .toList()
            .single);
        return StatusMatch(
          scoutedTeam: StatusLightTeam(
            isSpecific
                ? 0
                : (getPoints(parseMatch(scoutedMatchTable)) as int) +
                    (scoutedMatchTable["endgame_balance"]["endgame_points"]
                        as int) +
                    (scoutedMatchTable["auto_balance"]["auto_points"] as int),
            scheduleMatch.redAlliance.contains(
              team,
            )
                ? Colors.red
                : Colors.blue,
            team,
            scheduleMatch.redAlliance.contains(
              team,
            )
                ? scheduleMatch.redAlliance.indexOf(
                    team,
                  )
                : scheduleMatch.blueAlliance.indexOf(
                    team,
                  ),
          ),
          scouter: scoutedMatchTable["scouter_name"] as String,
        );
      },
      (
        final MatchIdentifier identifier,
        final List<StatusMatch> scoutedMatches,
      ) {
        final ScheduleMatch match =
            MatchesProvider.of(context).matches.firstWhere(
                  (final ScheduleMatch element) =>
                      element.matchNumber == identifier.number &&
                      element.matchTypeId ==
                          IdProvider.of(context)
                              .matchType
                              .nameToId[identifier.type],
                );

        return <LightTeam>[
          ...match.redAlliance,
          ...match.blueAlliance,
        ]
            .where(
              (final LightTeam team) => !scoutedMatches
                  .map(
                    (final StatusMatch statusMatch) =>
                        statusMatch.scoutedTeam.team,
                  )
                  .contains(team),
            )
            .map(
              (final LightTeam notScoutedTeam) => StatusMatch(
                scouter: "?",
                scoutedTeam: StatusLightTeam(
                  0,
                  match.redAlliance.contains(notScoutedTeam)
                      ? Colors.red
                      : Colors.blue,
                  notScoutedTeam,
                  -1,
                ),
              ),
            )
            .toList();
      },
    );

String getSubscription(final bool isSpecific, final bool isPreScouting) => """
subscription Status {
   _2023_${isSpecific ? "specific" : "technical_match"}
  (order_by: {match: {match_type: {order: asc}, match_number: asc}, is_rematch: asc},
   where: {match: {match_type: {title: {${isPreScouting ? "_eq" : "_neq"}: "Pre scouting"}}}}) {
    team {
      colors_index
      id
      number
      name
    }
    scouter_name
    is_rematch
     ${!isSpecific ? """tele_cones_low
    tele_cones_mid
    tele_cones_top
    tele_cubes_low
    tele_cubes_mid
    tele_cubes_top
    auto_cones_low
    auto_cones_mid
    auto_cones_top
    auto_cubes_low
    auto_cubes_mid
    auto_cubes_top
    auto_cones_delivered
    auto_cubes_delivered
    tele_cones_delivered
    tele_cubes_delivered
    auto_balance {
      auto_points
    }
    endgame_balance {
      endgame_points
    } """ : ""}
    match {
      match_number
      match_type {
        title
      }
    }
  }
}
""";
