import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class CompareClimbLineChart<E extends num> extends StatelessWidget {
  const CompareClimbLineChart(this.data);
  final List<CompareLineChartData<E>> data;
  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment(-1, -1),
          child: Text(data[0].title),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            top: 40,
          ),
          child: DashboardClimbLineChart<E>(
            showShadow: false,
            inputedColors:
                data.map((final CompareLineChartData<E> e) => e.color).toList(),
            matchNumbers: data
                .map<List<MatchIdentifier>>((final CompareLineChartData<E> e) {
              int number = 1;
              return e.matchStatuses
                  .map<MatchIdentifier>(
                    (final RobotMatchStatus e) => MatchIdentifier(
                      number: number++,
                      type: "Quals",
                      robotMatchStatus: e,
                    ),
                  )
                  .toList();
            }).toList(),
            dataSet: data
                .map(
                  (final CompareLineChartData<E> e) => e.points,
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
