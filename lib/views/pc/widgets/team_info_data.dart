import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
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

// ignore: must_be_immutable
class TeamInfoData extends StatefulWidget {
  TeamInfoData({
    Key key,
    @required this.team,
  }) : super(key: key);

  int team;

  @override
  State<TeamInfoData> createState() => _TeamInfoDataState();
}

class _TeamInfoDataState extends State<TeamInfoData> {
  Future<List<SpecificData>> fetchSpesific() async {
    final client = getClient();
    final String query = """query MyQuery(\$teamNumber : Int){
  specific(where: {team: {number: {_eq: \$teamNumber}}}) {
    match_id
    message
    id
  }
}""";
    final QueryResult result = await client.query(QueryOptions(
        document: gql(query),
        variables: <String, int>{"teamNumber": widget.team}));
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
        variables: <String, int>{"teamNumber": widget.team}));
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
                        body: Container(
                          child: Center(
                            child: Text('TBD'),
                          ),
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
                      return Text(' data.length is \nshorter than 1! :(');
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
