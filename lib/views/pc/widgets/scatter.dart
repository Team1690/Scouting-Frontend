import "dart:math" as math;
import "package:flutter/material.dart";
import "package:fl_chart/fl_chart.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";

class ScatterData {
  ScatterData(
    this.avgInner,
    this.avgOuter,
    this.stddevInner,
    this.stddevOuter,
    this.number,
    this.id,
    this.name,
  );
  final double avgInner;
  final double avgOuter;
  final double stddevInner;
  final double stddevOuter;
  final int number;
  final int id;
  final String name;

  double get sumOfAvg {
    return avgInner + avgOuter;
  }
}

class Scatter extends StatelessWidget {
  Scatter({
    required this.onHover,
  });

  double stddev(final ScatterData e) {
    return ((e.sumOfAvg) != 0)
        ? ((e.stddevInner * e.avgInner) + (e.stddevOuter * e.avgOuter)) /
            (e.sumOfAvg)
        : 0;
  }

  Future<List<ScatterData>> fetchScatter() async {
    final GraphQLClient client = getClient();
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
    id
    name
  }
}
""";

    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));

    return result.mapQueryResult(
      (final Map<String, dynamic>? data) =>
          data.mapNullable(
            (final Map<String, dynamic> scatterData) => (scatterData["team"]
                    as List<dynamic>)
                .map(
                  (final dynamic e) => ScatterData(
                    e["stats"]["aggregate"]["avg"]["teleop_inner"] as double,
                    e["stats"]["aggregate"]["avg"]["teleop_outer"] as double,
                    e["stats"]["aggregate"]["stddev"]["teleop_inner"]
                            as double? ??
                        0,
                    e["stats"]["aggregate"]["stddev"]["teleop_outer"]
                            as double? ??
                        0,
                    e["number"] as int,
                    e["id"] as int,
                    e["name"] as String,
                  ),
                )
                .toList(),
          ) ??
          <ScatterData>[],
    );
  }

  final Function(Team team) onHover;

  @override
  Widget build(final BuildContext context) {
    String? tooltip;
    return Container(
      color: secondaryColor,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: FutureBuilder<List<ScatterData>>(
              future: fetchScatter(),
              builder: (
                final BuildContext context,
                final AsyncSnapshot<List<ScatterData>> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Text(
                    "Error has happened in the future! " +
                        snapshot.error.toString(),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.data!.isEmpty) {
                    return Text("invalid data :(");
                  }
                  final List<ScatterData> report = snapshot.data!
                      .map<ScatterData>(
                        (final ScatterData e) => ScatterData(
                          e.avgInner,
                          e.avgOuter,
                          e.stddevInner,
                          e.stddevOuter,
                          e.number,
                          e.id,
                          e.name,
                        ),
                      )
                      .toList();
                  final List<Team> teams = report
                      .map(
                        (final ScatterData e) => Team(
                          teamNumber: e.number,
                          teamName: e.name,
                          id: e.id,
                        ),
                      )
                      .toList();
                  return ScatterChart(
                    ScatterChartData(
                      scatterSpots: report
                          .map(
                            (final ScatterData e) => ScatterSpot(
                              (e.sumOfAvg).toDouble(),
                              stddev(e),
                            ),
                          )
                          .toList(),
                      scatterTouchData: ScatterTouchData(
                        touchCallback: (
                          final FlTouchEvent event,
                          final ScatterTouchResponse? response,
                        ) {
                          if (response?.touchedSpot != null) {
                            tooltip = teams[response!.touchedSpot!.spotIndex]
                                .teamNumber
                                .toString();
                          }
                        },
                        enabled: true,
                        handleBuiltInTouches: true,
                        touchTooltipData: ScatterTouchTooltipData(
                          tooltipBgColor: bgColor,
                          getTooltipItems: (final ScatterSpot touchedBarSpot) {
                            return ScatterTooltipItem(
                              tooltip!,
                              textStyle: TextStyle(color: Colors.white),
                              bottomMargin: 10,
                            );
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
                                .map((final ScatterData e) => (e.sumOfAvg))
                                .reduce(math.max) /
                            10,
                        verticalInterval:
                            report.map(stddev).reduce(math.max) / 10,
                        drawHorizontalLine: true,
                        checkToShowHorizontalLine: (final double value) => true,
                        getDrawingHorizontalLine: (final double value) =>
                            FlLine(color: Colors.black.withOpacity(0.1)),
                        drawVerticalLine: true,
                        checkToShowVerticalLine: (final double value) => true,
                        getDrawingVerticalLine: (final double value) =>
                            FlLine(color: Colors.black.withOpacity(0.1)),
                      ),
                      axisTitleData: FlAxisTitleData(bottomTitle: AxisTitle()),
                      borderData: FlBorderData(
                        show: true,
                      ),
                      minX: 0,
                      minY: 0,
                      maxX: report
                          .map((final ScatterData e) => (e.sumOfAvg))
                          .reduce(math.max),
                      maxY: report.map(stddev).reduce(math.max),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
