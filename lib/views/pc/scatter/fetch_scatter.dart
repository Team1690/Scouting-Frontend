import "package:collection/collection.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/technical_match_model.dart";
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
    technical_matches_v3_aggregate(where: {ignored: {_eq: false}}) {
    aggregate {
      avg {
        auto_cones_delivered
        auto_cones_failed
        auto_cones_scored
        auto_cubes_delivered
        auto_cubes_failed
        auto_cubes_scored
        tele_cones_delivered
        tele_cones_failed
        tele_cones_scored
        tele_cubes_delivered
        tele_cubes_failed
        tele_cubes_scored
      }
    }
  }
    technical_matches_v3(where: {ignored: {_eq: false}}) {
    auto_cones_delivered
    auto_cones_failed
    auto_cones_scored
    auto_cubes_delivered
    auto_cubes_failed
    auto_cubes_scored
    tele_cones_delivered
    tele_cones_failed
    tele_cones_scored
    tele_cubes_delivered
    tele_cubes_failed
    tele_cubes_scored
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
                final dynamic avg =
                    scatterTeam["technical_matches_v3_aggregate"]["aggregate"]
                        ["avg"];
                final List<dynamic> matches =
                    scatterTeam["technical_matches_v3"] as List<dynamic>;
                if (avg["auto_cones_scored"] == null) {
                  //if one of these is null, the team's match data doesnt exist so we return null
                  return null;
                }
                final double avgGamepieces = getPieces(parseMatch(avg));
                final Iterable<double> matchesGamepieces = matches
                    .map((final dynamic match) => getPieces(parseMatch(match)));
                final double yStddevGamepieces = matchesGamepieces
                    .map(
                      (final double matchGamepieces) =>
                          (matchGamepieces - avgGamepieces).abs(),
                    )
                    .average;
                return ScatterData(
                  avgGamepieces,
                  yStddevGamepieces,
                  team,
                );
              })
              .whereType<ScatterData>()
              .toList(),
    ),
  );
  return result.mapQueryResult();
}
