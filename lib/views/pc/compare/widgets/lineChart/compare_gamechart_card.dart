import "dart:collection";

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
    final List<Color> colors = data
        .map(
          (final CompareTeam<E> element) => element.team.color,
        )
        .toList();
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
                        CompareLineChart<E>(
                          data
                              .map(
                                (final CompareTeam<E> element) =>
                                    element.upperScoredDataAuto,
                              )
                              .toList(),
                          colors,
                          "Auto Upper",
                        ),
                        CompareLineChart<E>(
                          data
                              .map(
                                (final CompareTeam<E> element) =>
                                    element.missedDataAuto,
                              )
                              .toList(),
                          colors,
                          "Auto Missed",
                        ),
                        CompareLineChart<E>(
                          data
                              .map(
                                (final CompareTeam<E> element) =>
                                    element.upperScoredDataTele,
                              )
                              .toList(),
                          colors,
                          "Teleop Upper",
                        ),
                        CompareLineChart<E>(
                          data
                              .map(
                                (final CompareTeam<E> element) =>
                                    element.missedDataTele,
                              )
                              .toList(),
                          colors,
                          "Teleop Missed",
                        ),
                        CompareLineChart<E>(
                          data
                              .map(
                                (final CompareTeam<E> element) =>
                                    element.allBallsScored,
                              )
                              .toList(),
                          colors,
                          "Balls",
                        ),
                        CompareLineChart<E>(
                          data
                              .map(
                                (final CompareTeam<E> element) =>
                                    element.pointsData,
                              )
                              .toList(),
                          colors,
                          "Points",
                        ),
                        CompareClimbLineChart<E>(
                          data
                              .map(
                                (final CompareTeam<E> element) =>
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
