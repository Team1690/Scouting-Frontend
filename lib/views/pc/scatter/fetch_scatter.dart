import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/scatter/scatter.dart";

const String query = """
query MyQuery {
  team {
    colors_index
    number
    id
    name
    matches_aggregate(where: {ignored: {_eq: false}}) {
      aggregate {
        avg {
          auto_lower
          auto_upper
          tele_lower
          tele_upper
        }
      }
    }
    matches(where: {ignored: {_eq: false}}) {
      auto_lower
      auto_upper
      tele_lower
      tele_upper
    }
  }
}

""";
Future<List<ScatterData>> fetchScatterData() async {
  final GraphQLClient client = getClient();

  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));
  return result.mapQueryResult(
        (final Map<String, dynamic>? data) =>
            data.mapNullable((final Map<String, dynamic> data) {
          return (data["team"] as List<dynamic>)
              .map<ScatterData?>((final dynamic e) {
                final LightTeam team = LightTeam(
                  e["id"] as int,
                  e["number"] as int,
                  e["name"] as String,
                  e["colors_index"] as int,
                );
                final double? avgAutoUpper = (e["matches_aggregate"]
                        ["aggregate"]["avg"]["auto_upper"] as double?)
                    .mapNullable((final double p0) => p0 * 4);
                final double? avgTeleUpper = (e["matches_aggregate"]
                        ["aggregate"]["avg"]["tele_upper"] as double?)
                    .mapNullable((final double p0) => p0 * 2);
                final double? avgAutoLower = (e["matches_aggregate"]
                        ["aggregate"]["avg"]["auto_lower"] as double?)
                    .mapNullable((final double p0) => p0 * 2);
                final double? avgTeleLower = (e["matches_aggregate"]
                    ["aggregate"]["avg"]["tele_lower"] as double?);
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
        }),
      ) ??
      (throw Exception("No data"));
}
