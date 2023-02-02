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
              final double? avgCones = getPoints(
                true,
                e["technical_matches_aggregate"]["aggregate"]["avg"],
              );
              final double? avgCubes = getPoints(
                false,
                e["technical_matches_aggregate"]["aggregate"]["avg"],
              );
              if (avgCubes == null || avgCones == null) return null;
              final double gamepiecePointsAvg = avgCubes + avgCones;
              final List<dynamic> matches =
                  e["technical_matches"] as List<dynamic>;
              final Iterable<int> matchesGamepiecePoints = matches.map(
                (final dynamic match) => getPoints(true, match)! +
                        getPoints(false, match)!
                    as int, //these values being null was already delt with in the above 'if' statement
              );
              double yStddevGamepiecePoints = 0;
              for (final int match in matchesGamepiecePoints) {
                yStddevGamepiecePoints += (match - gamepiecePointsAvg).abs();
              }
              yStddevGamepiecePoints /= matchesGamepiecePoints.length;
              return ScatterData(
                gamepiecePointsAvg,
                yStddevGamepiecePoints,
                team,
              );
            })
            .where((final ScatterData? data) => data != null)
            .cast<ScatterData>()
            .toList();
      },
    ),
  );
  return result.mapQueryResult();
}

double? getPoints(final bool isCone, final dynamic data) {
  double? calculatePoints(final bool isTele) {
    final double? top =
        data["${isTele ? "tele" : "auto"}_${isCone ? "cones" : "cubes"}_top"]
            as double?;
    final double? mid =
        data["${isTele ? "tele" : "auto"}_${isCone ? "cones" : "cubes"}_mid"]
            as double?;
    final double? low =
        data["${isTele ? "tele" : "auto"}_${isCone ? "cones" : "cubes"}_low"]
            as double?;

    return top.mapNullable(
      (final double top) =>
          top * (isTele ? 5 : 6) +
          mid! * (isTele ? 3 : 4) +
          low! * (isTele ? 2 : 3),
    ); //these values can only be null if all of them is null. aka the data does not exist
  }

  return calculatePoints(true).mapNullable(
    (final double telePoints) =>
        telePoints +
        calculatePoints(
          false,
        )!,
  ); //same principle as stated above
}
