import "package:collection/collection.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
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
  }
  }
}
""";
Future<List<ScatterData>> fetchScatterData() async {
  final GraphQLClient client = getClient();

  final QueryResult<List<ScatterData>> result = await client.query(
    QueryOptions<List<ScatterData>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> data) {
        return (data["team"] as List<dynamic>)
            .map<ScatterData?>((final dynamic scatterTeam) {
              final LightTeam team = LightTeam(
                scatterTeam["id"] as int,
                scatterTeam["number"] as int,
                scatterTeam["name"] as String,
                scatterTeam["colors_index"] as int,
              );
              final double? avgPoints = getPoints(
                scatterTeam["technical_matches_aggregate"]["aggregate"]["avg"],
              );
              if (avgPoints == null) return null;
              final List<dynamic> matches =
                  scatterTeam["technical_matches"] as List<dynamic>;
              final Iterable<double> matchesGamepiecePoints = matches.map(
                (final dynamic match) => getPoints(
                  match,
                )!, //these values being null was already delt with in the above 'if' statement
              );
              final double yStddevGamepiecePoints = matchesGamepiecePoints
                  .map(
                    (final double e) => (e - avgPoints).abs(),
                  )
                  .average;
              return ScatterData(
                avgPoints,
                yStddevGamepiecePoints,
                team,
              );
            })
            .whereType<ScatterData>()
            .toList();
      },
    ),
  );
  return result.mapQueryResult();
}

double? getPoints(final dynamic data) {
  final Map<String, int> pointValues = <String, int>{
    "top": 5,
    "mid": 3,
    "low": 2,
  };
  if (data["tele_cones_top"] == null) {
    //the only case in which one of the values are null is when the team match data doesnt exist in which case we return null.
    return null;
  } else {
    double auto = 0;
    double tele = 0;
    for (final MapEntry<String, int> pointValue in pointValues.entries) {
      auto += (data["auto_cubes_${pointValue.key}"] as double) *
              (pointValue.value + 1) +
          (data["auto_cones_${pointValue.key}"] as double) *
              (pointValue.value + 1);
      tele += (data["tele_cubes_${pointValue.key}"] as double) *
              pointValue.value +
          (data["tele_cones_${pointValue.key}"] as double) * pointValue.value;
    }
    return auto + tele;
  }
}
