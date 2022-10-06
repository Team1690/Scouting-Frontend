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
Future<List<ScheduleMatch>> fetchMatches() async {
  final GraphQLClient client = getClient();
  final String query = """
query{
  matches{
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
  }
}
  """;

  final QueryResult<List<ScheduleMatch>> result = await client.query(
    QueryOptions<List<ScheduleMatch>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> matches) =>
          (matches["matches"] as List<dynamic>)
              .map(
                (final dynamic e) => ScheduleMatch(
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
                ),
              )
              .toList(),
    ),
  );

  return result.mapQueryResult();
}