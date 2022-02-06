import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

const String teamInfoQuery = """
query MyQuery(\$id: Int!) {
  team_by_pk(id: \$id) {
    pit {
      drive_motor_amount
      drive_train_reliability
      drive_wheel_type
      electronics_reliability
      gearbox_purchased
      notes
      robot_reliability
      has_shifter
      url
      drivetrain {
        title
      }
      drivemotor {
        title
      }
    }
    specifics {
      message
    }
    matches_aggregate {
      aggregate {
        avg {
          auto_lower
          auto_upper
          auto_missed
          tele_lower
          tele_upper
          tele_missed
        }
      }
    }
    matches(order_by: {match_number: asc}) {
      climb {
        points
        title
      }
      auto_lower
      auto_upper
      auto_missed
      match_number
      tele_lower
      tele_upper
      tele_missed
    }
  }
}

""";

Future<Team<E>> fetchTeamInfo<E extends num>(
  final LightTeam teamForQuery,
) async {
  final GraphQLClient client = getClient();

  final QueryResult result = await client.query(
    QueryOptions(
      document: gql(teamInfoQuery),
      variables: <String, dynamic>{
        "id": teamForQuery.id,
      },
    ),
  );
  return result.mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable((final Map<String, dynamic> team) {
          //couldn't use map nullable because team["team_by_pk"] is dynamic
          final Map<String, dynamic> teamByPk = team["team_by_pk"] != null
              ? team["team_by_pk"] as Map<String, dynamic>
              : throw Exception("that team doesnt exist");
          final Map<String, dynamic>? pit =
              (teamByPk["pit"] as Map<String, dynamic>?);
          final SpecificData specificData = SpecificData(
            (teamByPk["specifics"] as List<dynamic>)
                .map((final dynamic e) => e["message"] as String)
                .toList(),
          );

          final PitData? pitData = pit.mapNullable<PitData>(
            (final Map<String, dynamic> p0) => PitData(
              driveMotorAmount: p0["drive_motor_amount"] as int,
              driveTrainReliability: p0["drive_train_reliability"] as int,
              driveWheelType: p0["drive_wheel_type"] as String,
              electronicsReliability: p0["electronics_reliability"] as int,
              gearboxPurchased: p0["gearbox_purchased"] as bool?,
              notes: p0["notes"] as String,
              robotReliability: p0["robot_reliability"] as int,
              hasShifer: p0["has_shifter"] as bool?,
              url: p0["url"] as String,
              driveTrainType: p0["drivetrain"]["title"] as String,
              driveMotorType: p0["drivemotor"]["title"] as String,
            ),
          );
          final double avgAutoLow = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["auto_lower"] as double? ??
              0;
          final double avgAutoMissed = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["auto_missed"] as double? ??
              0;
          final double avgAutoUpperScored = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["auto_upper"] as double? ??
              0;
          final double avgTeleLow = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["tele_lower"] as double? ??
              0;
          final double avgTeleMissed = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["tele_missed"] as double? ??
              0;
          final double avgTeleUpperScored = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["tele_upper"] as double? ??
              0;

          final List<String> climbTitles =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["climb"]["title"] as String)
                  .toList();

          final List<int> climbPoints = (teamByPk["matches"] as List<dynamic>)
              .map((final dynamic e) => e["climb"]["points"] as int)
              .toList();
          final QuickData quickData = QuickData(
            avgAutoLowScored: avgAutoLow,
            avgAutoMissed: avgAutoMissed,
            avgAutoUpperScored: avgAutoUpperScored,
            avgBallPoints: avgTeleUpperScored * 2 +
                avgTeleLow +
                avgAutoUpperScored * 4 +
                avgAutoLow * 2,
            avgClimbPoints: climbPoints.isEmpty
                ? 0.0
                : climbPoints.length == 1
                    ? climbPoints.single.toDouble()
                    : climbPoints.reduce(
                          (final int value, final int element) =>
                              value + element,
                        ) /
                        climbPoints.length,
            avgTeleLowScored: avgTeleLow,
            avgTeleMissed: avgTeleMissed,
            avgTeleUpperScored: avgTeleUpperScored,
            scorePercentAuto: ((avgAutoUpperScored + avgAutoLow) /
                    (avgAutoUpperScored + avgAutoMissed + avgAutoLow)) *
                100,
            scorePercentTele: ((avgTeleUpperScored + avgTeleLow) /
                    (avgTeleUpperScored + avgTeleMissed + avgTeleLow)) *
                100,
          );

          final List<int> climbLineChartPoints =
              climbTitles.map<int>((final String e) {
            switch (e) {
              case "Failed":
                return 0;
              case "No attempt":
                return -1;
              case "Level 1":
                return 1;
              case "Level 2":
                return 2;
              case "Level 3":
                return 3;
              case "Level 4":
                return 4;
            }
            throw Exception("Not a climb value");
          }).toList();
          final List<int> matchNumbers = (teamByPk["matches"] as List<dynamic>)
              .map((final dynamic e) => e["match_number"] as int)
              .toList();

          final LineChartData<E> climbData = LineChartData<E>(
            gameNumbers: matchNumbers,
            points: <List<E>>[climbLineChartPoints.castToGeneric<E>().toList()],
            title: "Climb",
          );

          final List<E> upperScoredDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_upper"] as int)
                  .castToGeneric<E>()
                  .toList();
          final List<E> missedDataTele = (teamByPk["matches"] as List<dynamic>)
              .map((final dynamic e) => e["tele_missed"] as int)
              .castToGeneric<E>()
              .toList();

          final List<E> lowerScoredDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_lower"] as int)
                  .castToGeneric<E>()
                  .toList();

          final LineChartData<E> scoredMissedDataTele = LineChartData<E>(
            gameNumbers: matchNumbers,
            points: <List<E>>[
              upperScoredDataTele,
              missedDataTele,
              lowerScoredDataTele
            ],
            title: "Teleoperated",
          );

          final List<E> upperScoredDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_upper"] as int)
                  .castToGeneric<E>()
                  .toList();
          final List<E> missedDataAuto = (teamByPk["matches"] as List<dynamic>)
              .map((final dynamic e) => e["auto_missed"] as int)
              .castToGeneric<E>()
              .toList();
          final List<E> lowerScoredDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_lower"] as int)
                  .castToGeneric<E>()
                  .toList();
          final LineChartData<E> scoredMissedDataAuto = LineChartData<E>(
            gameNumbers: matchNumbers,
            points: <List<E>>[
              upperScoredDataAuto,
              missedDataAuto,
              lowerScoredDataAuto
            ],
            title: "Autonomous",
          );
          return Team<E>(
            team: teamForQuery,
            specificData: specificData,
            pitViewData: pitData,
            quickData: quickData,
            climbData: climbData,
            scoredMissedDataTele: scoredMissedDataTele,
            scoredMissedDataAuto: scoredMissedDataAuto,
          );
        }) ??
        (throw Exception("No team with that id")),
  );
}
