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
            .map<ScatterData?>((final dynamic e) {
              final LightTeam team = LightTeam(
                e["id"] as int,
                e["number"] as int,
                e["name"] as String,
                e["colors_index"] as int,
              );
              final double? avgAutoUpper = (e["matches_aggregate"]["aggregate"]
                      ["avg"]["auto_upper"] as double?)
                  .mapNullable((final double p0) => p0 * 4);
              final double? avgTeleUpper = (e["matches_aggregate"]["aggregate"]
                      ["avg"]["tele_upper"] as double?)
                  .mapNullable((final double p0) => p0 * 2);
              final double? avgAutoLower = (e["matches_aggregate"]["aggregate"]
                      ["avg"]["auto_lower"] as double?)
                  .mapNullable((final double p0) => p0 * 2);
              final double? avgTeleLower = (e["matches_aggregate"]["aggregate"]
                  ["avg"]["tele_lower"] as double?);
              if (avgTeleUpper == null ||
                  avgTeleLower == null ||
                  avgAutoLower == null ||
                  avgAutoUpper == null) return null;
              final double xBallPointsAvg =
                  avgTeleLower + avgAutoLower + avgTeleUpper + avgAutoUpper;
              final List<dynamic> matches = e["matches"] as List<dynamic>;
              final Iterable<int> matchBallPoints = matches.map(
                (final dynamic e) => ((e["auto_lower"] as int) * 2 +
                    (e["tele_lower"] as int) * 1 +
                    (e["auto_upper"] as int) * 4 +
                    (e["tele_upper"] as int) * 2),
              );
              double yStddevBallPoints = 0;
              for (final int element in matchBallPoints) {
                yStddevBallPoints += (element - xBallPointsAvg).abs();
              }
              yStddevBallPoints /= matchBallPoints.length;
              return ScatterData(xBallPointsAvg, yStddevBallPoints, team);
            })
            .where((final ScatterData? element) => element != null)
            .cast<ScatterData>()
            .toList();
      },
    ),
  );
  return result.mapQueryResult();
}
