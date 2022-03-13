import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/carousel_with_indicator.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/models/fetch_team_info.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/specific/scouting_specific.dart";

class CoachTeamData<E extends int> extends StatelessWidget {
  const CoachTeamData(this.team);
  final LightTeam team;
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${team.number} ${team.name}",
        ),
      ),
      body: FutureBuilder<Team<E>>(
        future: fetchTeamInfo<E>(team, context), //fetchTeam(team.id, context),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<Team<E>> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return snapshot.data.mapNullable((final Team<E> data) {
                  return CarouselWithIndicator(
                    enableInfininteScroll: true,
                    initialPage: 0,
                    widgets: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Line charts",
                          body: data.climbData.points[0].length < 2
                              ? Center(
                                  child: Text("No data :("),
                                )
                              : CoachTeamInfoLineCharts<E>(data),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Specific",
                          body: data.specificData.msg.isEmpty
                              ? Center(
                                  child: Text("No data :("),
                                )
                              : ScoutingSpecific(
                                  msg: data.specificData,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Quick data",
                          body: CoachQuickData(data.quickData),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Pit Scouting",
                          body: data.pitViewData.mapNullable(
                                CoachPitScouting.new,
                              ) ??
                              Center(child: Text("No data :(")),
                        ),
                      )
                    ],
                  );
                }) ??
                (throw Exception("No data"));
          }
        },
      ),
    );
  }
}

class CoachTeamInfoLineCharts<E extends num> extends StatelessWidget {
  CoachTeamInfoLineCharts(this.data);
  final Team<E> data;
  @override
  Widget build(final BuildContext context) => CarouselWithIndicator(
        direction: Axis.vertical,
        enableInfininteScroll: true,
        widgets: <Widget>[
          Column(
            children: <Widget>[
              FittedBox(
                fit: BoxFit.fitHeight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Text("Teleop"),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  margin: const EdgeInsets.only(left: 25, top: 8.0),
                  child: Container(
                    child: DashboardLineChart<E>(
                      showShadow: true,
                      gameNumbers: data.scoredMissedDataTele.gameNumbers,
                      distanceFromHighest: 4,
                      dataSet: data.scoredMissedDataTele.points,
                      robotMatchStatuses:
                          data.scoredMissedDataTele.robotMatchStatuses,
                      inputedColors: <Color>[
                        Colors.green,
                        Colors.red,
                        Colors.yellow[700]!
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text("Autonomous"),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  margin: const EdgeInsets.only(left: 25, top: 8.0),
                  child: DashboardLineChart<E>(
                    showShadow: true,
                    gameNumbers: data.scoredMissedDataTele.gameNumbers,
                    robotMatchStatuses:
                        data.scoredMissedDataTele.robotMatchStatuses,
                    distanceFromHighest: 4,
                    dataSet: data.scoredMissedDataAuto.points,
                    inputedColors: <Color>[
                      Colors.green,
                      Colors.red,
                      Colors.yellow[700]!
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text("Climb"),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  margin: const EdgeInsets.only(left: 25, top: 8.0),
                  child: DashboardClimbLineChart<E>(
                    showShadow: true,
                    inputedColors: <Color>[primaryColor],
                    matchNumbers: data.climbData.gameNumbers,
                    dataSet: data.climbData.points,
                    robotMatchStatuses: data.climbData.robotMatchStatuses,
                  ),
                ),
              ),
              Spacer(
                flex: 3,
              )
            ],
          )
        ],
      );
}

class CoachQuickData extends StatelessWidget {
  const CoachQuickData(this.data);
  final QuickData data;

  @override
  Widget build(final BuildContext context) => data.avgAutoLowScored.isNaN
      ? Center(child: Text("No data :("))
      : Column(
          children: <Widget>[
            Spacer(),
            Row(
              children: <Expanded>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Auto",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text(
                        "Upper: ${data.avgAutoUpperScored.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.green[300]),
                      ),
                      Text(
                        "Lower: ${data.avgAutoLowScored.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.yellow),
                      ),
                      Text(
                        "Missed: ${data.avgAutoMissed.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.red),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Points",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text("Balls: ${data.avgBallPoints.toStringAsFixed(1)}"),
                      Text("Climb: ${data.avgClimbPoints.toStringAsFixed(1)}"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Teleop",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text(
                        "Upper: ${data.avgTeleUpperScored.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.green[300]),
                      ),
                      Text(
                        "Lower: ${data.avgTeleLowScored.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.yellow),
                      ),
                      Text(
                        "Missed: ${data.avgTeleMissed.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.red),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Aim",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text(
                        "Teleop: ${!data.scorePercentTele.isNaN ? "${data.scorePercentTele.toStringAsFixed(1)}%" : "Insufficient data"} ",
                      ),
                      Text(
                        "Auto: ${!data.scorePercentAuto.isNaN ? "${data.scorePercentAuto.toStringAsFixed(1)}%" : "Insufficient data"} ",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(
              flex: 2,
            )
          ],
        );
}

class CoachPitScouting extends StatelessWidget {
  const CoachPitScouting(this.data);
  final PitData data;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        primary: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                "Robot Fault",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Row(
              children: <Widget>[
                Spacer(
                  flex: 5,
                ),
                Icon(
                  data.faultMessage != null ? Icons.warning : Icons.check,
                  color: data.faultMessage != null
                      ? Colors.yellow[700]
                      : Colors.green,
                ),
                Spacer(),
                Text(data.faultMessage ?? "No Fault"),
                Spacer(
                  flex: 5,
                )
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Drivetrain",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Text("Drivetrain: ${data.driveTrainType}"),
            Text("Drive motor: ${data.driveMotorType}"),
            Text("Drive motor amount: ${data.driveMotorAmount}"),
            Text("Drive wheel: ${data.driveWheelType}"),
            Row(
              children: <Widget>[
                Text("Has shifter:"),
                data.hasShifer.mapNullable(
                      (final bool hasShifter) => hasShifter
                          ? Icon(
                              Icons.done,
                              color: Colors.lightGreen,
                            )
                          : Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                    ) ??
                    Text(" Not answered"),
              ],
            ),
            Text(
              "Gearbox: ${data.gearboxPurchased.mapNullable((final bool p0) => p0 ? "purchased" : "custom") ?? "Not answered"}",
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Notes",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Text(
              data.notes,
              textDirection: TextDirection.rtl,
              softWrap: true,
            ),
            SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.center,
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
                              width: double.infinity,
                              imageUrl: data.url,
                              placeholder: (
                                final BuildContext context,
                                final String url,
                              ) =>
                                  CircularProgressIndicator(),
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
                    imageUrl: data.url,
                    placeholder:
                        (final BuildContext context, final String url) =>
                            CircularProgressIndicator(),
                  ),
                ),
              ),
            )
          ],
        ),
      );
}
