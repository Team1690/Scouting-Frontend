import 'dart:html';
import "dart:math" as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';

class ScatterData {
  ScatterData(this.avgInner, this.avgOuter, this.stddevInner, this.stddevOuter,
      this.number);
  final double avgInner;
  final double avgOuter;
  final double stddevInner;
  final double stddevOuter;
  final int number;
}

// ignore: must_be_immutable
class Scatter extends StatelessWidget {
  double stddev(e) {
    return ((e.avgInner + e.avgOuter) != 0)
        ? ((e.stddevInner * e.avgInner) + (e.stddevOuter * e.avgOuter)) /
            (e.avgInner + e.avgOuter)
        : 0;
  }

  Future<List<ScatterData>> fetchScatter() async {
    final client = getClient();
    final String query = """query MyQuery{
  team{
    stats: matches_aggregate {
      aggregate {
        avg {
          teleop_inner
          teleop_outer
        }
        stddev {
          teleop_inner
          teleop_outer
        }
        count(columns: team_id)
      }
    }
    number
  }
}
""";

    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) {
      print(result.exception.toString());
    } else {
      //TODO: avoid dynamic
      return (result.data['team'] as List<dynamic>)
          .map((e) => ScatterData(
              e['stats']['aggregate']['avg']['teleop_inner'],
              e['stats']['aggregate']['avg']['teleop_outer'],
              e['stats']['aggregate']['stddev']['teleop_inner'] ?? 0,
              e['stats']['aggregate']['stddev']['teleop_outer'] ?? 0,
              e['number']))
          .toList();
    }
  }

  Scatter({
    @required this.onHover,
    Key key,
    List<Team> teams,
  }) : super(key: key);
  List<Team> teams;

  final Function(Team team) onHover;

  @override
  Widget build(BuildContext context) {
    Team selectedTeam;
    String tooltip;
    return Container(
        color: secondaryColor,
        child: Column(children: [
          Expanded(
              flex: 1,
              child: FutureBuilder(
                  future: fetchScatter(),
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
                        return Text('invalid data :(');
                      }
                      final List<ScatterData> report = snapshot.data
                          .map((e) => ScatterData(e.avgInner, e.avgOuter,
                              e.stddevInner, e.stddevOuter, e.number))
                          .toList()
                          .cast<ScatterData>();
                      teams = report
                          .map((e) => Team(teamNumber: e.number))
                          .toList();
                      return ScatterChart(ScatterChartData(
                        scatterSpots: report
                            .map((e) => ScatterSpot(
                                  (e.avgInner + e.avgOuter).toDouble(),
                                  stddev(e),
                                ))
                            .toList(),
                        scatterTouchData: ScatterTouchData(
                          touchCallback: (p0) => {
                            if (p0.touchedSpot != null)
                              {
                                tooltip = teams[p0.touchedSpot.spotIndex]
                                    .teamNumber
                                    .toString(),
                              }
                          },
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchTooltipData: ScatterTouchTooltipData(
                            tooltipBgColor: Colors.grey[400],
                            getTooltipItems: (ScatterSpot touchedBarSpot) {
                              return ScatterTooltipItem(
                                  tooltip, TextStyle(), 10);
                            },
                          ),
                        ),
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
                          horizontalInterval: report
                                  .map((e) => (e.avgInner + e.avgOuter))
                                  .reduce(math.max) /
                              10,
                          verticalInterval:
                              report.map((e) => stddev(e)).reduce(math.max) /
                                  10,
                          drawHorizontalLine: true,
                          checkToShowHorizontalLine: (value) => true,
                          getDrawingHorizontalLine: (value) =>
                              FlLine(color: Colors.black.withOpacity(0.1)),
                          drawVerticalLine: true,
                          checkToShowVerticalLine: (value) => true,
                          getDrawingVerticalLine: (value) =>
                              FlLine(color: Colors.black.withOpacity(0.1)),
                        ),
                        axisTitleData:
                            FlAxisTitleData(bottomTitle: AxisTitle()),
                        borderData: FlBorderData(
                          show: true,
                        ),
                        minX: 0,
                        minY: 0,
                        maxX: report
                            .map((e) => (e.avgInner + e.avgOuter))
                            .reduce((curr, next) => curr > next ? curr : next),
                        maxY: report
                            .map((e) => stddev(e))
                            .reduce((curr, next) => curr > next ? curr : next),
                      ));
                    }
                  }))
        ]));
  }
}
