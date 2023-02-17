import "dart:collection";

import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/compare/widgets/spiderChart/compare_spider_chart.dart";

class SpiderChartCard extends StatelessWidget {
  const SpiderChartCard(this.teams, this.data);
  final SplayTreeSet<LightTeam> teams;
  final SplayTreeSet<CompareTeam> data;
  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "Spiderchart",
        body: Center(
          child: teams.isEmpty
              ? Container()
              : CompareSpiderChart(
                  data,
                ),
        ),
      );
}
