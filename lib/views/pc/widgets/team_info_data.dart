import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/widgets/card.dart";
import "package:scouting_frontend/views/pc/widgets/carousel_with_indicator.dart";
import "package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart";
import "package:scouting_frontend/views/pc/widgets/scouting_pit.dart";
import "package:scouting_frontend/views/pc/widgets/scouting_specific.dart";

class TeamInfoData extends StatefulWidget {
  TeamInfoData(this.team);
  LightTeam team;

  @override
  _TeamInfoDataState createState() => _TeamInfoDataState();
}

class _TeamInfoDataState extends State<TeamInfoData> {
  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<Team>(
      future: fetchTeamInfo(widget.team),
      builder:
          (final BuildContext context, final AsyncSnapshot<Team> snapShot) {
        if (snapShot.hasError) {
          return Center(child: Text(snapShot.error.toString()));
        } else if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return snapShot.data.mapNullable<Widget>(
              (final Team data) => Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: DashboardCard(
                                  title: "Quick Data",
                                  body: quickData(data.quickData),
                                ),
                              ),
                              SizedBox(width: defaultPadding),
                              Expanded(
                                flex: 3,
                                child: DashboardCard(
                                  title: "Pit Scouting",
                                  body: data.pitViewData
                                          .mapNullable(ScoutingPit.new) ??
                                      Text("No data yet :("),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: defaultPadding),
                        Expanded(
                          flex: 5,
                          child: DashboardCard(
                            title: "Game Chart",
                            body: data.upperScoredMissedDataTele.points[0]
                                    .isNotEmpty
                                ? gameChartWidgets(data)
                                : Center(
                                    child: Text(
                                      "No data yet :(",
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: defaultPadding),
                  DashboardCard(
                    title: "Scouting Specific",
                    body: snapShot.data!.specificData.msg.isNotEmpty
                        ? ScoutingSpecific(
                            msg: snapShot.data!.specificData.msg,
                          )
                        : Text("No data yet :("),
                  )
                ],
              ),
            ) ??
            Text("No data available");
      },
    );
  }
}

Widget quickData(final QuickData data) => SingleChildScrollView(
      child: Text(
        """
Average auto upper scored: ${data.avgAutoUpperScored.toStringAsFixed(3)}
Average auto upper missed: ${data.avgAutoUpperMissed.toStringAsFixed(3)}
Average auto low scored: ${data.avgAutoLowScored.toStringAsFixed(3)}

Average tele upper scored: ${data.avgTeleUpperScored.toStringAsFixed(3)}
Average tele upper missed: ${data.avgAutoUpperMissed.toStringAsFixed(3)}
Average tele low scored: ${data.avgTeleLowScored.toStringAsFixed(3)}

Average points from balls: ${data.avgBallPoints.toStringAsFixed(3)}
Average points from climb: ${data.avgClimbPoints.toStringAsFixed(3)}

Upper Shooting teleop success rate: ${!data.scorePercentTeleUpper.isNaN ? data.scorePercentTeleUpper.round() : "Not a number"}%
Upper Shooting auto success rate: ${!data.scorePercentAutoUpper.isNaN ? data.scorePercentAutoUpper.round() : "Not a number"}%
""",
      ),
    );

Widget gameChartWidgets(final Team data) {
  return CarouselWithIndicator(
    widgets: <Widget>[
      Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(-1, -1),
            child: Text(
              data.upperScoredMissedDataTele.title,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              top: 40,
            ),
            child: DashboardLineChart(
              inputedColors: <Color>[Colors.green, Colors.red],
              distanceFromHighest: 4,
              dataSet: data.upperScoredMissedDataTele.points,
            ),
          ),
        ],
      ),
      Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(-1, -1),
            child: Text(
              data.upperScoredMissedDataAuto.title,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              top: 40,
            ),
            child: DashboardLineChart(
              inputedColors: <Color>[Colors.green, Colors.red],
              distanceFromHighest: 4,
              dataSet: data.upperScoredMissedDataAuto.points,
            ),
          ),
        ],
      ),
      Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(-1, -1),
            child: Text(data.climbData.title),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 40.0,
              left: 40.0,
              right: 20.0,
              top: 40,
            ),
            child: DashBoardClimbLineChart(
              dataSet: data.climbData.points,
            ),
          ),
        ],
      )
    ],
  );
}

const String teamInfoQuery = """
query MyQuery(\$id: Int!) {
  team_by_pk(id: \$id) {
    pit {
      drive_motor_amount
      drive_train_reliability
      drive_wheel_type
      electronics_reliability
      gearbox
      notes
      robot_reliability
      shifter
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
          auto_upper_missed
          tele_lower
          tele_upper
          tele_upper_missed
        }
      }
    }
    matches(order_by: {match_number: asc}) {
      climb {
        name
      }
      auto_lower
      auto_upper
      auto_upper_missed
      match_number
      tele_lower
      tele_upper
      tele_upper_missed
    }
  }
}

""";

class QuickData {
  QuickData({
    required this.avgAutoLowScored,
    required this.avgAutoUpperMissed,
    required this.avgAutoUpperScored,
    required this.avgBallPoints,
    required this.avgClimbPoints,
    required this.avgTeleLowScored,
    required this.avgTeleUpperMissed,
    required this.avgTeleUpperScored,
    required this.scorePercentAutoUpper,
    required this.scorePercentTeleUpper,
  });
  final double avgBallPoints;
  final double avgClimbPoints;
  final double avgAutoUpperScored;
  final double avgAutoUpperMissed;
  final double avgAutoLowScored;
  final double scorePercentAutoUpper;
  final double avgTeleUpperScored;
  final double avgTeleUpperMissed;
  final double avgTeleLowScored;
  final double scorePercentTeleUpper;
}

class SpecificData {
  SpecificData(this.msg);
  final List<String> msg;
}

class LineChartData {
  LineChartData({required this.points, required this.title});
  List<List<double>> points;
  String title = "";
}

class PitData {
  PitData({
    required this.driveTrainType,
    required this.driveMotorAmount,
    required this.driveMotorType,
    required this.driveTrainReliability,
    required this.driveWheelType,
    required this.electronicsReliability,
    required this.gearbox,
    required this.notes,
    required this.robotReliability,
    required this.shifter,
    required this.url,
  });
  final String driveTrainType;
  final int driveMotorAmount;
  final String driveWheelType;
  final String shifter;
  final String gearbox;
  final String driveMotorType;
  final int driveTrainReliability;
  final int electronicsReliability;
  final int robotReliability;
  final String notes;
  final String url;
}

class Team {
  Team({
    required this.team,
    required this.specificData,
    required this.pitViewData,
    required this.quickData,
    required this.climbData,
    required this.upperScoredMissedDataTele,
    required this.upperScoredMissedDataAuto,
  });
  final LightTeam team;
  final SpecificData specificData;
  final PitData? pitViewData;
  final QuickData quickData;
  final LineChartData climbData;
  final LineChartData upperScoredMissedDataTele;
  final LineChartData upperScoredMissedDataAuto;
}

double getClimbAverage(final List<String> climbVals) {
  final List<int> climbPoints = climbVals.map<int>((final String e) {
    switch (e) {
      case "no attempt":
      case "failed":
        return 0;
      case "level 1":
        return 4;
      case "level 2":
        return 6;
      case "level 3":
        return 10;
      case "level 4":
        return 15;
    }
    throw Exception("Not a climb value");
  }).toList();
  if (climbVals.isEmpty) {
    return 0;
  } else if (climbVals.length == 1) {
    climbPoints[0];
  }
  return climbPoints.reduce((final int a, final int b) => a + b).toDouble() /
      climbPoints.length;
}

Future<Team> fetchTeamInfo(final LightTeam teamForQuery) async {
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
              gearbox: p0["gearbox"] as String,
              notes: p0["notes"] as String,
              robotReliability: p0["robot_reliability"] as int,
              shifter: p0["shifter"] as String,
              url: p0["url"] as String,
              driveTrainType: p0["drivetrain"]["title"] as String,
              driveMotorType: p0["drivemotor"]["title"] as String,
            ),
          );

          final double avgAutoLow = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["auto_lower"] as double? ??
              0;
          final double avgAutoUpperMissed = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["auto_upper_missed"] as double? ??
              0;
          final double avgAutoUpperScored = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["auto_upper"] as double? ??
              0;
          final double avgTeleLow = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["tele_lower"] as double? ??
              0;
          final double avgTeleUpperMissed = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["tele_upper_missed"] as double? ??
              0;
          final double avgTeleUpperScored = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["tele_upper"] as double? ??
              0;

          final List<String> climbVals = (teamByPk["matches"] as List<dynamic>)
              .map((final dynamic e) => e["climb"]["name"] as String)
              .toList();

          final QuickData quickData = QuickData(
            avgAutoLowScored: avgAutoLow,
            avgAutoUpperMissed: avgAutoUpperMissed,
            avgAutoUpperScored: avgAutoUpperScored,
            avgBallPoints: avgTeleUpperScored * 2 +
                avgTeleLow +
                avgAutoUpperScored * 4 +
                avgAutoLow * 2,
            avgClimbPoints: getClimbAverage(climbVals),
            avgTeleLowScored: avgTeleLow,
            avgTeleUpperMissed: avgTeleUpperMissed,
            avgTeleUpperScored: avgTeleUpperScored,
            scorePercentAutoUpper: (avgAutoUpperScored /
                    (avgAutoUpperScored + avgAutoUpperMissed)) *
                100,
            scorePercentTeleUpper: (avgTeleUpperScored /
                    (avgTeleUpperScored + avgTeleUpperMissed)) *
                100,
          );

          final List<double> climbPoints =
              climbVals.map<double>((final String e) {
            switch (e) {
              case "failed":
                return 0;
              case "no attempt":
                return -1;
              case "level 1":
                return 1;
              case "level 2":
                return 2;
              case "level 3":
                return 3;
              case "level 4":
                return 4;
            }
            throw Exception("Not a climb value");
          }).toList();

          final LineChartData climbData = LineChartData(
            points: <List<double>>[climbPoints],
            title: "Climb",
          );

          final List<double> upperScoredDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_upper"] as double)
                  .toList();
          final List<double> upperMissedDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_upper_missed"] as double)
                  .toList();

          final LineChartData upperScoredMissedDataTele = LineChartData(
            points: <List<double>>[
              upperScoredDataTele,
              upperMissedDataTele,
            ],
            title: "Upper balls Teleop",
          );

          final List<double> upperScoredDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_upper"] as double)
                  .toList();
          final List<double> upperMissedDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_upper_missed"] as double)
                  .toList();
          final LineChartData upperScoredMissedDataAuto = LineChartData(
            points: <List<double>>[
              upperScoredDataAuto,
              upperMissedDataAuto,
            ],
            title: "Upper balls Auto",
          );
          return Team(
            team: teamForQuery,
            specificData: specificData,
            pitViewData: pitData,
            quickData: quickData,
            climbData: climbData,
            upperScoredMissedDataTele: upperScoredMissedDataTele,
            upperScoredMissedDataAuto: upperScoredMissedDataAuto,
          );
        }) ??
        (throw Exception("No team with that id")),
  );
}
