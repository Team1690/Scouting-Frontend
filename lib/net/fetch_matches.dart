import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";

const List<String> allianceMembers = <String>[
  "red_0",
  "red_1",
  "red_2",
  "red_3",
  "blue_0",
  "blue_1",
  "blue_2",
  "blue_3"
];
String graphqlSyntax(final bool isSubscription) => """
${isSubscription ? "subscription" : "query"} FetchMatches{
  matches(order_by:[{match_type:{order:asc}},{match_number:asc}]){
    ${allianceMembers.map(
          (final String e) => """$e{
      id
      name
      number
      colors_index
    }""",
        ).join("\n")}
    id
    match_type_id
    match_number
    happened
  }
}
  """;

List<TeamStation> returnTeamStation(final dynamic json, final String color) {
  final String optional = "${color}_3";
  return <TeamStation>[
    ...(<int>[0, 1, 2].map(
      (final int index) => TeamStation(
        alliancePos: index,
        allianceColor: color,
        team: LightTeam.fromJson(json["${color}_$index"]),
      ),
    )),
    if (json[optional] != null)
      TeamStation(
        team: LightTeam.fromJson(json[optional]),
        allianceColor: color,
        alliancePos: 3,
      )
  ];
}

List<ScheduleMatch> parserFn(final Map<String, dynamic> matches) =>
    (matches["matches"] as List<dynamic>)
        .map(
          (final dynamic e) => IdProvider.isOfficial(e["match_type_id"] as int)
              ? OfficialMatch(
                  happened: e["happened"] as bool,
                  id: e["id"] as int,
                  matchTypeId: e["match_type_id"] as int,
                  matchNumber: e["match_number"] as int,
                  teams: <TeamStation>[
                    ...returnTeamStation(e, "blue"),
                    ...returnTeamStation(e, "red")
                  ],
                )
              : UnofficialMatch(
                  happened: e["happened"] as bool,
                  id: e["id"] as int,
                  matchTypeId: e["match_type_id"] as int,
                  matchNumber: e["match_number"] as int,
                ),
        )
        .toList();

Stream<List<ScheduleMatch>> fetchMatchesSubscription() {
  final GraphQLClient client = getClient();
  final String subscription = graphqlSyntax(true);
  final Stream<QueryResult<List<ScheduleMatch>>> result = client.subscribe(
    SubscriptionOptions<List<ScheduleMatch>>(
      document: gql(subscription),
      parserFn: parserFn,
    ),
  );

  return result.map(
    (final QueryResult<List<ScheduleMatch>> event) => event.mapQueryResult(),
  );
}

Future<List<ScheduleMatch>> fetchMatches() async {
  final GraphQLClient client = getClient();
  final String query = graphqlSyntax(false);
  final QueryResult<List<ScheduleMatch>> result = await client.query(
    QueryOptions<List<ScheduleMatch>>(
      document: gql(query),
      parserFn: parserFn,
    ),
  );
  return result.mapQueryResult();
}
