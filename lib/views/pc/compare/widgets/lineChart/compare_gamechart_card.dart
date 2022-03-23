import "dart:collection";
import "dart:math";

import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/carousel_with_indicator.dart";
import "package:scouting_frontend/views/common/no_team_selected.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/compare/widgets/lineChart/compare_climb_line_chart.dart";
import "package:scouting_frontend/views/pc/compare/widgets/lineChart/compare_line_chart.dart";

class CompareGamechartCard<E extends num> extends StatelessWidget {
  const CompareGamechartCard(this.data, this.teams);
  final SplayTreeSet<CompareTeam<E>> data;
  final SplayTreeSet<LightTeam> teams;
  @override
  Widget build(final BuildContext context) {
    final Iterable<CompareTeam<E>> emptyTeams = data.where(
      (final CompareTeam<E> element) => element.climbData.points.length < 2,
    );

    final List<CompareLineChartData<E>> teleScored =
        <CompareLineChartData<E>>[];

    final List<CompareLineChartData<E>> teleMissed =
        <CompareLineChartData<E>>[];

    final List<CompareLineChartData<E>> climb = <CompareLineChartData<E>>[];

    final List<CompareLineChartData<E>> autoScored =
        <CompareLineChartData<E>>[];

    final List<CompareLineChartData<E>> autoMissed =
        <CompareLineChartData<E>>[];

    final List<CompareLineChartData<E>> allBalls = <CompareLineChartData<E>>[];
    for (final CompareTeam<E> item in data) {
      if ((item.climbData.points.length > 1)) {
        teleScored.add(
          item.upperScoredDataTele,
        );
        allBalls.add(item.allBallsScored);
        teleMissed.add(
          item.missedDataTele,
        );
        autoScored.add(
          item.upperScoredDataAuto,
        );
        autoMissed.add(
          item.missedDataAuto,
        );
        climb.add(item.climbData);
      }
    }
    int longestList = -1;
    for (final CompareLineChartData<E> element in climb) {
      longestList = max(
        longestList,
        element.points.length,
      );
    }

    return DashboardCard(
      title: "Gamechart",
      body: teams.isEmpty
          ? NoTeamSelected()
          : emptyTeams.isNotEmpty
              ? Text(
                  "teams: ${emptyTeams.map((final CompareTeam<E> e) => e.team.number).toString()} have insufficient data please remove them",
                )
              : Builder(
                  builder: (
                    final BuildContext context,
                  ) {
                    return CarouselWithIndicator(
                      direction:
                          isPC(context) ? Axis.horizontal : Axis.vertical,
                      widgets: <Widget>[
                        CompareLineChart<E>(autoScored),
                        CompareLineChart<E>(autoMissed),
                        CompareLineChart<E>(teleScored),
                        CompareLineChart<E>(teleMissed),
                        CompareLineChart<E>(allBalls),
                        CompareClimbLineChart<E>(climb)
                      ],
                    );
                  },
                ),
    );
  }
}
