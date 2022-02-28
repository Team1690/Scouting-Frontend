import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/carousel_with_indicator.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/mobile/slider.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/specific/scouting_specific.dart";

class CoachTeamData extends StatelessWidget {
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
      body: FutureBuilder<CoachViewTeam>(
        future: fetchTeam(team.id, context),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<CoachViewTeam> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return snapshot.data.mapNullable((final CoachViewTeam data) {
                  return CarouselWithIndicator(
                    enableInfininteScroll: true,
                    initialPage: 1,
                    widgets: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Line charts",
                          body: data.climbData.points[0].length < 2
                              ? Center(
                                  child: Text("No data :("),
                                )
                              : lineCharts(data),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Pit Scouting",
                          body: data.pitData.mapNullable(
                                (final PitData pit) =>
                                    pitScouting(pit, context),
                              ) ??
                              Center(child: Text("No data :(")),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Quick data",
                          body: quickData(data.quickData),
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

Widget lineCharts(final CoachViewTeam data) => CarouselWithIndicator(
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
                  child: DashboardLineChart<int>(
                    gameNumbers: data.scoredMissedDataTele.gameNumbers,
                    distanceFromHighest: 4,
                    dataSet: data.scoredMissedDataTele.points,
                    inputedColors: <Color>[
                      Colors.green,
                      Colors.red,
                      Colors.yellow[700]!
                    ],
                  ),
                ),
              ),
            ),
            Spacer(
              flex: 3,
            )
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
                child: DashboardLineChart<int>(
                  gameNumbers: data.scoredMissedDataAuto.gameNumbers,
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
            Spacer(
              flex: 3,
            )
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
                child: DashboardClimbLineChart<int>(
                  inputedColors: <Color>[primaryColor],
                  matchNumbers: data.climbData.gameNumbers,
                  dataSet: data.climbData.points,
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

Widget quickData(final QuickData data) => data.avgAutoLowScored.isNaN
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

const String query = """

query MyQuery(\$id: Int!) {
  team_by_pk(id: \$id) {
    id
    name
    number
    colors_index
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
      robot_role{
        title
        id
      }
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
  broken_robots {
    team {
      colors_index
      id
      name
      number
    }
    message
  }
}



""";

class CoachViewTeam {
  const CoachViewTeam({
    required this.team,
    required this.specificData,
    required this.pitData,
    required this.quickData,
    required this.climbData,
    required this.scoredMissedDataAuto,
    required this.scoredMissedDataTele,
  });
  final LightTeam team;
  final LineChartData<int> scoredMissedDataTele;
  final LineChartData<int> scoredMissedDataAuto;
  final LineChartData<int> climbData;
  final SpecificData specificData;
  final QuickData quickData;
  final PitData? pitData;
}

Future<CoachViewTeam> fetchTeam(
  final int id,
  final BuildContext context,
) async {
  final GraphQLClient client = getClient();
  final QueryResult result = await client.query(
    QueryOptions(document: gql(query), variables: <String, dynamic>{"id": id}),
  );

  return result.mapQueryResult(
    (final Map<String, dynamic>? p0) =>
        p0.mapNullable((final Map<String, dynamic> team) {
          final Map<String, dynamic> teamByPk = team["team_by_pk"] != null
              ? team["team_by_pk"] as Map<String, dynamic>
              : throw Exception("that team doesnt exist");
          final Map<String, dynamic>? pit =
              (teamByPk["pit"] as Map<String, dynamic>?);
          final List<int> roleIds = (teamByPk["specifics"] as List<dynamic>)
              .map<int?>(
                (final dynamic e) => e["robot_role"]?["id"] as int?,
              )
              .where((final int? element) => element != null)
              .cast<int>()
              .toList();

          final Map<int, int> roleToAmount = <int, int>{};
          for (final int element in roleIds) {
            roleToAmount[element] = (roleToAmount[element] ?? 0) + 1;
          }
          final List<MapEntry<int, int>> roles = roleToAmount.entries.toList()
            ..sort(
              (final MapEntry<int, int> a, final MapEntry<int, int> b) =>
                  b.value.compareTo(a.value),
            );
          final String mostPopularRoleName = roles.isEmpty
              ? "No data"
              : roles.length == 1
                  ? IdProvider.of(context).robotRole.idToName[roles.first.key]!
                  : roles.length == 2
                      ? "${IdProvider.of(context).robotRole.idToName[roles.first.key]}-${IdProvider.of(context).robotRole.idToName[roles.elementAt(1).key]}"
                      : "Misc";
          final SpecificData specificData = SpecificData(
            (teamByPk["specifics"] as List<dynamic>)
                .map(
                  (final dynamic e) => SpecificMatch(
                    e["message"] as String,
                    e["robot_role"]?["title"] as String?,
                  ),
                )
                .toList(),
            mostPopularRoleName,
          );
          final Map<int, String> teamIdToFaultMessage = <int, String>{
            for (final dynamic e in (team["broken_robots"] as List<dynamic>))
              e["team"]["id"] as int: e["message"] as String
          };
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
              faultMessage: teamIdToFaultMessage[teamByPk["id"] as int],
            ),
          );
          final double avgAutoLow = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["auto_lower"] as double? ??
              double.nan;
          final double avgAutoMissed = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["auto_missed"] as double? ??
              double.nan;
          final double avgAutoUpperScored = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["auto_upper"] as double? ??
              double.nan;
          final double avgTeleLow = teamByPk["matches_aggregate"]["aggregate"]
                  ["avg"]["tele_lower"] as double? ??
              double.nan;
          final double avgTeleMissed = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["tele_missed"] as double? ??
              double.nan;
          final double avgTeleUpperScored = teamByPk["matches_aggregate"]
                  ["aggregate"]["avg"]["tele_upper"] as double? ??
              double.nan;

          final List<int> climbVals = (teamByPk["matches"] as List<dynamic>)
              .map((final dynamic e) => e["climb"]["points"] as int)
              .toList();
          final int climbSum = climbVals.isEmpty
              ? 0
              : climbVals.length == 1
                  ? climbVals.first
                  : climbVals.reduce(
                      (final int value, final int element) => value + element,
                    );
          final QuickData quickData = QuickData(
            avgAutoLowScored: avgAutoLow,
            avgAutoMissed: avgAutoMissed,
            avgAutoUpperScored: avgAutoUpperScored,
            avgBallPoints: avgTeleUpperScored * 2 +
                avgTeleLow +
                avgAutoUpperScored * 4 +
                avgAutoLow * 2,
            avgClimbPoints: climbSum / climbVals.length,
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
          final List<String> climbTitles =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["climb"]["title"] as String)
                  .toList();

          final List<int> climbPoints = climbTitles.map<int>((final String e) {
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
          final LineChartData<int> climbData = LineChartData<int>(
            gameNumbers: matchNumbers,
            points: <List<int>>[climbPoints],
            title: "Climb",
          );

          final List<int> upperScoredDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_upper"] as int)
                  .toList();
          final List<int> missedDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_missed"] as int)
                  .toList();

          final List<int> lowerScoredDataTele =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["tele_lower"] as int)
                  .toList();

          final LineChartData<int> scoredMissedDataTele = LineChartData<int>(
            gameNumbers: matchNumbers,
            points: <List<int>>[
              upperScoredDataTele,
              missedDataTele,
              lowerScoredDataTele
            ],
            title: "Teleoperated",
          );

          final List<int> upperScoredDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_upper"] as int)
                  .toList();
          final List<int> missedDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_missed"] as int)
                  .toList();
          final List<int> lowerScoredDataAuto =
              (teamByPk["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["auto_lower"] as int)
                  .toList();
          final LineChartData<int> scoredMissedDataAuto = LineChartData<int>(
            gameNumbers: matchNumbers,
            points: <List<int>>[
              upperScoredDataAuto,
              missedDataAuto,
              lowerScoredDataAuto
            ],
            title: "Autonomous",
          );
          return CoachViewTeam(
            team: LightTeam(
              teamByPk["id"] as int,
              teamByPk["number"] as int,
              teamByPk["name"] as String,
              teamByPk["colors_index"] as int,
            ),
            specificData: specificData,
            pitData: pitData,
            quickData: quickData,
            climbData: climbData,
            scoredMissedDataAuto: scoredMissedDataAuto,
            scoredMissedDataTele: scoredMissedDataTele,
          );
        }) ??
        (throw Exception("No data")),
  );
}

Widget pitScouting(final PitData data, final BuildContext context) =>
    SingleChildScrollView(
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
                data.faultMessage == null ? Icons.warning : Icons.check,
                color: data.faultMessage == null
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
              "Reliability",
              style: TextStyle(fontSize: 18),
            ),
          ),
          PitViewSlider(
            label: "Drivetrain",
            divisions: 4,
            max: 5,
            min: 1,
            onChange: identity,
            value: data.driveTrainReliability.toDouble(),
          ),
          PitViewSlider(
            label: "Electronics",
            divisions: 4,
            max: 5,
            min: 1,
            onChange: identity,
            value: data.electronicsReliability.toDouble(),
          ),
          PitViewSlider(
            label: "Robot",
            divisions: 9,
            max: 10,
            min: 1,
            onChange: identity,
            value: data.driveTrainReliability.toDouble(),
          ),
          Align(
            alignment: Alignment.center,
            child: Text("Notes"),
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
                  placeholder: (final BuildContext context, final String url) =>
                      CircularProgressIndicator(),
                ),
              ),
            ),
          )
        ],
      ),
    );
