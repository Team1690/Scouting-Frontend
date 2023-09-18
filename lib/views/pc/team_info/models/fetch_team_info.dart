import "package:flutter/cupertino.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";
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
      space_between_wheels
      length
      drive_motor_amount
      drive_wheel_type
      gearbox_purchased
      notes
      has_shifter
      url
      tipped_cones_intake
      typical_ground_intake
      typical_single_intake
      typical_double_intake
      can_score_top
      drivetrain {
        title
      }
      drivemotor {
        title
      }
    }
    _2023_specifics{
      schedule_match_id
      defense
      drivetrain_and_driving
      general_notes
      intake
      placement
      is_rematch
      scouter_name
      defense_amount_id
      match{
        match_type_id
        match_number
      }
      defense_amount{
        title
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
          auto_cones_delivered
          auto_cubes_delivered
          tele_cones_delivered
          tele_cubes_delivered
          balanced_with
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
      robot_placement{
        title
      }
      schedule_match_id
      balanced_with
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
      auto_cones_delivered
      auto_cubes_delivered
      tele_cones_delivered
      tele_cubes_delivered
      auto_mobility
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
          (final Map<String, dynamic> pitTable) => PitData(
            weight: pitTable["weight"] as int,
            width: pitTable["width"] as int,
            spaceBetweenWheels: pitTable["space_between_wheels"] as int,
            length: pitTable["length"] as int,
            driveMotorAmount: pitTable["drive_motor_amount"] as int,
            driveWheelType: pitTable["drive_wheel_type"] as String,
            gearboxPurchased: pitTable["gearbox_purchased"] as bool?,
            notes: pitTable["notes"] as String,
            hasShifer: pitTable["has_shifter"] as bool?,
            url: pitTable["url"] as String,
            driveTrainType: pitTable["drivetrain"]["title"] as String,
            driveMotorType: pitTable["drivemotor"]["title"] as String,
            faultMessages: faultMessages,
            tippedConesIntake: pitTable["tipped_cones_intake"] as bool,
            canScoreTop: pitTable["can_score_top"] as bool,
            groundIntake: pitTable["typical_ground_intake"] as bool,
            singleSubIntake: pitTable["typical_single_intake"] as bool,
            doubleSubIntake: pitTable["typical_double_intake"] as bool,
            team: teamForQuery,
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
        final double autoConesDelivered = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cone,
          GridLevel.none,
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
        final double teleConesDelivered = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cone,
          GridLevel.none,
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
        final double autoCubesDelivered = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cube,
          GridLevel.none,
        );
        final double autoCubesFailed =
            avgNullToZero(MatchMode.auto, Gamepiece.cube);
        final double teleCubesTop =
            avgNullToZero(MatchMode.tele, Gamepiece.cube, GridLevel.top);
        final double teleCubesMid =
            avgNullToZero(MatchMode.tele, Gamepiece.cube, GridLevel.mid);
        final double teleCubesLow =
            avgNullToZero(MatchMode.tele, Gamepiece.cube, GridLevel.low);
        final double teleCubesDelivered = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cube,
          GridLevel.none,
        );
        final double teleCubesFailed = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cube,
        );

        final List<dynamic> matches =
            (teamByPk["technical_matches"] as List<dynamic>);
        List<int> balancePoints(final MatchMode mode) => matches
            .where(
              (final dynamic match) => match["robot_match_status"]["title"] !=
                      "Didn't come to field"
                  ? match["${mode == MatchMode.auto ? mode.title : "endgame"}_balance"]
                          ["title"] !=
                      "No attempt"
                  : false,
            )
            .map(
              (final dynamic match) => match[
                      "${mode == MatchMode.auto ? mode.title : "endgame"}_balance"]
                  [
                  "${mode == MatchMode.auto ? mode.title : "endgame"}_points"] as int,
            )
            .toList();
        int matchesBalanced(final MatchMode mode, final List<dynamic> data) =>
            data
                .where(
                  (final dynamic match) => match["robot_match_status"]
                              ["title"] !=
                          "Didn't come to field"
                      ? match["${mode == MatchMode.auto ? mode.title : "endgame"}_balance"]
                                  ["title"] !=
                              "No attempt" &&
                          match["${mode.title == MatchMode.auto.title ? mode.title : "endgame"}_balance"]
                                  ["title"] !=
                              "Failed"
                      : false,
                )
                .length;
        final List<int> autoBalancePoints = balancePoints(MatchMode.auto);
        final List<int> endgameBalancePoints = balancePoints(MatchMode.tele);
        final SpecificData specificData = SpecificData(
          (teamByPk["_2023_specifics"] as List<dynamic>)
              .map(
                (final dynamic specific) => SpecificMatch(
                  drivetrainAndDriving:
                      specific["drivetrain_and_driving"] as String?,
                  intake: specific["intake"] as String?,
                  placement: specific["placement"] as String?,
                  generalNotes: specific["general_notes"] as String?,
                  defense: specific["defense"] as String?,
                  isRematch: specific["is_rematch"] as bool,
                  matchNumber: specific["match"]["match_number"] as int,
                  matchTypeId: specific["match"]["match_type_id"] as int,
                  scouterNames: specific["scouter_name"] as String,
                ),
              )
              .toList(),
        );
        final bool nullValidator = avg["auto_cones_top"] == null;
        final double avgDelivered = nullValidator
            ? 0
            : autoCubesDelivered +
                autoConesDelivered +
                teleCubesDelivered +
                teleConesDelivered;
        final int matchesBalancedSingle = matches
            .where(
              (final dynamic match) => (match["balanced_with"] as int?) == 0,
            )
            .length;
        final int matchesBalancedDouble = matches
            .where(
              (final dynamic match) => (match["balanced_with"] as int?) == 1,
            )
            .length;
        final int matchesBalancedTriple = matches
            .where(
              (final dynamic match) => (match["balanced_with"] as int?) == 2,
            )
            .length;
        final int amountOfmobility = matches
            .where((final dynamic match) => (match["auto_mobility"] as bool))
            .length;
        final bool specificNullValidator =
            (teamByPk["_2023_specifics"] as List<dynamic>).isEmpty;
        final List<int> scheduleMatchesNoDefense = specificNullValidator
            ? <int>[]
            : (teamByPk["_2023_specifics"] as List<dynamic>)
                .where(
                  (final dynamic specific) =>
                      (specific["defense_amount_id"] as int) ==
                      IdProvider.of(context).defense.nameToId["No Defense"],
                )
                .map(
                  (final dynamic specific) =>
                      (specific["schedule_match_id"] as int),
                )
                .toList();
        final List<int> scheduleMatchesHalfDefense = specificNullValidator
            ? <int>[]
            : (teamByPk["_2023_specifics"] as List<dynamic>)
                .where(
                  (final dynamic specific) =>
                      (specific["defense_amount_id"] as int) ==
                      IdProvider.of(context).defense.nameToId["Half Defense"],
                )
                .map(
                  (final dynamic specific) =>
                      (specific["schedule_match_id"] as int),
                )
                .toList();
        final List<int> scheduleMatchesFullDefense = specificNullValidator
            ? <int>[]
            : (teamByPk["_2023_specifics"] as List<dynamic>)
                .where(
                  (final dynamic specific) =>
                      (specific["defense_amount_id"] as int) ==
                      IdProvider.of(context).defense.nameToId["Full Defense"],
                )
                .map(
                  (final dynamic specific) =>
                      (specific["schedule_match_id"] as int),
                )
                .toList();

        double getAvgByDefense(final List<dynamic> technicalMatches) =>
            technicalMatches.isEmpty && !nullValidator
                ? double.nan
                : technicalMatches
                        .map(
                          (final dynamic match) => getPieces(
                            parseMatch(match),
                          ),
                        )
                        .toList()
                        .averageOrNull ??
                    double.nan;
        final double avgGamepiecesNoDefense = nullValidator
            ? 0
            : getAvgByDefense(
                matches
                    .where(
                      (final dynamic match) => scheduleMatchesNoDefense
                          .contains(match["schedule_match_id"] as int),
                    )
                    .toList(),
              );
        final double avgGamepiecesHalfDefense = nullValidator
            ? 0
            : getAvgByDefense(
                matches
                    .where(
                      (final dynamic match) => scheduleMatchesHalfDefense
                          .contains(match["schedule_match_id"] as int),
                    )
                    .toList(),
              );
        final double avgGamepiecesFullDefense = nullValidator
            ? 0
            : getAvgByDefense(
                matches
                    .where(
                      (final dynamic match) => scheduleMatchesFullDefense
                          .contains(match["schedule_match_id"] as int),
                    )
                    .toList(),
              );
        final QuickData quickData = QuickData(
          amountOfMobility: amountOfmobility,
          matchesBalancedAuto: matchesBalanced(MatchMode.auto, matches),
          matchesBalancedEndgame: matchesBalanced(MatchMode.tele, matches),
          firstPicklistIndex: team["team_by_pk"]["first_picklist_index"] as int,
          secondPicklistIndex:
              team["team_by_pk"]["second_picklist_index"] as int,
          highestBalanceTitleAuto: matches.isEmpty
              ? "highestLevelTitle QuickData: this isn't supposed to be shown because of amoutOfMatches check in ui"
              : matches
                  .where(
                    (final dynamic match) =>
                        match["robot_match_status"]["title"] !=
                        "Didn't come to field",
                  )
                  .map<Map<String, dynamic>>(
                    (final dynamic match) =>
                        match["auto_balance"] as Map<String, dynamic>,
                  )
                  .fold(
                  <String, dynamic>{"auto_points": 0, "title": "No attempt"},
                  (
                    final Map<String, dynamic> value,
                    final Map<String, dynamic> element,
                  ) =>
                      (value["auto_points"] as int) >
                              (element["auto_points"] as int)
                          ? value
                          : element,
                )["title"] as String,
          amoutOfMatches: matches.length,
          avgAutoBalancePoints: autoBalancePoints.averageOrNull ?? 0,
          avgEndgameBalancePoints: endgameBalancePoints.averageOrNull ?? 0,
          avgGamepieces:
              nullValidator ? 0 : getPieces(parseMatch(avg)) - avgDelivered,
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
          avgAutoConesDelivered: autoConesDelivered,
          avgAutoCubesDelivered: autoCubesDelivered,
          avgTeleConesDelivered: teleConesDelivered,
          avgTeleCubesDelivered: teleCubesDelivered,
          avgDelivered: avgDelivered,
          matchesBalancedSingle: matchesBalancedSingle,
          matchesBalancedDouble: matchesBalancedDouble,
          matchesBalancedTriple: matchesBalancedTriple,
          avgGamePiecesNoDefense: avgGamepiecesNoDefense,
          avgGamePiecesHalfDefense: avgGamepiecesHalfDefense,
          avgGamePiecesFullDefense: avgGamepiecesFullDefense,
        );
        List<int> getBalanceLineChart(final MatchMode mode) => matches
                .map(
                  (final dynamic match) => match["robot_match_status"]
                              ["title"] !=
                          "Didn't come to field"
                      ? match["${mode == MatchMode.auto ? mode.title : "endgame"}_balance"]
                          ["title"] as String
                      : "No attempt",
                )
                .toList()
                .map<int>((final String title) {
              switch (title) {
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

        final List<int> autoBalanceLineChart =
            getBalanceLineChart(MatchMode.auto);
        final List<int> endgameBalanceLineChart =
            getBalanceLineChart(MatchMode.tele);
        final List<MatchIdentifier> matchNumbers = matches
            .map(
              (final dynamic match) => MatchIdentifier(
                number: match["match"]["match_number"] as int,
                type: match["match"]["match_type"]["title"] as String,
                isRematch: match["is_rematch"] as bool,
              ),
            )
            .toList();
        LineChartData getBalanceChartData(final bool isAuto) => LineChartData(
              gameNumbers: matchNumbers,
              points: <List<int>>[
                isAuto
                    ? autoBalanceLineChart.toList()
                    : endgameBalanceLineChart.toList(),
              ],
              title: "${isAuto ? "Auto" : "Endgame"} Balance",
              robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
                1,
                (teamByPk["technical_matches"] as List<dynamic>)
                    .map(
                      (final dynamic match) => robotMatchStatusTitleToEnum(
                        match["robot_match_status"]["title"] as String,
                      ),
                    )
                    .toList(),
              ),
              defenseAmounts: List<List<DefenseAmount>>.filled(
                1,
                (teamByPk["technical_matches"] as List<dynamic>)
                    .map(
                      (final dynamic match) => DefenseAmount
                          .noDefense, //defense should not be shown in Balance Charts
                    )
                    .toList(),
              ),
            );
        final LineChartData autoBalanceData = getBalanceChartData(true);
        final LineChartData endgameBalanceData = getBalanceChartData(false);
        final List<DefenseAmount> defenseAmountBeforeAdding =
            (teamByPk["_2023_specifics"] as List<dynamic>).isEmpty
                ? <DefenseAmount>[]
                : (teamByPk["_2023_specifics"] as List<dynamic>)
                    .map(
                      (final dynamic match) => specificNullValidator
                          ? DefenseAmount.noDefense
                          : defenseAmountTitleToEnum(
                              match["defense_amount"]["title"] as String,
                            ),
                    )
                    .toList();
        final List<List<DefenseAmount>> defenseAmount =
            List<List<DefenseAmount>>.filled(5, <DefenseAmount>[
          for (int i = 0;
              i < (teamByPk["technical_matches"] as List<dynamic>).length;
              i++)
            if (defenseAmountBeforeAdding.isEmpty ||
                i >= defenseAmountBeforeAdding.length)
              DefenseAmount.noDefense
            else
              defenseAmountBeforeAdding[i],
        ]);
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
                          match["${mode.title}_${piece.title}_delivered"]
                              as int,
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
                5,
                (teamByPk["technical_matches"] as List<dynamic>)
                    .map(
                      (final dynamic match) => robotMatchStatusTitleToEnum(
                        match["robot_match_status"]["title"] as String,
                      ),
                    )
                    .toList(),
              ),
              defenseAmounts: defenseAmount,
            );
        final LineChartData dataTeleCones = getGamepieceChartData(
          MatchMode.tele,
          Gamepiece.cone,
        );

        final LineChartData dataAutoCones =
            getGamepieceChartData(MatchMode.auto, Gamepiece.cone);

        final LineChartData dataTeleCubes =
            getGamepieceChartData(MatchMode.tele, Gamepiece.cube);

        final LineChartData dataAutoCubes =
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
              gamepieceLevelData(gamepiece, GridLevel.none),
              gamepieceLevelData(gamepiece),
            ],
            title: gamepiece == Gamepiece.cone ? "Cones" : "Cubes",
            robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
              5,
              (teamByPk["technical_matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) => robotMatchStatusTitleToEnum(
                      e["robot_match_status"]["title"] as String,
                    ),
                  )
                  .toList(),
            ),
            defenseAmounts: defenseAmount,
          );
        }

        final LineChartData dataAllCones = getScoredMissedData(Gamepiece.cone);

        final LineChartData dataAllCubes = getScoredMissedData(Gamepiece.cube);
        final LineChartData scoredMissedDataAll = LineChartData(
          gameNumbers: matchNumbers,
          points: <List<int>>[
            combineLists(
              dataAllCones.points[0],
              dataAllCubes.points[0],
            ),
            combineLists(
              dataAllCones.points[1],
              dataAllCubes.points[1],
            ),
            combineLists(
              dataAllCones.points[2],
              dataAllCubes.points[2],
            ),
            combineLists(
              dataAllCones.points[3],
              dataAllCubes.points[3],
            ),
            combineLists(
              dataAllCones.points[4],
              dataAllCubes.points[4],
            ),
          ],
          title: "Gamepieces",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            5,
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic match) => robotMatchStatusTitleToEnum(
                    match["robot_match_status"]["title"] as String,
                  ),
                )
                .toList(),
          ),
          defenseAmounts: defenseAmount,
        );
        final LineChartData gamepiecePointsData = LineChartData(
          points: <List<int>>[
            matches
                .map(
                  (final dynamic match) => getPoints(parseMatch(match)) as int,
                )
                .toList(),
          ],
          title: "Gamepieces Points",
          gameNumbers: matchNumbers,
          robotMatchStatuses: <List<RobotMatchStatus>>[
            (teamByPk["technical_matches"] as List<dynamic>)
                .map(
                  (final dynamic match) => robotMatchStatusTitleToEnum(
                    match["robot_match_status"]["title"] as String,
                  ),
                )
                .toList(),
          ],
          defenseAmounts: <List<DefenseAmount>>[defenseAmount[0]],
        );
        AutoByPosData getDataByNodeList(final List<dynamic> matchesInPos) =>
            AutoByPosData(
              amountOfMobility: matchesInPos
                  .where(
                    (final dynamic match) => match["auto_mobility"] as bool,
                  )
                  .length,
              matchesBalancedAuto:
                  matchesBalanced(MatchMode.auto, matchesInPos),
              highestBalanceTitleAuto: matchesInPos.isEmpty
                  ? "highestLevelTitle QuickData: this isn't supposed to be shown because of amoutOfMatches check in ui"
                  : matchesInPos
                      .where(
                        (final dynamic match) =>
                            match["robot_match_status"]["title"] !=
                            "Didn't come to field",
                      )
                      .map<Map<String, dynamic>>(
                        (final dynamic match) =>
                            match["auto_balance"] as Map<String, dynamic>,
                      )
                      .fold(
                      <String, dynamic>{
                        "auto_points": 0,
                        "title": "No attempt",
                      },
                      (
                        final Map<String, dynamic> value,
                        final Map<String, dynamic> element,
                      ) =>
                          (value["auto_points"] as int) >
                                  (element["auto_points"] as int)
                              ? value
                              : element,
                    )["title"] as String,
              avgBalancePoints: matchesInPos
                      .map<int>(
                        (final dynamic match) => match["robot_match_status"]
                                    ["title"] !=
                                "Didn't come to field"
                            ? match["auto_balance"]["auto_points"] as int
                            : 0,
                      )
                      .toList()
                      .averageOrNull ??
                  double.nan,
              amoutOfMatches: matchesInPos.length,
              avgAutoGampepiecePoints: matchesInPos
                      .map(
                        (final dynamic match) =>
                            getPoints(parseByMode(MatchMode.auto, match)),
                      )
                      .toList()
                      .averageOrNull ??
                  double.nan,
              avgAutoDelivered: matchesInPos
                      .map(
                        (final dynamic match) =>
                            (match["auto_cones_delivered"] as int) +
                            (match["auto_cubes_delivered"] as int),
                      )
                      .toList()
                      .averageOrNull ??
                  double.nan,
              avgAutoGampepieces: nullValidator
                  ? 0
                  : (matchesInPos
                          .map(
                            (final dynamic match) =>
                                getPieces(
                                  parseByMode(MatchMode.auto, match),
                                ) -
                                ((match["auto_cones_delivered"] as int) +
                                    (match["auto_cubes_delivered"] as int)),
                          )
                          .toList()
                          .averageOrNull ??
                      double.nan),
            );
        return Team(
          gamepiecePointsData: gamepiecePointsData,
          allConesData: dataAllCones,
          allCubesData: dataAllCubes,
          allData: scoredMissedDataAll,
          team: teamForQuery,
          specificData: specificData,
          pitViewData: pitData,
          quickData: quickData,
          autoBalanceData: autoBalanceData,
          endgameBalanceData: endgameBalanceData,
          teleConesData: dataTeleCones,
          autoConesData: dataAutoCones,
          teleCubesData: dataTeleCubes,
          autoCubesData: dataAutoCubes,
          autoData: AutoData(
            dataNearGate: getDataByNodeList(
              matches
                  .where(
                    (final dynamic match) =>
                        match["robot_placement"] != null &&
                        (match["robot_placement"]["title"] as String) ==
                            "Near Gate",
                  )
                  .toList(),
            ),
            middleData: getDataByNodeList(
              matches
                  .where(
                    (final dynamic match) =>
                        match["robot_placement"] != null &&
                        (match["robot_placement"]["title"] as String) ==
                            "Middle",
                  )
                  .toList(),
            ),
            nearFeederData: getDataByNodeList(
              matches
                  .where(
                    (final dynamic match) =>
                        match["robot_placement"] != null &&
                        (match["robot_placement"]["title"] as String) ==
                            "Near Feeder",
                  )
                  .toList(),
            ),
          ),
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
