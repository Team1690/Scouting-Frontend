import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/status/status_screen.dart";
import "package:collection/collection.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

Stream<List<StatusItem<LightTeam, String>>> fetchPreScoutingStatus(
  final bool specific,
) =>
    fetchBase(
      getSubscription(specific, true),
      specific,
      (final dynamic element) => LightTeam.fromJson(element["team"]),
      (final dynamic e) => e["scouter_name"] as String,
      (final __, final _) => <String>[],
    );

Stream<List<StatusItem<I, V>>> fetchBase<I, V>(
  final String subscription,
  final bool specific,
  final I Function(dynamic) parseI,
  final V Function(dynamic) parseV,
  final List<V> Function(I identifier, List<V> currentValues) getMissing,
) {
  return getClient()
      .subscribe(
    SubscriptionOptions<List<StatusItem<I, V>>>(
      document: gql(subscription),
      parserFn: (final Map<String, dynamic> data) {
        final List<dynamic> matches =
            data[specific ? "specific" : "match"] as List<dynamic>;
        final Map<I, List<dynamic>> identifierToMatch = matches.groupListsBy(
          parseI,
        );
        return identifierToMatch
            .map(
              (final I key, final List<dynamic> value) => MapEntry<I, List<V>>(
                key,
                value.map(parseV).toList(),
              ),
            )
            .entries
            .map<StatusItem<I, V>>(
              (final MapEntry<I, List<V>> e) => StatusItem<I, V>(
                missingValues: getMissing(e.key, e.value),
                values: e.value,
                identifier: e.key,
              ),
            )
            .toList();
      },
    ),
  )
      .map((final QueryResult<List<StatusItem<I, V>>> event) {
    return event.mapQueryResult();
  });
}

Stream<List<StatusItem<MatchIdentifier, Match>>> fetchStatus(
  final bool specific,
  final BuildContext context,
) =>
    fetchBase(
      getSubscription(specific, false),
      specific,
      (final dynamic element) => MatchIdentifier(
        number: element["match"]["match_number"] as int,
        type: element["match"]["match_type"]["title"] as String,
        isRematch: element["is_rematch"] as bool,
      ),
      (final dynamic e) {
        final LightTeam team = LightTeam.fromJson(e);
        final ScheduleMatch scheduleMatch = (MatchesProvider.of(context)
            .matches
            .where(
              (final ScheduleMatch element) =>
                  element.matchNumber == e["match"]["match_number"] as int,
            )
            .toList()
            .single);
        return Match(
          scoutedTeam: StatusLightTeam(
            specific
                ? 0
                : (e["auto_upper"] as int) * 4 +
                    (e["auto_lower"] as int) * 2 +
                    (e["tele_upper"] as int) * 2 +
                    (e["tele_lower"] as int) +
                    (e["climb"]["points"] as int),
            scheduleMatch.isOfficial()
                ? scheduleMatch.getTeamStation(team).getColor()
                : Colors.white,
            team,
            scheduleMatch.isOfficial()
                ? scheduleMatch.getTeamStation(team).alliancePos
                : -1,
          ),
          scouter: e["scouter_name"] as String,
        );
      },
      (final MatchIdentifier identifier, final List<Match> scoutedMatches) {
        final ScheduleMatch match =
            MatchesProvider.of(context).matches.firstWhere(
                  (final ScheduleMatch element) =>
                      element.matchNumber == identifier.number &&
                      element.matchTypeId ==
                          IdProvider.of(context)
                              .matchType
                              .nameToId[identifier.type],
                );

        return match
            .getTeams(context)
            .where(
              (final LightTeam element) => !scoutedMatches
                  .map((final Match e) => e.scoutedTeam.team)
                  .contains(element),
            )
            .map(
              (final LightTeam e) => Match(
                scouter: "?",
                scoutedTeam: StatusLightTeam(
                  0,
                  match.getTeamStation(e).getColor(),
                  e,
                  -1,
                ),
              ),
            )
            .toList();
      },
    );

String getSubscription(final bool specific, final bool preScouting) => """
subscription Status {
  ${specific ? "specific" : "match"}(
    order_by: [{match: {match_type: {order: asc}}}, {match: {match_number: asc}}, {is_rematch: asc}]
    where: {match: {match_type: {title: {${preScouting ? "_eq" : "_neq"}: "Pre scouting"}}}}
  ) {
    team {
      colors_index
      id
      number
      name
    }
    scouter_name
    is_rematch
    ${!specific ? """
    auto_upper
    auto_lower
    auto_missed
    tele_upper
    tele_lower
    tele_missed
    climb{
      points
    } 
""" : ""}
    match {
      match_number
      match_type {
        title
      }
    }
  }
}
""";
