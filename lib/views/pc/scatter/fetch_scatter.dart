import "package:collection/collection.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/scatter/scatter.dart";

const String query = """
query Scatter {
  team {
    colors_index
    number
    id
    name
    technical_matches_aggregate(where: {ignored: {_eq: false}}) {
    aggregate {
      avg {
        auto_cones_low
        auto_cones_mid
        auto_cones_top
        auto_cubes_low
        auto_cubes_mid
        auto_cubes_top
        tele_cones_low
        tele_cones_mid
        tele_cones_top
        tele_cubes_low
        tele_cubes_mid
        tele_cubes_top
        auto_cones_delivered
        auto_cubes_delivered
        tele_cones_delivered
        tele_cubes_delivered
      }
    }
  }
    technical_matches(where: {ignored: {_eq: false}}) {
    auto_cones_low
    auto_cones_mid
    auto_cones_top
    auto_cubes_low
    auto_cubes_mid
    auto_cubes_top
    tele_cones_low
    tele_cones_mid
    tele_cones_top
    tele_cubes_low
    tele_cubes_mid
    tele_cubes_top
    auto_cones_delivered
    auto_cubes_delivered
    tele_cones_delivered
    tele_cubes_delivered
  }
  }
}
""";
Future<List<ScatterData>> fetchScatterData() async {
  final GraphQLClient client = getClient();

  final QueryResult<List<ScatterData>> result = await client.query(
    QueryOptions<List<ScatterData>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> data) =>
          (data["team"] as List<dynamic>)
              .map<ScatterData?>((final dynamic scatterTeam) {
                final LightTeam team = LightTeam(
                  scatterTeam["id"] as int,
                  scatterTeam["number"] as int,
                  scatterTeam["name"] as String,
                  scatterTeam["colors_index"] as int,
                );
                final dynamic avg = scatterTeam["technical_matches_aggregate"]
                    ["aggregate"]["avg"];
                final List<dynamic> matches =
                    scatterTeam["technical_matches"] as List<dynamic>;
                if (avg["auto_cones_top"] == null) {
                  //if one of these is null, the team's match data doesnt exist so we return null
                  return null;
                }
                final double avgPoints = getPoints(parseMatch(avg));
                final Iterable<double> matchesGamepiecePoints = matches
                    .map((final dynamic match) => getPoints(parseMatch(match)));
                final double yStddevGamepiecePoints = matchesGamepiecePoints
                    .map(
                      (final double matchPoints) =>
                          (matchPoints - avgPoints).abs(),
                    )
                    .average;
                return ScatterData(
                  avgPoints,
                  yStddevGamepiecePoints,
                  team,
                );
              })
              .whereType<ScatterData>()
              .toList(),
    ),
  );
  return result.mapQueryResult();
}
