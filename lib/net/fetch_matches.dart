import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
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

List<ScheduleMatch> parserFn(final Map<String, dynamic> matches) =>
    (matches["matches"] as List<dynamic>)
        .map(
          (final dynamic e) => ScheduleMatch(
            happened: e["happened"] as bool,
            id: e["id"] as int,
            matchTypeId: e["match_type_id"] as int,
            matchNumber: e["match_number"] as int,
            blue0: LightTeam.fromJson(e["blue_0"]),
            blue1: LightTeam.fromJson(e["blue_1"]),
            blue2: LightTeam.fromJson(e["blue_2"]),
            blue3: (e["blue_3"] as Map<String, dynamic>?)
                .mapNullable(LightTeam.fromJson),
            red0: LightTeam.fromJson(e["red_0"]),
            red1: LightTeam.fromJson(e["red_1"]),
            red2: LightTeam.fromJson(e["red_2"]),
            red3: (e["red_3"] as Map<String, dynamic>?)
                .mapNullable(LightTeam.fromJson),
            getTeamStation: (final LightTeam p0) {
              final int index = <int?>[
                LightTeam.fromJson(e["blue_0"]).id,
                LightTeam.fromJson(e["blue_1"]).id,
                LightTeam.fromJson(e["blue_2"]).id,
                (e["blue_3"] as Map<String, dynamic>?)
                    .mapNullable(LightTeam.fromJson)
                    ?.id,
                LightTeam.fromJson(e["red_0"]).id,
                LightTeam.fromJson(e["red_1"]).id,
                LightTeam.fromJson(e["red_2"]).id,
                (e["red_3"] as Map<String, dynamic>?)
                    .mapNullable(LightTeam.fromJson)!
                    .id
              ].indexOf(p0.id);
              switch (index) {
                case 0:
                  return "blue1";
                case 1:
                  return "blue2";
                case 2:
                  return "blue3";
                case 3:
                  return "blue4";
                case 4:
                  return "red1";
                case 5:
                  return "red2";
                case 6:
                  return "red3";
                case 7:
                  return "red4";
                default:
                  return "should not be here";
              }
            },
            redAlliance: <LightTeam?>[
              LightTeam.fromJson(e["red_0"]),
              LightTeam.fromJson(e["red_1"]),
              LightTeam.fromJson(e["red_2"]),
              (e["red_3"] as Map<String, dynamic>?)
                  .mapNullable(LightTeam.fromJson)
            ],
            blueAlliance: <LightTeam?>[
              LightTeam.fromJson(e["blue_0"]),
              LightTeam.fromJson(e["blue_1"]),
              LightTeam.fromJson(e["blue_2"]),
              (e["blue_3"] as Map<String, dynamic>?)
                  .mapNullable(LightTeam.fromJson),
            ],
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
