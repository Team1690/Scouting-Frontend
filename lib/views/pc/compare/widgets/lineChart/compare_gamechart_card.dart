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

class CompareGamechartCard extends StatelessWidget {
  const CompareGamechartCard(this.data, this.teams);
  final SplayTreeSet<CompareTeam> data;
  final SplayTreeSet<LightTeam> teams;
  @override
  Widget build(final BuildContext context) {
    final Iterable<CompareTeam> emptyTeams = data.where(
      (final CompareTeam element) => element.gamepieces.points.length < 2,
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
                  "teams: ${emptyTeams.map((final CompareTeam compareTeam) => compareTeam.team.number).toString()} have insufficient data, please remove them",
                )
              : Builder(
                  builder: (
                    final BuildContext context,
                  ) =>
                      CarouselWithIndicator(
                    direction: isPC(context) ? Axis.horizontal : Axis.vertical,
                    widgets: <Widget>[
                      CompareLineChart(
                        data
                            .map(
                              (final CompareTeam element) => element.points,
                            )
                            .toList(),
                        colors,
                        "Points",
                      ),
                      CompareLineChart(
                        data
                            .map(
                              (final CompareTeam element) => element.gamepieces,
                            )
                            .toList(),
                        colors,
                        "Total Gamepieces",
                      ),
                      CompareLineChart(
                        data
                            .map(
                              (final CompareTeam element) =>
                                  element.autoGamepieces,
                            )
                            .toList(),
                        colors,
                        "Auto Gamepieces",
                      ),
                      CompareLineChart(
                        data
                            .map(
                              (final CompareTeam element) =>
                                  element.teleGamepieces,
                            )
                            .toList(),
                        colors,
                        "Teleop Gamepieces",
                      ),
                      CompareLineChart(
                        data
                            .map(
                              (final CompareTeam element) => element.totalCones,
                            )
                            .toList(),
                        colors,
                        "Total Cones",
                      ),
                      CompareLineChart(
                        data
                            .map(
                              (final CompareTeam element) => element.totalCubes,
                            )
                            .toList(),
                        colors,
                        "Total Cubes",
                      ),
                      CompareLineChart(
                        data
                            .map(
                              (final CompareTeam element) =>
                                  element.totalDelivered,
                            )
                            .toList(),
                        colors,
                        "Total Delivered",
                      ),
                      CompareClimbLineChart(
                        data
                            .map(
                              (final CompareTeam element) =>
                                  element.autoBalanceVals,
                            )
                            .toList(),
                        colors,
                        "Auto Balance Values",
                      ),
                      CompareClimbLineChart(
                        data
                            .map(
                              (final CompareTeam element) =>
                                  element.endgameBalanceVals,
                            )
                            .toList(),
                        colors,
                        "Endgame Balance Values",
                      ),
                    ],
                  ),
                ),
    );
  }
}
