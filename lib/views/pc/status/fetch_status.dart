import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/status/status_screen.dart";
import "package:collection/collection.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

Stream<List<StatusItem<LightTeam, String>>> fetchPreScoutingStatus(
  final bool specific,
) {
  final String subscription = """
subscription Status {
  ${specific ? "specific" : "match_2022"}(order_by: {match_type: {order: asc}, match_number: asc, is_rematch: asc},where:{match_type: {title:{_eq:"Pre scouting"}}}) {
    team {
      colors_index
      id
      number
      name
    }
    scouter_name
    match_number
    is_rematch
    match_type {
      title
    }
  }
}
""";
  return fetchBase(
    subscription,
    specific,
    (final dynamic element) => LightTeam.fromJson(element["team"]),
    (final dynamic e) => e["scouter_name"] as String,
  );
}

Stream<List<StatusItem<I, V>>> fetchBase<I, V>(
  final String subscription,
  final bool specific,
  final I Function(dynamic) parseI,
  final V Function(dynamic) parseV,
) {
  return getClient()
      .subscribe(SubscriptionOptions(document: gql(subscription)))
      .map((final QueryResult event) {
    return event.mapQueryResult<List<StatusItem<I, V>>>(
      (final Map<String, dynamic>? p0) =>
          p0.mapNullable<List<StatusItem<I, V>>>(
              (final Map<String, dynamic> data) {
            final List<dynamic> matches =
                data[specific ? "specific" : "match_2022"] as List<dynamic>;
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
                  (final MapEntry<I, List<V>> e) => StatusItem<I, V>(
                    values: e.value,
                    identifier: e.key,
                  ),
                )
                .toList();
          }) ??
          (throw Exception("No data")),
    );
  });
}

Stream<List<StatusItem<MatchIdentifier, Match>>> fetchStatus(
  final bool specific,
) {
  final String subscription = """
subscription Status {
  ${specific ? "specific" : "match_2022"}(order_by: {match_type: {order: asc}, match_number: asc, is_rematch: asc},,where:{match_type: {title:{_neq:"Pre scouting"}}}) {
    team {
      colors_index
      id
      number
      name
    }
    scouter_name
    match_number
    is_rematch
    match_type {
      title
    }
  }
}
""";
  return fetchBase(
    subscription,
    specific,
    (final dynamic element) => MatchIdentifier(
      number: element["match_number"] as int,
      type: element["match_type"]["title"] as String,
      isRematch: element["is_rematch"] as bool,
    ),
    (final dynamic e) => Match(
      team: LightTeam(
        e["team"]["id"] as int,
        e["team"]["number"] as int,
        e["team"]["name"] as String,
        e["team"]["colors_index"] as int,
      ),
      scouter: e["scouter_name"] as String,
    ),
  );
}
