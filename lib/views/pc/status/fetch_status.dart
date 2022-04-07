import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/status/status_screen.dart";
import "package:collection/collection.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

Stream<List<MatchReceived>> fetchStatus(final bool specific) {
  final String subscription = """
subscription Status {
  ${specific ? "specific" : "match_2022"}(order_by: {match_type: {order: asc}, match_number: asc, is_rematch: asc}) {
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
  return getClient()
      .subscribe(SubscriptionOptions(document: gql(subscription)))
      .map((final QueryResult event) {
    return event.mapQueryResult<List<MatchReceived>>(
      (final Map<String, dynamic>? p0) =>
          p0.mapNullable<List<MatchReceived>>(
              (final Map<String, dynamic> data) {
            final List<dynamic> matches =
                data[specific ? "specific" : "match_2022"] as List<dynamic>;
            final Map<MatchIdentifier, List<dynamic>> identifierToMatch =
                matches.groupListsBy(
              (final dynamic element) => MatchIdentifier(
                number: element["match_number"] as int,
                type: element["match_type"]["title"] as String,
                isRematch: element["is_rematch"] as bool,
              ),
            );
            return identifierToMatch
                .map(
                  (final MatchIdentifier key, final List<dynamic> value) =>
                      MapEntry<MatchIdentifier, List<Match>>(
                    key,
                    value
                        .map(
                          (final dynamic e) => Match(
                            team: LightTeam(
                              e["team"]["id"] as int,
                              e["team"]["number"] as int,
                              e["team"]["name"] as String,
                              e["team"]["colors_index"] as int,
                            ),
                            scouter: e["scouter_name"] as String,
                          ),
                        )
                        .toList(),
                  ),
                )
                .entries
                .map(
                  (final MapEntry<MatchIdentifier, List<Match>> e) =>
                      MatchReceived(
                    matches: e.value,
                    identifier: e.key,
                  ),
                )
                .toList();
          }) ??
          (throw Exception("No data")),
    );
  });
}
