import "package:cached_network_image/cached_network_image.dart";
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
import "package:scouting_frontend/models/map_nullable.dart";

class TeamInfoData<E extends num> extends StatefulWidget {
  TeamInfoData(this.team);
  final LightTeam team;

  @override
  _TeamInfoDataState<E> createState() => _TeamInfoDataState<E>();
}

class _TeamInfoDataState<E extends num> extends State<TeamInfoData<E>> {
  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<Team<E>>(
      future: fetchTeamInfo<E>(widget.team),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<Team<E>> snapShot,
      ) {
        if (snapShot.hasError) {
          return Center(child: Text(snapShot.error.toString()));
        } else if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return snapShot.data.mapNullable<Widget>(
              (final Team<E> data) => Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: DashboardCard(
                                  title: "Quick",
                                  body: quickDataLeft(data.quickData),
                                ),
                              ),
                              SizedBox(
                                width: defaultPadding,
                              ),
                              Expanded(
                                child: DashboardCard(
                                  title: "Data",
                                  body: quickDataRight(data.quickData),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: defaultPadding),
                        Expanded(
                          flex: 6,
                          child: DashboardCard(
                            title: "Game Chart",
                            body: data.upperScoredMissedDataTele.points[0]
                                        .length >
                                    1
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
                  Expanded(
                    flex: 2,
                    child: DashboardCard(
                      title: "Scouting Specific",
                      body: snapShot.data!.specificData.msg.isNotEmpty
                          ? ScoutingSpecific(
                              msg: snapShot.data!.specificData.msg,
                            )
                          : Center(child: Text("No data yet :(")),
                    ),
                  ),
                  SizedBox(
                    width: defaultPadding,
                  ),
                  Expanded(
                    flex: 2,
                    child: data.pitViewData.mapNullable(
                          (final PitData p0) => Column(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: DashboardCard(
                                  title: "Robot Image",
                                  body: robotImage(
                                    context,
                                    p0.url,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: defaultPadding,
                              ),
                              Expanded(
                                flex: 3,
                                child: DashboardCard(
                                  title: "Pit Scouting",
                                  body: ScoutingPit(p0),
                                ),
                              ),
                            ],
                          ),
                        ) ??
                        DashboardCard(title: "Pit Scouting", body: Container()),
                  ),
                ],
              ),
            ) ??
            Text("No data available");
      },
    );
  }
}

Widget quickDataLeft(final QuickData data) => Row(
      children: <Widget>[
        Spacer(),
        Column(
          children: <Widget>[
            Text(
              "Auto",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "Upper: ${data.avgAutoUpperScored.toStringAsFixed(1)}",
              style: TextStyle(color: Colors.green),
            ),
            Text(
              "Lower: ${data.avgAutoLowScored.toStringAsFixed(1)}",
              style: TextStyle(color: Colors.yellow),
            ),
            Text(
              "Missed: ${data.avgAutoUpperMissed.toStringAsFixed(1)}",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        Spacer(),
        Column(
          children: <Widget>[
            Text(
              "Teleop",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "Upper: ${data.avgTeleUpperScored.toStringAsFixed(1)}",
              style: TextStyle(color: Colors.green),
            ),
            Text(
              "Lower: ${data.avgTeleLowScored.toStringAsFixed(1)}",
              style: TextStyle(color: Colors.yellow),
            ),
            Text(
              "Missed: ${data.avgTeleUpperMissed.toStringAsFixed(1)}",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        Spacer()
      ],
    );

Widget quickDataRight(final QuickData data) => Row(
      children: <Widget>[
        Spacer(),
        Column(
          children: <Widget>[
            Text(
              "Points",
              style: TextStyle(fontSize: 18),
            ),
            Text("Balls: ${data.avgBallPoints.toStringAsFixed(1)}"),
            Text("Climb: ${data.avgClimbPoints.toStringAsFixed(1)}"),
          ],
        ),
        Spacer(),
        Column(
          children: <Widget>[
            Text(
              "Upper Aim",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "Teleop: ${!data.scorePercentTeleUpper.isNaN ? "${data.scorePercentTeleUpper.toStringAsFixed(1)}%" : "Insufficient data"} ",
            ),
            Text(
              "Autonomous: ${!data.scorePercentAutoUpper.isNaN ? "${data.scorePercentAutoUpper.toStringAsFixed(1)}%" : "Insufficient data"} ",
            ),
          ],
        ),
        Spacer()
      ],
    );

Widget lineChart<E extends num>(final LineChartData<E> data) => Stack(
      children: <Widget>[
        Align(
          alignment: Alignment(0.7, -1),
          child: RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: " Upper ",
                  style: TextStyle(color: Colors.green),
                ),
                TextSpan(
                  text: " Lower ",
                  style: TextStyle(color: Colors.yellow),
                ),
                TextSpan(text: " Missed ", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment(-1, -1),
          child: Text(
            data.title,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            top: 40,
          ),
          child: DashboardLineChart<E>(
            inputedColors: <Color>[
              Colors.green,
              Colors.red,
              Colors.yellow[700]!
            ],
            distanceFromHighest: 4,
            dataSet: data.points,
          ),
        ),
      ],
    );

Widget gameChartWidgets<E extends num>(final Team<E> data) {
  return CarouselWithIndicator(
    widgets: <Widget>[
      lineChart<E>(data.upperScoredMissedDataTele),
      lineChart<E>(data.upperScoredMissedDataAuto),
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
            child: DashBoardClimbLineChart<E>(
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
          auto_upper_missed
          tele_lower
          tele_upper
          tele_upper_missed
        }
      }
    }
    matches(order_by: {match_number: asc}) {
      climb {
        title
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

class LineChartData<E extends num> {
  LineChartData({required this.points, required this.title});
  List<List<E>> points;
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
    required this.gearboxPurchased,
    required this.notes,
    required this.robotReliability,
    required this.hasShifer,
    required this.url,
  });
  final String driveTrainType;
  final int driveMotorAmount;
  final String driveWheelType;
  final bool? hasShifer;
  final bool? gearboxPurchased;
  final String driveMotorType;
  final int driveTrainReliability;
  final int electronicsReliability;
  final int robotReliability;
  final String notes;
  final String url;
}

class Team<E extends num> {
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
  final LineChartData<E> climbData;
  final LineChartData<E> upperScoredMissedDataTele;
  final LineChartData<E> upperScoredMissedDataAuto;
}

double getClimbAverage(final List<String> climbVals) {
  final List<int> climbPoints = climbVals.map<int>((final String e) {
    switch (e) {
      case "No attempt":
      case "Failed":
        return 0;
      case "Level 1":
        return 4;
      case "Level 2":
        return 6;
      case "Level 3":
        return 10;
      case "Level 4":
        return 15;
    }
    throw Exception("Not a climb value");
  }).toList();
  if (climbVals.isEmpty) {
    return 0;
  } else if (climbVals.length == 1) {
    return climbPoints[0].toDouble();
  }
  return climbPoints.reduce((final int a, final int b) => a + b).toDouble() /
      climbPoints.length;
}

Expanded robotImage(final BuildContext context, final String url) => Expanded(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push<Scaffold>(
          PageRouteBuilder<Scaffold>(
            reverseTransitionDuration: Duration(milliseconds: 700),
            transitionDuration: Duration(milliseconds: 700),
            pageBuilder: (
              final BuildContext context,
              final Animation<double> a,
              final Animation<double> b,
            ) =>
                GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Scaffold(
                body: Center(
                  child: Hero(
                    tag: "Robot Image",
                    child: CachedNetworkImage(
                      imageUrl: url,
                      placeholder: (
                        final BuildContext context,
                        final String url,
                      ) =>
                          Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: Hero(
          tag: "Robot Image",
          child: CachedNetworkImage(
            width: 240,
            imageUrl: url,
            placeholder: (final BuildContext context, final String url) =>
                Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );

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
              .map((final dynamic e) => e["climb"]["title"] as String)
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

          final List<int> climbPoints = climbVals.map<int>((final String e) {
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

          final LineChartData<E> climbData = LineChartData<E>(
            points: <List<E>>[climbPoints.cast<E>()],
            title: "Climb",
          );

          final List<E> upperScoredDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_upper"] as int)
                  .cast<E>()
                  .toList();
          final List<E> upperMissedDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_upper_missed"] as int)
                  .cast<E>()
                  .toList();

          final List<E> lowerScoredDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_lower"] as int)
                  .cast<E>()
                  .toList();

          final LineChartData<E> upperScoredMissedDataTele = LineChartData<E>(
            points: <List<E>>[
              upperScoredDataTele,
              upperMissedDataTele,
              lowerScoredDataTele
            ],
            title: "Teleoperated",
          );

          final List<E> upperScoredDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_upper"] as int)
                  .toList()
                  .cast<E>();
          final List<E> upperMissedDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_upper_missed"] as int)
                  .cast<E>()
                  .toList();
          final List<E> lowerScoredDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_lower"] as int)
                  .cast<E>()
                  .toList();
          final LineChartData<E> upperScoredMissedDataAuto = LineChartData<E>(
            points: <List<E>>[
              upperScoredDataAuto,
              upperMissedDataAuto,
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
            upperScoredMissedDataTele: upperScoredMissedDataTele,
            upperScoredMissedDataAuto: upperScoredMissedDataAuto,
          );
        }) ??
        (throw Exception("No team with that id")),
  );
}
