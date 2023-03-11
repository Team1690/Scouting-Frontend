import "package:collection/collection.dart";
import "package:flutter/cupertino.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/average_or_null.dart";
import "package:scouting_frontend/models/cycle_model.dart";
import "package:scouting_frontend/models/event_model.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/technical_match_model.dart";
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
      has_ground_intake
      can_score_top
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
    secondary_technicals {
      _2023_secondary_technical_events(order_by: {match_id: asc, timestamp: asc}) {
        event_type_id
        match_id
        timestamp
      }
      robot_match_status_id
      schedule_match_id
      scouter_name
      starting_position_id
      team_id
      id
    }
    technical_matches_v3(
      where: {ignored: {_eq: false}}
      order_by: [{match: {match_type: {order: asc}}}, {match: {match_number: asc}}, {is_rematch: asc}]
    ) {
      auto_cones_delivered
      auto_cones_failed
      auto_cones_scored
      auto_cubes_delivered
      auto_cubes_failed
      auto_cubes_scored
      tele_cones_delivered
      tele_cones_failed
      tele_cubes_delivered
      tele_cones_scored
      tele_cubes_failed
      tele_cubes_scored
      schedule_match_id
      scouter_name
      is_rematch
      match {
        match_type {
          title
        }
      }
      robot_match_status {
        title
      }
      auto_balance {
        title
        auto_points
      }
      endgame_balance {
        title
        endgame_points
      }
      match {
        match_number
      }
      _2023_technical_events(order_by: {match_id: asc, timestamp: asc}) {
        match_id
        timestamp
        event_type_id
      }
    }
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
    id
    name
    number
    colors_index
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
            hasGroundIntake: pitTable["has_ground_intake"] as bool,
            canScoreTop: pitTable["can_score_top"] as bool,
          ),
        );

        final dynamic avg =
            teamByPk["technical_matches_v3_aggregate"]["aggregate"]["avg"];
        double avgNullToZero(
          final MatchMode mode,
          final Gamepiece piece, [
          final ActionType? action,
        ]) =>
            avg["${mode.title}_${piece.title}_${action?.title ?? "failed"}"]
                as double? ??
            0;

        final double autoConesScored = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cone,
          ActionType.scored,
        );
        final double autoConesDelivered = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cone,
          ActionType.delivered,
        );
        final double autoConesFailed =
            avgNullToZero(MatchMode.auto, Gamepiece.cone);
        final double teleConesScored = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cone,
          ActionType.scored,
        );
        final double teleConesDelivered = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cone,
          ActionType.delivered,
        );
        final double teleConesFailed =
            avgNullToZero(MatchMode.tele, Gamepiece.cone);
        final double autoCubesScored = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cube,
          ActionType.scored,
        );
        final double autoCubesDelivered = avgNullToZero(
          MatchMode.auto,
          Gamepiece.cube,
          ActionType.delivered,
        );
        final double autoCubesFailed =
            avgNullToZero(MatchMode.auto, Gamepiece.cube);
        final double teleCubesScored =
            avgNullToZero(MatchMode.tele, Gamepiece.cube, ActionType.scored);
        final double teleCubesDelivered =
            avgNullToZero(MatchMode.tele, Gamepiece.cube, ActionType.delivered);
        final double teleCubesFailed = avgNullToZero(
          MatchMode.tele,
          Gamepiece.cube,
        );
        final List<dynamic> matches =
            (teamByPk["technical_matches_v3"] as List<dynamic>);

        List<int> balancePoints(final MatchMode mode) => matches
            .where(
              (final dynamic match) =>
                  match["robot_match_status"]["title"] as String !=
                      "Didn't come to field" &&
                  match["${mode == MatchMode.auto ? mode.title : "endgame"}_balance"]
                          ["title"] !=
                      "No Attempt",
            )
            .map(
              (final dynamic match) => match[
                      "${mode == MatchMode.auto ? mode.title : "endgame"}_balance"]
                  [
                  "${mode == MatchMode.auto ? mode.title : "endgame"}_points"] as int,
            )
            .toList();
        List<Cycle> cycles = getCycles(
            getEvents(matches, "_2023_technical_events"),
            getEvents(
              teamByPk["secondary_technicals"] as List<dynamic>,
              "_2023_secondary_technical_events",
            ),
            context);

        int matchesBalanced(final MatchMode mode) => matches
            .where(
              (final dynamic match) =>
                  match["robot_match_status"]["title"] as String !=
                      "Didn't come to field" &&
                  match["${mode == MatchMode.auto ? mode.title : "endgame"}_balance"]
                          ["title"] !=
                      "No Attempt" &&
                  match["${mode.title == MatchMode.auto.title ? mode.title : "endgame"}_balance"]
                          ["title"] !=
                      "Failed",
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
        final bool nullValidator = avg["auto_cones_scored"] == null;
        final QuickData quickData = QuickData(
          matchesBalancedAuto: matchesBalanced(MatchMode.auto),
          matchesBalancedEndgame: matchesBalanced(MatchMode.tele),
          firstPicklistIndex: team["team_by_pk"]["first_picklist_index"] as int,
          secondPicklistIndex:
              team["team_by_pk"]["second_picklist_index"] as int,
          highestBalanceTitleAuto: matches.isEmpty
              ? "highestLevelTitle QuickData: this isn't supposed to be shown because of amoutOfMatches check in ui"
              : matches
                  .where((final dynamic match) => match["auto_balance"] != null)
                  .map<dynamic>((final dynamic match) => match["auto_balance"])
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
          avgAutoGamepieces:
              nullValidator ? 0 : getPieces(parseByMode(MatchMode.auto, avg)),
          avgTeleGamepieces:
              nullValidator ? 0 : getPieces(parseByMode(MatchMode.tele, avg)),
          avgCycles: nullValidator
              ? 0
              : cycles.isEmpty
                  ? 0
                  : cycles.length / matches.length,
          avgCycleTime: nullValidator
              ? 0
              : cycles
                      .map((cycle) => cycle.getLength())
                      .toList()
                      .averageOrNull ??
                  0,
          avgFeederTime: nullValidator
              ? 0
              : getFeederTime(
                  getEvents(
                    teamByPk["secondary_technicals"] as List<dynamic>,
                    "_2023_secondary_technical_events",
                  ),
                  context),
          avgPlacementTime: nullValidator
              ? 0
              : getPlacingTime(
                  getEvents(
                    teamByPk["secondary_technicals"] as List<dynamic>,
                    "_2023_secondary_technical_events",
                  ),
                  getEvents(matches, "_2023_technical_events"),
                  context),
          avgAutoConesScored: nullValidator ? 0 : autoConesScored,
          avgAutoConesDelivered: nullValidator ? 0 : autoConesDelivered,
          avgAutoConesFailed: nullValidator ? 0 : autoConesFailed,
          avgTeleConesScored: nullValidator ? 0 : teleConesScored,
          avgTeleConesDelivered: nullValidator ? 0 : teleConesDelivered,
          avgTeleConesFailed: nullValidator ? 0 : teleConesFailed,
          avgAutoCubesScored: nullValidator ? 0 : autoCubesScored,
          avgAutoCubesDelivered: nullValidator ? 0 : autoCubesDelivered,
          avgAutoCubesFailed: nullValidator ? 0 : autoCubesFailed,
          avgTeleCubesScored: nullValidator ? 0 : teleCubesScored,
          avgTeleCubesDelivered: nullValidator ? 0 : teleCubesDelivered,
          avgTeleCubesFailed: nullValidator ? 0 : teleCubesFailed,
        );
        List<int> getBalanceLineChart(final MatchMode mode) => matches
                .map(
                  (final dynamic match) => match["robot_match_status"]["title"]
                              as String !=
                          "Didn't come to field"
                      ? match["${mode == MatchMode.auto ? mode.title : "endgame"}_balance"]
                          ["title"] as String
                      : "No Attempt",
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
                    : endgameBalanceLineChart.toList()
              ],
              title: "${isAuto ? "Auto" : "Endgame"} Balance",
              robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
                1,
                (teamByPk["technical_matches_v3"] as List<dynamic>)
                    .map(
                      (final dynamic match) => titleToEnum(
                        match["robot_match_status"]["title"] as String,
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
                          match["${mode.title}_${piece.title}_scored"] as int,
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
                3,
                (teamByPk["technical_matches_v3"] as List<dynamic>)
                    .map(
                      (final dynamic match) => titleToEnum(
                        match["robot_match_status"]["title"] as String,
                      ),
                    )
                    .toList(),
              ),
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
          final ActionType? action,
        ]) =>
            matches
                .map(
                  (final dynamic match) => match[
                          "${mode.title}_${piece.title}_${action?.title ?? "failed"}"]
                      as int,
                )
                .toList();
        LineChartData getScoredMissedData(final Gamepiece gamepiece) {
          List<int> gamepieceActionData(
            final Gamepiece piece, [
            final ActionType? level,
          ]) =>
              combineLists(
                getPiecesData(MatchMode.auto, piece, level),
                getPiecesData(MatchMode.tele, piece, level),
              );
          return LineChartData(
            gameNumbers: matchNumbers,
            points: <List<int>>[
              gamepieceActionData(gamepiece, ActionType.scored),
              gamepieceActionData(gamepiece, ActionType.delivered),
              gamepieceActionData(gamepiece),
            ],
            title: gamepiece == Gamepiece.cone ? "Cones" : "Cubes",
            robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
              3,
              (teamByPk["technical_matches_v3"] as List<dynamic>)
                  .map(
                    (final dynamic e) => titleToEnum(
                      e["robot_match_status"]["title"] as String,
                    ),
                  )
                  .toList(),
            ),
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
          ],
          title: "Gamepieces",
          robotMatchStatuses: List<List<RobotMatchStatus>>.filled(
            3,
            (teamByPk["technical_matches_v3"] as List<dynamic>)
                .map(
                  (final dynamic match) => titleToEnum(
                    match["robot_match_status"]["title"] as String,
                  ),
                )
                .toList(),
          ),
        );
        final LineChartData cyclesData = LineChartData(
          points: <List<int>>[
            matches
                .map((final dynamic match) => getCycles(
                        getEvents(matches, "_2023_technical_events")
                            .where((element) =>
                                element.matchId == match["schedule_match_id"])
                            .toList(),
                        getEvents(
                          teamByPk["secondary_technicals"] as List<dynamic>,
                          "_2023_secondary_technical_events",
                        )
                            .where((element) =>
                                element.matchId == match["schedule_match_id"])
                            .toList(),
                        context)
                    .length)
                .toList()
          ],
          title: "Cycles",
          gameNumbers: matchNumbers,
          robotMatchStatuses: <List<RobotMatchStatus>>[
            (teamByPk["technical_matches_v3"] as List<dynamic>)
                .map(
                  (final dynamic match) => titleToEnum(
                    match["robot_match_status"]["title"] as String,
                  ),
                )
                .toList()
          ],
        );
        final LineChartData cycleTimeData = LineChartData(
          points: <List<int>>[
            matches
                .map((final dynamic match) =>
                    getCycles(
                            getEvents(matches, "_2023_technical_events")
                                .where((element) =>
                                    element.matchId ==
                                    match["schedule_match_id"])
                                .toList(),
                            getEvents(
                              teamByPk["secondary_technicals"] as List<dynamic>,
                              "_2023_secondary_technical_events",
                            )
                                .where((element) =>
                                    element.matchId ==
                                    match["schedule_match_id"])
                                .toList(),
                            context)
                        .toList()
                        .map((e) => (e.endTime == double.nan ||
                                e.startingTime == double.nan
                            ? 0
                            : e.getLength() / 1000))
                        .toList()
                        .averageOrNull ??
                    0)
                .map((e) => e.isNaN ? 0 : e.round())
                .toList(),
          ],
          title: "Cycle Time",
          gameNumbers: matchNumbers,
          robotMatchStatuses: <List<RobotMatchStatus>>[
            (teamByPk["technical_matches_v3"] as List<dynamic>)
                .map(
                  (final dynamic match) => titleToEnum(
                    match["robot_match_status"]["title"] as String,
                  ),
                )
                .toList()
          ],
        );
        final LineChartData placementTimeData = LineChartData(
          points: <List<int>>[
            matches
                .map((final dynamic match) => getPlacingTime(
                    getEvents(
                      teamByPk["secondary_technicals"] as List<dynamic>,
                      "_2023_secondary_technical_events",
                    )
                        .where((element) =>
                            element.matchId == match["schedule_match_id"])
                        .toList(),
                    getEvents(matches, "_2023_technical_events")
                        .where((element) =>
                            element.matchId == match["schedule_match_id"])
                        .toList(),
                    context))
                .map((e) => e.isNaN ? 0 : (e / 1000).round())
                .toList(),
          ],
          title: "Placement Time",
          gameNumbers: matchNumbers,
          robotMatchStatuses: <List<RobotMatchStatus>>[
            (teamByPk["technical_matches_v3"] as List<dynamic>)
                .map(
                  (final dynamic match) => titleToEnum(
                    match["robot_match_status"]["title"] as String,
                  ),
                )
                .toList()
          ],
        );
        final LineChartData feederTimeData = LineChartData(
          points: <List<int>>[
            matches
                .map(
                  (final dynamic match) => (getFeederTime(
                      getEvents(
                        teamByPk["secondary_technicals"] as List<dynamic>,
                        "_2023_secondary_technical_events",
                      )
                          .where((element) =>
                              element.matchId == match["schedule_match_id"])
                          .toList(),
                      context)),
                )
                .map((e) => e.isNaN ? 0 : (e / 1000).round())
                .toList(),
          ],
          title: "Feeder Time",
          gameNumbers: matchNumbers,
          robotMatchStatuses: <List<RobotMatchStatus>>[
            (teamByPk["technical_matches_v3"] as List<dynamic>)
                .map(
                  (final dynamic match) => titleToEnum(
                    match["robot_match_status"]["title"] as String,
                  ),
                )
                .toList()
          ],
        );
        return Team(
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
          cyclesData: cyclesData,
          cycleTimeData: cycleTimeData,
          placementTimeData: placementTimeData,
          feederTimeData: feederTimeData,
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
