import "package:flutter/cupertino.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/average_or_null.dart";
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

        final dynamic avg =
            teamByPk["technical_matches_aggregate"]["aggregate"]["avg"];
        double avgNullToZero(
          final MatchMode mode,
          final Gamepiece piece, [
          final GridLevel? level,
        ]) =>
            avg["${mode.title}_${piece.title}_${level?.title ?? "failed"}"]
                as double? ??
            0;

        final double autoConesTop = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cone,
          GridLevel.top,
        );
        final double autoConesMid = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cone,
          GridLevel.mid,
        );
        final double autoConesLow = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cone,
          GridLevel.low,
        );
        final double autoConesFailed =
            avgNullToZero(MatchMode.auto, Gamepiece.cone);
        final double teleConesTop = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cone,
          GridLevel.top,
        );
        final double teleConesMid = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cone,
          GridLevel.mid,
        );
        final double teleConesLow = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cone,
          GridLevel.low,
        );
        final double teleConesFailed =
            avgNullToZero(MatchMode.tele, Gamepiece.cone);
        final double autoCubesTop = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cube,
          GridLevel.top,
        );
        final double autoCubesMid = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cube,
          GridLevel.mid,
        );
        final double autoCubesLow = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cube,
          GridLevel.low,
        );
        final double autoCubesFailed =
            avgNullToZero(MatchMode.auto, Gamepiece.cube);
        final double teleCubesTop =
            avgNullToZero(MatchMode.tele, Gamepiece.cube, GridLevel.top);
        final double teleCubesMid =
            avgNullToZero(MatchMode.tele, Gamepiece.cube, GridLevel.mid);
        final double teleCubesLow =
            avgNullToZero(MatchMode.tele, Gamepiece.cube, GridLevel.low);
        final double teleCubesFailed = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cube,
        );

        final List<dynamic> matches =
            (teamByPk["technical_matches"] as List<dynamic>);

        List<int> balancePoints(final String mode) => matches
            .where(
              (final dynamic match) =>
                  match["${mode}_balance"]["title"] != "No attempt",
            )
            .map(
              (final dynamic match) =>
                  match["${mode}_balance"]["${mode}_points"] as int,
            )
            .toList();

        int matchesBalanced(final String mode) => matches
            .where(
              (final dynamic match) =>
                  match["${mode}_balance"]["title"] != "No attempt" &&
                  match["${mode}_balance"]["title"] != "Failed",
            )
            .length;
        final List<int> autoBalancePoints = balancePoints("auto");
        final List<int> endgameBalancePoints = balancePoints("endgame");
        final SpecificData specificData = SpecificData(
          (teamByPk["_2023_specifics"] as List<dynamic>)
              .map(
                (final dynamic e) => SpecificMatch(
                  drivetrainAndDriving: e["drivetrain_and_driving"] as String?,
                  intake: e["intake"] as String?,
                  placement: e["placement"] as String?,
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
        final bool nullValidator = avg["auto_cones_top"] == null;
        final QuickData quickData = QuickData(
          matchesBalancedAuto: matchesBalanced("auto"),
          matchesBalancedEndgame: matchesBalanced("endgame"),
          firstPicklistIndex: team["team_by_pk"]["first_picklist_index"] as int,
          secondPicklistIndex:
              team["team_by_pk"]["second_picklist_index"] as int,
          highestBalanceTitleAuto: matches.isEmpty
              ? "highestLevelTitle QuickData: this isn't supposed to be shown because of amoutOfMatches check in ui"
              : matches
                  .map<dynamic>((final dynamic e) => e["auto_balance"])
                  .reduceSafe(
                    (final dynamic value, final dynamic element) =>
                        (value["auto_points"] as int) >
                                (element["auto_points"] as int)
                            ? value
                            : element,
                  )["title"] as String,
          amoutOfMatches: matches.length,
          avgAutoBalancePoints: autoBalancePoints.averageOrNull ?? 0,
          avgEndgameBalancePoints: endgameBalancePoints.averageOrNull ?? 0,
          avgGamepieces: nullValidator ? 0 : getPieces(parseMatch(avg)),
          avgGamepiecePoints: nullValidator ? 0 : getPoints(parseMatch(avg)),
          avgAutoGamepieces:
              nullValidator ? 0 : getPieces(parseByMode(MatchMode.auto, avg)),
          avgTeleGamepieces:
              nullValidator ? 0 : getPieces(parseByMode(MatchMode.tele, avg)),
          avgAutoConesFailed: autoConesFailed,
          avgAutoConesLow: autoConesLow,
          avgAutoConesMid: autoConesMid,
          avgAutoConesTop: autoConesTop,
          avgAutoCubesFailed: autoCubesFailed,
          avgAutoCubesLow: autoCubesLow,
          avgAutoCubesMid: autoCubesMid,
          avgAutoCubesTop: autoCubesTop,
          avgTeleConesFailed: teleConesFailed,
          avgTeleConesLow: teleConesLow,
          avgTeleConesMid: teleConesMid,
          avgTeleConesTop: teleConesTop,
          avgTeleCubesFailed: teleCubesFailed,
          avgTeleCubesLow: teleCubesLow,
          avgTeleCubesMid: teleCubesMid,
          avgTeleCubesTop: teleCubesTop,
        );
        List<int> getBalanceLineChart(final String mode) => matches
                .map(
                  (final dynamic match) =>
                      match["${mode}_balance"]["title"] as String,
                )
                .toList()
                .map<int>((final String title) {
              switch (title) {
                case "Failed":
                  return 0;
                case "No Attempt":
                  return -1;
                case "Unbalanced":
                  return 1;
                case "Balanced":
                  return 2;
              }
              throw Exception("Not a balance value");
            }).toList();

        final List<int> autoBalanceLineChart = getBalanceLineChart("auto");
        final List<int> endgameBalanceLineChart =
            getBalanceLineChart("endgame");
        final List<MatchIdentifier> matchNumbers = matches
            .map(
              (final dynamic e) => MatchIdentifier(
                number: e["match"]["match_number"] as int,
                type: e["match"]["match_type"]["title"] as String,
                isRematch: e["is_rematch"] as bool,
              ),
            )
            .toList();

        LineChartData getBalanceChartData(final bool isAuto) => LineChartData(
              gameNumbers: matchNumbers,
              points: <List<int>>[
                isAuto
                    ? autoBalanceLineChart.toList()
                    : endgameBalanceLineChart.toList()
              ],
              title: "${isAuto ? "Auto" : "Endgame"} Balance",
              robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
                4,
                (teamByPk["technical_matches"] as List<dynamic>)
                    .map(
                      (final dynamic e) => titleToEnum(
                        e["robot_match_status"]["title"] as String,
                      ),
                    )
                    .toList(),
              ),
            );
        final LineChartData autoBalanceData = getBalanceChartData(true);
        final LineChartData endgameBalanceData = getBalanceChartData(false);

        LineChartData getGamepieceChartData(
          final MatchMode mode,
          final Gamepiece piece,
        ) =>
            LineChartData(
              gameNumbers: matchNumbers,
              points: <List<int>>[
                matches
                    .map(
                      (final dynamic match) =>
                          match["${mode.title}_${piece.title}_top"] as int,
                    )
                    .toList(),
                matches
                    .map(
                      (final dynamic match) =>
                          match["${mode.title}_${piece.title}_mid"] as int,
                    )
                    .toList(),
                matches
                    .map(
                      (final dynamic match) =>
                          match["${mode.title}_${piece.title}_low"] as int,
                    )
                    .toList(),
                matches
                    .map(
                      (final dynamic match) =>
                          match["${mode.title}_${piece.title}_failed"] as int,
                    )
                    .toList(),
              ],
              title:
                  "${mode == MatchMode.auto ? "Autonomous" : "Teleoperated"} ${piece.title}",
              robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
                4,
                (teamByPk["technical_matches"] as List<dynamic>)
                    .map(
                      (final dynamic e) => titleToEnum(
                        e["robot_match_status"]["title"] as String,
                      ),
                    )
                    .toList(),
              ),
            );

        final LineChartData scoredMissedDataTeleCones = getGamepieceChartData(
          MatchMode.tele,
          Gamepiece.cone,
        );

        final LineChartData scoredMissedDataAutoCones =
            getGamepieceChartData(MatchMode.auto, Gamepiece.cone);

        final LineChartData scoredMissedDataTeleCubes =
            getGamepieceChartData(MatchMode.tele, Gamepiece.cube);

        final LineChartData scoredMissedDataAutoCubes =
            getGamepieceChartData(MatchMode.auto, Gamepiece.cube);

        List<int> combineLists(
          final List<int> listOne,
          final List<int> listTwo,
        ) =>
            List<int>.generate(
              listOne.length,
              (final int index) => (listOne[index] + listTwo[index]),
            ).toList();
        List<int> getPiecesData(
          final MatchMode mode,
          final Gamepiece piece, [
          final GridLevel? level,
        ]) =>
            matches
                .map(
                  (final dynamic match) => match[
                          "${mode.title}_${piece.title}_${level?.title ?? "failed"}"]
                      as int,
                )
                .toList();
        LineChartData getScoredMissedData(final Gamepiece gamepiece) {
          List<int> gamepieceLevelData(
            final Gamepiece piece, [
            final GridLevel? level,
          ]) =>
              combineLists(
                getPiecesData(MatchMode.auto, piece, level),
                getPiecesData(MatchMode.tele, piece, level),
              );
          return LineChartData(
            gameNumbers: matchNumbers,
            points: <List<int>>[
              gamepieceLevelData(gamepiece, GridLevel.top),
              gamepieceLevelData(gamepiece, GridLevel.mid),
              gamepieceLevelData(gamepiece, GridLevel.low),
              gamepieceLevelData(gamepiece),
            ],
            title: gamepiece == Gamepiece.cone ? "Cones" : "Cubes",
            robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
              4,
              (teamByPk["technical_matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) => titleToEnum(
                      e["robot_match_status"]["title"] as String,
                    ),
                  )
                  .toList(),
            ),
          );
        }

        final LineChartData scoredMissedDataAllCones =
            getScoredMissedData(Gamepiece.cone);

        final LineChartData scoredMissedDataAllCubes =
            getScoredMissedData(Gamepiece.cube);
        final LineChartData scoredMissedDataAll = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[
            combineLists(
              scoredMissedDataAllCones.points[0],
              scoredMissedDataAllCubes.points[0],
            ),
            combineLists(
              scoredMissedDataAllCones.points[1],
              scoredMissedDataAllCubes.points[1],
            ),
            combineLists(
              scoredMissedDataAllCones.points[2],
              scoredMissedDataAllCubes.points[2],
            ),
            combineLists(
              scoredMissedDataAllCones.points[3],
              scoredMissedDataAllCubes.points[3],
            ),
          ],
          title: "Gamepieces",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            4,
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
            (teamByPk["technical_matches"] as List<dynamic>)
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
          scoredMissedDataAll: scoredMissedDataAll,
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
