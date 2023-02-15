import "package:flutter/cupertino.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

const String teamInfoQuery = """
query TeamInfo(\$id: Int!) {
  team_by_pk(id: \$id) {
    first_picklist_index
    second_picklist_index
    id
    faults {
      message
    }
    _2023_pit {
      weight
      width
      length
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
    _2023_specifics{
      defense
      drivetrain_and_driving
      general_notes
      intake
      placement
      is_rematch
      scouter_name
      match{
        match_type_id 
        match_number
      }
    }
    technical_matches_aggregate(where: {ignored: {_eq: false}}) {
      aggregate {
        avg {
          auto_cones_low
          auto_cones_mid
          auto_cones_top
          auto_cones_failed
          auto_cubes_low
          auto_cubes_mid
          auto_cubes_top
          auto_cubes_failed
          tele_cones_low
          tele_cones_mid
          tele_cones_top
          tele_cones_failed
          tele_cubes_low
          tele_cubes_mid
          tele_cubes_top
          tele_cubes_failed
        }
      }
    }
    technical_matches(
      where: {ignored: {_eq: false}}
      order_by: [{match: {match_type: {order: asc}}}, {match: {match_number: asc}}, {is_rematch: asc}]
    ) {
      auto_balance {
        auto_points
        title
      }
      endgame_balance {
        endgame_points
        title
      }
      match {
        match_type {
          title
        }
      }
      robot_match_status {
        title
      }
      is_rematch
      auto_cones_low
      auto_cones_mid
      auto_cones_top
      auto_cones_failed
      auto_cubes_low
      auto_cubes_mid
      auto_cubes_top
      auto_cubes_failed
      match {
        match_number
      }
      tele_cones_low
      tele_cones_mid
      tele_cones_top
      tele_cones_failed
      tele_cubes_low
      tele_cubes_mid
      tele_cubes_top
      tele_cubes_failed
    }
  }
}


""";

Future<Team> fetchTeamInfo(
  final LightTeam teamForQuery,
  final BuildContext context,
) async {
  final GraphQLClient client = getClient();

  final QueryResult<Team> result = await client.query(
    QueryOptions<Team>(
      parserFn: (final Map<String, dynamic> team) {
        //couldn't use map nullable because team["team_by_pk"] is dynamic
        final Map<String, dynamic> teamByPk = team["team_by_pk"] != null
            ? team["team_by_pk"] as Map<String, dynamic>
            : throw Exception("that team doesnt exist");
        final Map<String, dynamic>? pit =
            (teamByPk["_2023_pit"] as Map<String, dynamic>?);

        final List<String> faultMessages = (teamByPk["faults"] as List<dynamic>)
            .map((final dynamic e) => e["message"] as String)
            .toList();
        final PitData? pitData = pit.mapNullable<PitData>(
          (final Map<String, dynamic> p0) => PitData(
            weight: p0["weight"] as int,
            width: p0["width"] as int,
            length: p0["length"] as int,
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

        //       final dynamic avg =
        //    teamByPk["technical_matches_aggregate"]["aggregate"]["avg"];
        ////TODO add a function for 'avg["auto_cones_top"] as double? ?? 0'
        // final double autoConesTop = avg["auto_cones_top"] as double? ?? 0;
        // final double autoConesMid = avg["auto_cones_mid"] as double? ?? 0;
        // final double autoConesLow = avg["auto_cones_low"] as double? ?? 0;
        // final double autoConesFailed = avg["auto_cones_failed"] as double? ?? 0;
        // final double teleConesTop = avg["tele_cones_top"] as double? ?? 0;
        // final double teleConesMid = avg["tele_cones_mid"] as double? ?? 0;
        // final double teleConesLow = avg["tele_cones_low"] as double? ?? 0;
        // final double teleConesFailed = avg["tele_cones_failed"] as double? ?? 0;
        // final double autoCubesTop = avg["auto_cubes_top"] as double? ?? 0;
        // final double autoCubesMid = avg["auto_cubes_mid"] as double? ?? 0;
        // final double autoCubesLow = avg["auto_cubes_low"] as double? ?? 0;
        // final double autoCubesFailed = avg["auto_cubes_failed"] as double? ?? 0;
        // final double teleCubesTop = avg["tele_cubes_top"] as double? ?? 0;
        // final double teleCubesMid = avg["tele_cubes_mid"] as double? ?? 0;
        // final double teleCubesLow = avg["tele_cubes_low"] as double? ?? 0;
        // final double teleCubesFailed = avg["tele_cubes_failed"] as double? ?? 0;

        final double avgAutoLow = teamByPk["matches_aggregate"]["aggregate"]
                ["avg"]["auto_lower"] as double? ??
            0;
        final double avgAutoMissed = teamByPk["matches_aggregate"]["aggregate"]
                ["avg"]["auto_missed"] as double? ??
            0;
        final double avgAutoUpper = teamByPk["matches_aggregate"]["aggregate"]
                ["avg"]["auto_upper"] as double? ??
            0;
        final double avgTeleLow = teamByPk["matches_aggregate"]["aggregate"]
                ["avg"]["tele_lower"] as double? ??
            0;
        final double avgTeleMissed = teamByPk["matches_aggregate"]["aggregate"]
                ["avg"]["tele_missed"] as double? ??
            0;
        final double avgTeleUpper = teamByPk["matches_aggregate"]["aggregate"]
                ["avg"]["tele_upper"] as double? ??
            0;
        final List<dynamic> matches =
            (teamByPk["technical_matches"] as List<dynamic>);

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
                  drivetrainAndDriving: e["drivetrain_and_driving"] as String?,
                  intakeAndConveyor: e["intake_and_conveyor"] as String?,
                  shooter: e["shooter"] as String?,
                  climb: e["climb"] as String?,
                  generalNotes: e["general_notes"] as String?,
                  defense: e["defense"] as String?,
                  isRematch: e["is_rematch"] as bool,
                  matchNumber: e["match"]["match_number"] as int,
                  matchTypeId: e["match"]["match_type_id"] as int,
                  scouterNames: e["scouter_name"] as String,
                ),
              )
              .toList(),
        );
        final QuickData quickData = QuickData(
          matchesClimbed: matches
              .where(
                (final dynamic element) =>
                    element["climb"]["title"] != "No attempt" &&
                    element["climb"]["title"] != "Failed",
              )
              .length,
          firstPicklistIndex: team["team_by_pk"]["first_picklist_index"] as int,
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
          avgBallPoints:
              avgTeleUpper * 2 + avgTeleLow + avgAutoUpper * 4 + avgAutoLow * 2,
          avgClimbPoints: climbPoints.isEmpty
              ? 0.0
              : climbPoints.length == 1
                  ? climbPoints.single.toDouble()
                  : climbPoints.reduce(
                        (final int value, final int element) => value + element,
                      ) /
                      climbPoints.length,
          avgTeleLowScored: avgTeleLow,
          avgTeleMissed: avgTeleMissed,
          avgTeleUpperScored: avgTeleUpper,
          amoutOfMatches: matches.length,
        );
        final List<String> autoBalanceTitles = matches
            .map((final dynamic e) => e["auto_balance"]["title"] as String)
            .toList();
        final List<String> endgameBalanceTitles = matches
            .map((final dynamic e) => e["tele_balance"]["title"] as String)
            .toList();

        //TODO fix code dupe
        final List<int> autoBalanceLineChart =
            autoBalanceTitles.map<int>((final String e) {
          switch (e) {
            case "Failed":
              return 0;
            case "No attempt":
              return -1;
            case "Unbalanced":
              return 1;
            case "Balanced":
              return 2;
          }
          throw Exception("Not a balance value");
        }).toList();

        final List<int> endgameBalanceLineChart =
            endgameBalanceTitles.map<int>((final String e) {
          switch (e) {
            case "Failed":
              return 0;
            case "No attempt":
              return -1;
            case "Unbalanced":
              return 1;
            case "Balanced":
              return 2;
          }
          throw Exception("Not a balance value");
        }).toList();

        final List<MatchIdentifier> matchNumbers = matches
            .map(
              (final dynamic e) => MatchIdentifier(
                number: e["match"]["match_number"] as int,
                type: e["match"]["match_type"]["title"] as String,
                isRematch: e["is_rematch"] as bool,
              ),
            )
            .toList();

        final LineChartData autoBalanceData = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[autoBalanceLineChart.toList()],
          title: "Auto Balance",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            3,
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic e) =>
                      titleToEnum(e["robot_match_status"]["title"] as String),
                )
                .toList(),
          ),
        );
        final LineChartData endgameBalanceData = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[endgameBalanceLineChart.toList()],
          title: "Endgame Balance",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            3,
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic e) =>
                      titleToEnum(e["robot_match_status"]["title"] as String),
                )
                .toList(),
          ),
        );
        final List<int> teleConesTopData = matches
            .map((final dynamic e) => e["tele_cones_top"] as int)
            .toList();
        final List<int> teleConesMidData = matches
            .map((final dynamic e) => e["tele_cones_mid"] as int)
            .toList();
        final List<int> teleConesLowData = matches
            .map((final dynamic e) => e["tele_cones_low"] as int)
            .toList();
        final List<int> teleConesFailedData = matches
            .map((final dynamic e) => e["tele_cones_failed"] as int)
            .toList();

        final LineChartData scoredMissedDataTeleCones = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[
            teleConesTopData,
            teleConesMidData,
            teleConesLowData,
            teleConesFailedData
          ],
          title: "Teleoperated Cones",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            3,
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic e) =>
                      titleToEnum(e["robot_match_status"]["title"] as String),
                )
                .toList(),
          ),
        );

        final List<int> autoConesTopData = matches
            .map((final dynamic e) => e["auto_cones_top"] as int)
            .toList();
        final List<int> autoConesMidData = matches
            .map((final dynamic e) => e["auto_cones_mid"] as int)
            .toList();
        final List<int> autoConesLowData = matches
            .map((final dynamic e) => e["auto_cones_low"] as int)
            .toList();
        final List<int> autoConesFailedData = matches
            .map((final dynamic e) => e["auto_cones_failed"] as int)
            .toList();

        final LineChartData scoredMissedDataAutoCones = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[
            autoConesTopData,
            autoConesMidData,
            autoConesLowData,
            autoConesFailedData
          ],
          title: "Autonomous Cones",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            3,
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic e) =>
                      titleToEnum(e["robot_match_status"]["title"] as String),
                )
                .toList(),
          ),
        );

        final List<int> teleCubesTopData = matches
            .map((final dynamic e) => e["tele_cubes_top"] as int)
            .toList();
        final List<int> teleCubesMidData = matches
            .map((final dynamic e) => e["tele_cubes_mid"] as int)
            .toList();
        final List<int> teleCubesLowData = matches
            .map((final dynamic e) => e["tele_cubes_low"] as int)
            .toList();
        final List<int> teleCubesFailedData = matches
            .map((final dynamic e) => e["tele_cubes_failed"] as int)
            .toList();

        final LineChartData scoredMissedDataTeleCubes = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[
            teleCubesTopData,
            teleCubesMidData,
            teleCubesLowData,
            teleCubesFailedData
          ],
          title: "Teleoperated Cubes",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            3,
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic e) =>
                      titleToEnum(e["robot_match_status"]["title"] as String),
                )
                .toList(),
          ),
        );

        final List<int> autoCubesTopData = matches
            .map((final dynamic e) => e["auto_cubes_top"] as int)
            .toList();
        final List<int> autoCubesMidData = matches
            .map((final dynamic e) => e["auto_cubes_mid"] as int)
            .toList();
        final List<int> autoCubesLowData = matches
            .map((final dynamic e) => e["auto_cubes_low"] as int)
            .toList();
        final List<int> autoCubesFailedData = matches
            .map((final dynamic e) => e["auto_cubes_failed"] as int)
            .toList();

        final LineChartData scoredMissedDataAutoCubes = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[
            autoCubesTopData,
            autoCubesMidData,
            autoCubesLowData,
            autoCubesFailedData
          ],
          title: "Autonomous Cubes",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            3,
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic e) =>
                      titleToEnum(e["robot_match_status"]["title"] as String),
                )
                .toList(),
          ),
        );

        List<int> combineLists(
          final List<int> listOne,
          final List<int> listTwo,
        ) =>
            List<int>.generate(
              listOne.length,
              (final int index) => (listOne[index] + listTwo[index]),
            ).toList();

        final LineChartData scoredMissedDataAllCones = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[
            combineLists(autoConesTopData, teleConesTopData),
            combineLists(autoConesMidData, teleConesMidData),
            combineLists(autoConesLowData, teleConesLowData),
            combineLists(autoConesFailedData, teleConesFailedData),
          ],
          title: "Tele+Auto Cones",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            3,
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic e) => titleToEnum(
                    e["robot_match_status"]["title"] as String,
                  ),
                )
                .toList(),
          ),
        );

        final LineChartData scoredMissedDataAllCubes = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[
            combineLists(autoCubesTopData, teleCubesTopData),
            combineLists(autoCubesMidData, teleCubesMidData),
            combineLists(autoCubesLowData, teleCubesLowData),
            combineLists(autoCubesFailedData, teleCubesFailedData),
          ],
          title: "Tele+Auto Cubes",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            3,
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic e) => titleToEnum(
                    e["robot_match_status"]["title"] as String,
                  ),
                )
                .toList(),
          ),
        );

        final LineChartData pointsData = LineChartData(
          points: <List<int>>[
            matches
                .map(
                  (final dynamic e) => getPoints(parseMatch(e)) as int,
                )
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
        return Team(
          pointsData: pointsData,
          scoredMissedDataAllCones: scoredMissedDataAllCones,
          scoredMissedDataAllCubes: scoredMissedDataAllCubes,
          team: teamForQuery,
          specificData: specificData,
          pitViewData: pitData,
          quickData: quickData,
          autoBalanceData: autoBalanceData,
          endgameBalanceData: endgameBalanceData,
          scoredMissedDataTeleCones: scoredMissedDataTeleCones,
          scoredMissedDataAutoCones: scoredMissedDataAutoCones,
          scoredMissedDataTeleCubes: scoredMissedDataTeleCubes,
          scoredMissedDataAutoCubes: scoredMissedDataAutoCubes,
        );
      },
      document: gql(teamInfoQuery),
      variables: <String, dynamic>{
        "id": teamForQuery.id,
      },
    ),
  );
  return result.mapQueryResult();
}
