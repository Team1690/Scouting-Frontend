import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/pc/widgets/team_info_data.dart';


class ScatterQuickData {
  ScatterQuickData(this.games, this.avgInner, this.avgOuter, this.stddevInner,
      this.stddevOuter, this.teams) {}
      final  double avgInner;
      final  double avgOuter;
      final  double stddevInner;
      final  double stddevOuter;
      final  double games;
      final  double teams;
}

class ScatterData extends StatefulWidget {
  ScatterData({
    Key key,
    @required this.team,
  }) : super(key: key);

  int team;

  @override
  State<ScatterData> createState() => _ScatterDataState();
}

class Scatter extends StatelessWidget {
  const Scatter({
    @required this.teams,
    @required this.onHover,
    Key key,
  }) : super(key: key);
    final List<Team> teams;

    final Function(Team team) onHover;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }}


 class _ScatterDataState extends State<ScatterData> {
  Future<List<ScatterQuickData>> fetchScatterQuickData() async {
    final client = getClient();
    final String query = """query MyQuery {
  match_aggregate {
    aggregate {
      avg {
        teleop_inner
        teleop_outer
      }
      stddev {
        teleop_inner
        teleop_outer
      }
    }
  }
  match {
    team {
      matches {
        number
      }
    number
    }
  }
  team {
    number
}
}""";

 final QueryResult result = await client.query(QueryOptions(
        document: gql(query),
        variables: <String, int>{}));
    if (result.hasException) {
      print(result.exception.toString());
    } //TODO: avoid dynamic
    return (result.data['team'] as List<dynamic>)
        .map((e) => ScatterQuickData(
            e['match_aggregate']['aggregate']['avg']['teleop_inner'],
            e['match_aggregate']['aggregate']['avg']['teleop_outer'],
            e['match_aggregate']['aggregate']['stddev']['teleop_inner'],
            e['match_aggregate']['aggregate']['stddev']['teleop_outer'],
            e['match']['team']['matches']['number']['number'],
            e['team']['number']))
        .toList();
  }





  
  @override
  Widget build(BuildContext context) {
    Team selectedTeam;
    String tooltip;
    return Container(
      color: Colors.grey,
      child : Column ( 
      children : [
        Expanded( 
              flex: 1,
              child: FutureBuilder(
                    future: fetchScatterQuickData(),
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
                          return Text('invalid data :(');
                        }
                      
                      final QuickData report =
                        snapshot.data[0];
                      double averageShots = report.avgInner+ report.avgOuter;
                      double stddev = (report.stddevInner * report.games + report.teleopOuter * report.games)/
                    (report.avgInner+ report.avgOuter);
                      return ScatterChart(
        ScatterChartData(
                    scatterSpots: teams
              .map(
                    
                (element) => ScatterSpot(
                    element.averageShots.toDouble(),
                    element.stddev.toDouble(), ),
              )
              .toList(),
                      )

          scatterTouchData: ScatterTouchData(
            touchCallback: (p0) => {
              if (p0.touchedSpot != null)
                {
                  // onHover(teams[p0.touchedSpot.spotIndex]),
                  print(p0.clickHappened),
                  p0.clickHappened
                      ? onHover(teams[p0.touchedSpot.spotIndex])
                      : null,
                  // selectedTeam = teams[p0.touch  edSpot.spotIndex],
                  tooltip =
                      teams[p0.touchedSpot.spotIndex].teamNumber.toString(),
                  // inspect(p0),
                  // print(teams[p0.touchedSpot.spotIndex].teamNumber),
                }
            },
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: ScatterTouchTooltipData(
              tooltipBgColor: Colors.grey[400],
              getTooltipItems: (ScatterSpot touchedBarSpot) {
                // print(selectedTeam.teamNumber);
                return ScatterTooltipItem(tooltip, TextStyle(), 10);
              },
            ),
          ),

          //axis formatting
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              interval: 5,
              showTitles: true,
            ),
            leftTitles: SideTitles(
              interval: 5,
              showTitles: true,
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 5,
            verticalInterval: 5,
            drawHorizontalLine: true,
            checkToShowHorizontalLine: (value) => true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.black.withOpacity(0.1)),
            drawVerticalLine: true,
            checkToShowVerticalLine: (value) => true,
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.black.withOpacity(0.1)),
          ),
          axisTitleData: FlAxisTitleData(bottomTitle: AxisTitle()),
          borderData: FlBorderData(
            show: true,
          ),
          minX: 0,
          minY: 0,
          maxX: 100,
          maxY: 100,
        ),
      ),
        )
      ]

    ));
  }
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
