import "package:flutter/cupertino.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

const String teamInfoQuery = """
query MyQuery(\$id: Int!) {
  team_by_pk(id: \$id) {
    first_picklist_index
    second_picklist_index
    id
    broken_robots {

    message
    }
    pit {
      drive_motor_amount
      drive_wheel_type
      gearbox_purchased
      notes
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
      match_number
      match_type_id
      is_rematch
      scouter_name
    }
    matches_aggregate(where: {ignored: {_eq: false}}) {
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
    matches(where: {ignored: {_eq: false}}, order_by: {match_type: {order: asc}, match_number: asc,is_rematch: asc}) {
      climb {
        points
        title
      }
      match_type {
        title
      }
      robot_match_status{
        title
      }
      is_rematch
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
  final BuildContext context,
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

          final List<String> faultMessages =
              (teamByPk["broken_robots"] as List<dynamic>)
                  .map((final dynamic e) => e["message"] as String)
                  .toList();
          final PitData? pitData = pit.mapNullable<PitData>(
            (final Map<String, dynamic> p0) => PitData(
              driveMotorAmount: p0["drive_motor_amount"] as int,
              driveWheelType: p0["drive_wheel_type"] as String,
              gearboxPurchased: p0["gearbox_purchased"] as bool?,
              notes: p0["notes"] as String,
              hasShifer: p0["has_shifter"] as bool?,
              url: p0["url"] as String,
              driveTrainType: p0["drivetrain"]["title"] as String,
              driveMotorType: p0["drivemotor"]["title"] as String,
              faultMessages: faultMessages,
            ),
          );

          final double avgAutoLow = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["auto_lower"] as double? ??
              0;
          final double avgAutoMissed = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["auto_missed"] as double? ??
              0;
          final double avgAutoUpper = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["auto_upper"] as double? ??
              0;
          final double avgTeleLow = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["tele_lower"] as double? ??
              0;
          final double avgTeleMissed = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["tele_missed"] as double? ??
              0;
          final double avgTeleUpper = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["tele_upper"] as double? ??
              0;
          final List<dynamic> matches = (teamByPk["matches"] as List<dynamic>);
          final List<String> climbTitles = matches
              .map((final dynamic e) => e["climb"]["title"] as String)
              .toList();

          final List<int> climbPoints = matches
              .where(
                (final dynamic element) =>
                    element["climb"]["title"] != "No attempt",
              )
              .map((final dynamic e) => e["climb"]["points"] as int)
              .toList();
          final SpecificData specificData = SpecificData(
            (teamByPk["specifics"] as List<dynamic>)
                .map(
                  (final dynamic e) => SpecificMatch(
                    message: e["message"] as String,
                    isRematch: e["is_rematch"] as bool,
                    matchNumber: e["match_number"] as int,
                    matchTypeId: e["match_type_id"] as int,
                    scouterNames: e["scouter_name"] as String,
                  ),
                )
                .toList(),
          );
          final QuickData quickData = QuickData(
            firstPicklistIndex:
                team["team_by_pk"]["first_picklist_index"] as int,
            secondPicklistIndex:
                team["team_by_pk"]["second_picklist_index"] as int,
            highestLevelTitle: matches.isEmpty
                ? "highestLevelTitle QuickData: this isn't supposed to be shown because of amoutOfMatches check in ui"
                : matches.length == 1
                    ? matches.single["climb"]["title"] as String
                    : matches
                        .map<dynamic>((final dynamic e) => e["climb"])
                        .reduce(
                          (final dynamic value, final dynamic element) =>
                              (value["points"] as int) >
                                      (element["points"] as int)
                                  ? value
                                  : element,
                        )["title"] as String,
            avgAutoLowScored: avgAutoLow,
            avgAutoMissed: avgAutoMissed,
            avgAutoUpperScored: avgAutoUpper,
            avgBallPoints: avgTeleUpper * 2 +
                avgTeleLow +
                avgAutoUpper * 4 +
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
            avgTeleUpperScored: avgTeleUpper,
            amoutOfMatches: matches.length,
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

          final List<MatchIdentifier> matchNumbers = matches
              .map(
                (final dynamic e) => MatchIdentifier(
                  number: e["match_number"] as int,
                  type: e["match_type"]["title"] as String,
                  isRematch: e["is_rematch"] as bool,
                ),
              )
              .toList();

          final LineChartData<E> climbData = LineChartData<E>(
            gameNumbers: matchNumbers,
            points: <List<E>>[climbLineChartPoints.castToGeneric<E>().toList()],
            title: "Climb",
            robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
              3,
              (teamByPk["matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) =>
                        titleToEnum(e["robot_match_status"]["title"] as String),
                  )
                  .toList(),
            ),
          );

          final List<E> upperScoredDataTele = matches
              .map((final dynamic e) => e["tele_upper"] as int)
              .castToGeneric<E>()
              .toList();
          final List<E> missedDataTele = matches
              .map((final dynamic e) => e["tele_missed"] as int)
              .castToGeneric<E>()
              .toList();

          final List<E> lowerScoredDataTele = matches
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
            robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
              3,
              (teamByPk["matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) =>
                        titleToEnum(e["robot_match_status"]["title"] as String),
                  )
                  .toList(),
            ),
          );

          final List<E> upperScoredDataAuto = matches
              .map((final dynamic e) => e["auto_upper"] as int)
              .castToGeneric<E>()
              .toList();
          final List<E> missedDataAuto = matches
              .map((final dynamic e) => e["auto_missed"] as int)
              .castToGeneric<E>()
              .toList();
          final List<E> lowerScoredDataAuto = matches
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
            robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
              3,
              (teamByPk["matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) => titleToEnum(
                      e["robot_match_status"]["title"] as String,
                    ),
                  )
                  .toList(),
            ),
          );

          List<E> combineLists(final List<E> listOne, final List<E> listTwo) =>
              List<num>.generate(
                listOne.length,
                (final int index) => (listOne[index] + listTwo[index]),
              ).castToGeneric<E>().toList();

          final LineChartData<E> scoredMissedDataAll = LineChartData<E>(
            gameNumbers: matchNumbers,
            points: <List<E>>[
              combineLists(upperScoredDataAuto, upperScoredDataTele),
              combineLists(missedDataAuto, missedDataTele),
              combineLists(lowerScoredDataAuto, lowerScoredDataTele)
            ],
            title: "Tele+Auto",
            robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
              3,
              (teamByPk["matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) => titleToEnum(
                      e["robot_match_status"]["title"] as String,
                    ),
                  )
                  .toList(),
            ),
          );

          final LineChartData<E> pointsData = LineChartData<E>(
            points: <List<E>>[
              matches
                  .map(
                    (final dynamic e) =>
                        (e["auto_upper"] as int) * 4 +
                        (e["auto_lower"] as int) * 2 +
                        (e["tele_upper"] as int) * 2 +
                        (e["tele_lower"] as int) +
                        (e["climb"]["points"] as int),
                  )
                  .castToGeneric<E>()
                  .toList()
            ],
            title: "Points",
            gameNumbers: matchNumbers,
            robotMatchStatuses: <List<RobotMatchStatus>>[
              (teamByPk["matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) => titleToEnum(
                      e["robot_match_status"]["title"] as String,
                    ),
                  )
                  .toList()
            ],
          );
          return Team<E>(
            pointsData: pointsData,
            scoredMissedDataAll: scoredMissedDataAll,
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
