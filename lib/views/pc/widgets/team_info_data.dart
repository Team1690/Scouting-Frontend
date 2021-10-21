import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/radar_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/scouting_specific.dart';

import '../../constants.dart';

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
  }
  climb: match_aggregate(where: {climb: {name: {_eq: "succeed"}, _and: {matches: {number: {_eq: \$teamNumber}}}}}) {
    aggregate {
      count(columns: climb_id)
    }
  }
  failed: match_aggregate(where: {climb: {name: {_eq: "failed"}, _and: {matches: {number: {_eq: \$teamNumber}}}}}) {
    aggregate {
      count(columns: climb_id)
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
    //  print(result.data['team'][0]['matches_aggregate']['aggregate']['avg']);
    return (result.data['team'] as List<dynamic>)
        .map((e) => QuickData(
            e['balls']['aggregate']['avg']['teleop_inner'],
            e['balls']['aggregate']['avg']['teleop_outer'],
            e['balls']['aggregate']['avg']['auto_balls'],
            result.data['success']))
        .toList();
    //.entries.map((e) => LightTeam(e['id']);
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
                                            inspect(snapshot.data);
                                            if (snapshot.data.length != 1) {
                                              return Text('invalid data :(');
                                            }
                                            return Text("Average inner: " +
                                                snapshot.data[0].averageInner
                                                    .toString() +
                                                "\nAverage outer: " +
                                                snapshot.data[0].averageOuter
                                                    .toString() +
                                                "\nAverage autoBalls: " +
                                                snapshot.data[0].autoBalls
                                                    .toString() +
                                                "\nAverage autoBalls: " +
                                                snapshot.data[0].climbRate);
                                          }
                                        })),
                                //TODO: need to add more of that...
                              ],
                            ))),
                    SizedBox(width: defaultPadding),
                    Expanded(
                      flex: 3,
                      child: DashboardCard(
                        title: 'Pit Scouting',
                        body: Container(),
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
        Expanded(
            flex: 2,
            child: DashboardCard(
              title: 'Scouting Specific',
              // body: ScoutingSpecific(msg: widget.team.msg),
              body: ScoutingSpecific(msg: []),
            ))
      ],
    );
  }
}
