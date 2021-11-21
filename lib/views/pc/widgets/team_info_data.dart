import 'dart:developer';
import 'dart:convert' as convert;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/radar_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/scouting_specific.dart';
import 'package:scouting_frontend/views/pc/widgets/carousel_with_indicator.dart';

import '../../constants.dart';

class TeamInfoData extends StatefulWidget {
  const TeamInfoData({
    Key key,
    @required this.team,
  }) : super(key: key);

  final int team;

  @override
  State<TeamInfoData> createState() => _TeamInfoDataState();
}

class LineChartData {
  LineChartData({this.points});
  List<double> points;
}

class _TeamInfoDataState extends State<TeamInfoData> {
  Future<List<LineChartData>> fetchGameChart() async {
    final client = getClient();
    final String query = """
query fetchGameChart(\$teamNumber : Int) {
  team(where: {number: {_eq: \$teamNumber}}) {
    matches(order_by: {number: asc}) {
      teleop_inner
      teleop_outer
      auto_balls
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

    // print(convert.jsonDecode(result.data['team'][0]['matches']));
    return [
      LineChartData(
        points: (result.data['team'][0]['matches'] as List<dynamic>)
            .map((e) => e['teleop_inner'])
            .toList()
            .cast<double>(),
      ),
      LineChartData(
        points: (result.data['team'][0]['matches'] as List<dynamic>)
            .map((e) => e['teleop_outer'])
            .toList()
            .cast<double>(),
      ),
      LineChartData(
        points: (result.data['team'][0]['matches'] as List<dynamic>)
            .map((e) => e['auto_balls'])
            .toList()
            .cast<double>(),
      ),
    ];
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
                                Text("average shots: "
                                    // widget.team.averageShots.toString(),
                                    ),
                                Text("total shots sd: "
                                    // widget.team.totalShotsSD.toString()
                                    ),
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
                    body: FutureBuilder(
                        future: fetchGameChart(),
                        builder: (context,
                            AsyncSnapshot<List<LineChartData>> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error has happened in the future! ' +
                                snapshot.error.toString());
                          } else if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            inspect(snapshot.data);
                            return CarouselWithIndicator(
                              widgets: snapshot.data
                                  .map((LineChartData e) =>
                                      DashboardLineChart(dataSet: e.points))
                                  .toList(),
                            );
                          }
                        })),
              )
            ],
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
            flex: 2,
            child: DashboardCard(
              title: 'Scouting Specific',
              body: ScoutingSpecific(msg: []),
            ))
      ],
    );
  }
}
