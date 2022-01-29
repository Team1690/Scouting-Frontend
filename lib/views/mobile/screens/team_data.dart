import "package:cached_network_image/cached_network_image.dart";
import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/widgets/card.dart";
import "package:scouting_frontend/views/pc/widgets/scouting_specific.dart";
import "package:scouting_frontend/views/pc/widgets/team_info_data.dart";

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
        future: fetchTeam(team.id),
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
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: 3500,
                      aspectRatio: 2.0,
                      viewportFraction: 1,
                    ),
                    items: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Pit Scouting",
                          body: data.pitData.mapNullable(
                                (final PitData pit) =>
                                    pitScouting(pit, context),
                              ) ??
                              Text("No data"),
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
                          body: ScoutingSpecific(
                            phone: true,
                            msg: data.specificData.msg,
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

Widget quickData(final QuickData data) => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              "Auto",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Column(
            children: <Widget>[
              Text(
                "Upper: ${data.avgAutoUpperScored.toStringAsFixed(3)}",
                style: TextStyle(color: Colors.green[300]),
              ),
              Text(
                "Lower: ${data.avgAutoLowScored.toStringAsFixed(3)}",
                style: TextStyle(color: Colors.yellow),
              ),
              Text(
                "Missed: ${data.avgAutoUpperMissed.toStringAsFixed(3)}",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Teleop",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Column(
            children: <Widget>[
              Text(
                "Upper: ${data.avgTeleUpperScored.toStringAsFixed(3)}",
                style: TextStyle(color: Colors.green[300]),
              ),
              Text(
                "Lower: ${data.avgTeleLowScored.toStringAsFixed(3)}",
                style: TextStyle(color: Colors.yellow),
              ),
              Text(
                "Missed: ${data.avgTeleUpperMissed.toStringAsFixed(3)}",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Points",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Column(
            children: <Widget>[
              Text("Balls: ${data.avgBallPoints.toStringAsFixed(3)}"),
              Text("Climb: ${data.avgClimbPoints.toStringAsFixed(3)}"),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Upper Aim",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Column(
            children: <Widget>[
              Text(
                "Teleop: ${!data.scorePercentTeleUpper.isNaN ? "${data.scorePercentTeleUpper.toStringAsFixed(3)}%" : "Insufficient data"} ",
              ),
              Text(
                "Autonomous: ${!data.scorePercentAutoUpper.isNaN ? "${data.scorePercentAutoUpper.toStringAsFixed(3)}%" : "Insufficient data"} ",
              ),
            ],
          ),
        ],
      ),
    );

const String query = """

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
      nodes{
        climb{
          points
        }
      }
    }

  }
}



""";

class CoachViewTeam {
  const CoachViewTeam({
    required this.specificData,
    required this.pitData,
    required this.quickData,
  });
  final SpecificData specificData;
  final QuickData quickData;
  final PitData? pitData;
}

Future<CoachViewTeam> fetchTeam(final int id) async {
  final GraphQLClient client = getClient();
  final QueryResult result = await client.query(
    QueryOptions(document: gql(query), variables: <String, dynamic>{"id": id}),
  );

  return result.mapQueryResult(
    (final Map<String, dynamic>? p0) =>
        p0.mapNullable((final Map<String, dynamic> team) {
          print(team);
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

          final List<int> climbVals =
              (teamByPk["matches_aggregate"]["nodes"] as List<dynamic>)
                  .map((final dynamic e) => e["climb"]["points"] as int)
                  .toList();
          final int climbSum = climbVals.length == 1
              ? climbVals.first
              : climbVals.reduce(
                  (final int value, final int element) => value + element,
                );

          final QuickData quickData = QuickData(
            avgAutoLowScored: avgAutoLow,
            avgAutoUpperMissed: avgAutoUpperMissed,
            avgAutoUpperScored: avgAutoUpperScored,
            avgBallPoints: avgTeleUpperScored * 2 +
                avgTeleLow +
                avgAutoUpperScored * 4 +
                avgAutoLow * 2,
            avgClimbPoints: climbSum / climbVals.length,
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
          return CoachViewTeam(
            specificData: specificData,
            pitData: pitData,
            quickData: quickData,
          );
        }) ??
        (throw Exception("No data")),
  );
}

Widget pitScouting(final PitData data, final BuildContext context) =>
    SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
          Text("Drivetrain: ${data.driveTrainReliability}"),
          Text("Electronics: ${data.electronicsReliability}"),
          Text("Robot: ${data.robotReliability}"),
          Align(
            alignment: Alignment.center,
            child: Text("Notes"),
          ),
          Text(
            data.notes,
            softWrap: true,
          ),
          SizedBox(
            height: 30,
          ),
          FittedBox(
            fit: BoxFit.fitWidth,
            child: Align(
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
                              imageUrl: data.url,
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
                    imageUrl: data.url,
                    placeholder:
                        (final BuildContext context, final String url) =>
                            Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
