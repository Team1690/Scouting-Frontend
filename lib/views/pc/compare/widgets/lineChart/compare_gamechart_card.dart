import "dart:collection";

import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/carousel_with_indicator.dart";
import "package:scouting_frontend/views/common/no_team_selected.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/compare/widgets/lineChart/compare_climb_line_chart.dart";
import "package:scouting_frontend/views/pc/compare/widgets/lineChart/compare_line_chart.dart";

class CompareGamechartCard extends StatelessWidget {
  const CompareGamechartCard(this.data, this.teams);
  final SplayTreeSet<CompareTeam> data;
  final SplayTreeSet<LightTeam> teams;
  bool isPC(final BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return false;

      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return true;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final Iterable<CompareTeam> emptyTeams = data.where(
      (final CompareTeam element) => element.climbData.points.length < 2,
    );
    final List<Color> colors = data
        .map(
          (final CompareTeam element) => element.team.color,
        )
        .toList();
    return DashboardCard(
      title: "Gamechart",
      body: teams.isEmpty
          ? NoTeamSelected()
          : emptyTeams.isNotEmpty
              ? Text(
                  "teams: ${emptyTeams.map((final CompareTeam e) => e.team.number).toString()} have insufficient data please remove them",
                )
              : Builder(
                  builder: (
                    final BuildContext context,
                  ) {
                    return CarouselWithIndicator(
                      direction:
                          isPC(context) ? Axis.horizontal : Axis.vertical,
                      widgets: <Widget>[
                        CompareLineChart(
                          data
                              .map(
                                (final CompareTeam element) =>
                                    element.upperScoredDataAuto,
                              )
                              .toList(),
                          colors,
                          "Auto Upper",
                        ),
                        CompareLineChart(
                          data
                              .map(
                                (final CompareTeam element) =>
                                    element.missedDataAuto,
                              )
                              .toList(),
                          colors,
                          "Auto Missed",
                        ),
                        CompareLineChart(
                          data
                              .map(
                                (final CompareTeam element) =>
                                    element.upperScoredDataTele,
                              )
                              .toList(),
                          colors,
                          "Teleop Upper",
                        ),
                        CompareLineChart(
                          data
                              .map(
                                (final CompareTeam element) =>
                                    element.missedDataTele,
                              )
                              .toList(),
                          colors,
                          "Teleop Missed",
                        ),
                        CompareLineChart(
                          data
                              .map(
                                (final CompareTeam element) =>
                                    element.allBallsScored,
                              )
                              .toList(),
                          colors,
                          "Balls",
                        ),
                        CompareLineChart(
                          data
                              .map(
                                (final CompareTeam element) =>
                                    element.pointsData,
                              )
                              .toList(),
                          colors,
                          "Points",
                        ),
                        CompareClimbLineChart(
                          data
                              .map(
                                (final CompareTeam element) =>
                                    element.climbData,
                              )
                              .toList(),
                          colors,
                          "Climb",
                        )
                      ],
                    );
                  },
                ),
    );
  }
}
