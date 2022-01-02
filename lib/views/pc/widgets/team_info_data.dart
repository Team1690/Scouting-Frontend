import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/scouting_pit.dart';
import 'package:scouting_frontend/views/pc/widgets/scouting_specific.dart';
import '../../constants.dart';

class QuickData {
  QuickData(this.averageInner, this.averageOuter, this.autoBalls, this.success,
      this.failed);
  final double averageInner;
  final double averageOuter;
  final double autoBalls;
  final double success;
  final double failed;
}

class SpecificData {
  SpecificData(this.msg);
  final String msg;
}

class PitViewData {
  PitViewData(
      {this.driveTrainType,
      this.driveMotorAmount,
      this.driveMotorType,
      this.driveTrainReliability,
      this.driveWheelType,
      this.electronicsReliability,
      this.gearbox,
      this.notes,
      this.robotReliability,
      this.shifter,
      this.url});
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

// ignore: must_be_immutable
class TeamInfoData extends StatefulWidget {
  TeamInfoData({
    Key key,
    @required this.team,
  }) : super(key: key);

  LightTeam team;

  @override
  State<TeamInfoData> createState() => _TeamInfoDataState();
}

class _TeamInfoDataState extends State<TeamInfoData> {
  Future<PitViewData> fetchPit() async {
    final client = getClient();
    final String query = """
query MyQuery(\$team_id: Int!) {
  pit_by_pk(team_id: \$team_id) {
    drive_motor_amount
    drive_motor_type
    drive_train_reliability
    drive_train_type
    drive_wheel_type
    electronics_reliability
    gearbox
    notes
    robot_reliability
    team_id
    shifter
    url
  }
}

    """;
    final QueryResult result = await client.query(QueryOptions(
        document: gql(query), variables: {'team_id': widget.team.id}));
    if (result.data['pit_by_pk'] == null) return null;
    if (!result.hasException) {
      return PitViewData(
          driveTrainType: result.data["pit_by_pk"]['drive_train_type'],
          driveMotorAmount: result.data["pit_by_pk"]['drive_motor_amount'],
          driveMotorType: result.data["pit_by_pk"]['drive_motor_type'],
          driveTrainReliability: result.data["pit_by_pk"]
              ['drive_train_reliability'],
          driveWheelType: result.data["pit_by_pk"]['drive_wheel_type'],
          electronicsReliability: result.data["pit_by_pk"]
              ['electronics_reliability'],
          gearbox: result.data["pit_by_pk"]['gearbox'],
          shifter: result.data['pit_by_pk']['shifter'],
          notes: result.data["pit_by_pk"]['notes'],
          robotReliability: result.data["pit_by_pk"]['robot_reliability'],
          url: result.data["pit_by_pk"]['url']);
    } else {
      throw result.exception;
    }
  }

  Future<List<SpecificData>> fetchSpesific() async {
    final client = getClient();
    final String query = """query MyQuery(\$teamNumber : Int){
  specific(where: {team: {number: {_eq: \$teamNumber}}}) {
    message
    id
  }
}""";
    final QueryResult result = await client.query(QueryOptions(
        document: gql(query),
        variables: <String, int>{"teamNumber": widget.team.number}));
    if (result.hasException) {
      print(result.exception.toString());
    } //TODO: avoid dynamic
    return (result.data['specific'] as List<dynamic>)
        .map((e) => SpecificData(
              e['message'],
            ))
        .toList();
  }

  Future<List<QuickData>> fetchQuickData() async {
    final client = getClient();
    final String query = """
  query MyQuery(\$teamNumber: Int) {
  team(where: {number: {_eq: \$teamNumber}}) {
    name
    balls: matches_aggregate {
      aggregate {
        avg {
          teleop_inner
          teleop_outer
          auto_balls
        }
      }
    }
    climbSuccess: matches_aggregate(where: {climb: {name: {_eq: "Succeeded"}}}) {
      aggregate {
        count(columns: climb_id)
      }
    }
    climbFail: matches_aggregate(where: {climb: {name: {_eq: "failed"}}}) {
      aggregate {
        count(columns: climb_id)
      }
    }
  }
}
  """;

    final QueryResult result = await client.query(QueryOptions(
        document: gql(query),
        variables: <String, int>{"teamNumber": widget.team.number}));
    if (result.hasException) {
      print(result.exception.toString());
    } //TODO: avoid dynamic
    return (result.data['team'] as List<dynamic>)
        .map((e) => QuickData(
            e['balls']['aggregate']['avg']['teleop_inner'],
            e['balls']['aggregate']['avg']['teleop_outer'],
            e['balls']['aggregate']['avg']['auto_balls'],
            e['climbSuccess']['aggregate']['count'],
            e['climbFail']['aggregate']['count']))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: DashboardCard(
                            title: 'Quick Data',
                            body: Column(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: FutureBuilder(
                                        future: fetchQuickData(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error has happened in the future! ' +
                                                    snapshot.error.toString());
                                          } else if (!snapshot.hasData) {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else {
                                            if (snapshot.data.length != 1) {
                                              return Text(
                                                  'data.length is shorter than 1! :(');
                                            }
                                            final QuickData report =
                                                snapshot.data[0];
                                            return Text(
                                                "\nAverage inner: ${report.averageInner}"
                                                        "\nAverage outer: ${report.averageOuter}"
                                                        "\nAverage auto balls: ${report.autoBalls}"
                                                        "\nClimb Rate: " +
                                                    (report.success /
                                                            (report.failed +
                                                                report
                                                                    .success) *
                                                            100)
                                                        .toString() +
                                                    "%");
                                          }
                                        })),
                              ],
                            ))),
                    SizedBox(width: defaultPadding),
                    Expanded(
                      flex: 3,
                      child: DashboardCard(
                        title: 'Pit Scouting',
                        body: FutureBuilder(
                          future: fetchPit(),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Text('No data yet :(');
                            }
                            if (snapshot.hasError) {
                              return Text('Error has happened in the future! ' +
                                  snapshot.error.toString());
                            } else if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              final PitViewData report = snapshot.data;
                              return ScoutingPit(report);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: defaultPadding),
              Expanded(
                flex: 3,
                child: DashboardCard(
                  title: 'Game Chart',
                  body: Container(),
                  // body: CarouselSlider(
                  //   options: CarouselOptions(
                  //     height: 3500,
                  //     viewportFraction: 1,
                  //     // autoPlay: true,
                  //   ),
                  //   items: widget.team.tables
                  //       .map((table) => DashboardLineChart(
                  //             colors: colors,
                  //             dataSets: [table],
                  //           ))
                  //       .toList(),
                  // ),
                ),
              )
            ],
          ),
        ),
        SizedBox(width: defaultPadding),
        DashboardCard(
            title: 'Scouting Specific',
            // body: ScoutingSpecific(msg: widget.team.msg),
            body: FutureBuilder(
                future: fetchSpesific(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error has happened in the future! ' +
                        snapshot.error.toString());
                  } else if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.data.length < 1) {
                      return Text('no data yet!');
                    }
                    final List<dynamic> report =
                        (snapshot.data as List<dynamic>)
                            .map((e) => e.msg)
                            .toList();
                    return ScoutingSpecific(msg: report.cast<String>());
                  }
                }))
      ],
    );
  }
}
