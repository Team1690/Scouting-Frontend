import "dart:collection";

import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/teams_search_box.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/compare/models/fetch_compare.dart";
import "package:scouting_frontend/views/pc/compare/widgets/lineChart/compare_gamechart_card.dart";
import "package:scouting_frontend/views/pc/compare/widgets/spiderChart/spider_chart_card.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/models/map_nullable.dart";

class CompareScreen extends StatefulWidget {
  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final SplayTreeSet<LightTeam> teams = SplayTreeSet<LightTeam>(
    (final LightTeam p0, final LightTeam p1) => p0.id.compareTo(p1.id),
  );
  final TextEditingController controller = TextEditingController();
  void removeTeam(final MapEntry<int, LightTeam> index) {
    teams.removeWhere(
      (final LightTeam entry) => entry.number == index.value.number,
    );
    controller.value = TextEditingValue.empty;
  }

  @override
  Widget build(final BuildContext context) {
    return isPC(context)
        ? DashboardScaffold(
            body: compareScreen(context),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text("Compare"),
              centerTitle: true,
            ),
            drawer: SideNavBar(),
            body: compareScreen(context),
          );
  }

  Padding compareScreen(final BuildContext context) => Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: isPC(context) ? 1 : 2,
                    child: TeamsSearchBox(
                      teams: TeamProvider.of(context).teams
                        ..removeWhere(teams.contains),
                      onChange: (final LightTeam team) {
                        if (teams.contains(team)) return;
                        setState(() {
                          teams.add(
                            team,
                          );
                        });
                      },
                      typeAheadController: controller,
                    ),
                  ),
                  SizedBox(width: defaultPadding),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      primary: false,
                      child: Row(
                        children: List<Padding>.generate(
                          teams.length,
                          (final int index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding / 2,
                            ),
                            child: Chip(
                              label: Text(
                                teams.elementAt(index).number.toString(),
                              ),
                              backgroundColor: teams.elementAt(index).color,
                              onDeleted: () => setState(
                                () => teams.remove(
                                  teams.elementAt(index),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: defaultPadding),
            Expanded(
              flex: 5,
              child: FutureBuilder<SplayTreeSet<CompareTeam>>(
                future: teams.isEmpty
                    ? Future<SplayTreeSet<CompareTeam>>(
                        always(SplayTreeSet<CompareTeam>()),
                      )
                    : fetchData(
                        teams.map((final LightTeam e) => e.id).toList(),
                      ),
                builder: (
                  final BuildContext context,
                  final AsyncSnapshot<SplayTreeSet<CompareTeam>?> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error!.toString());
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    if (isPC(context)) {
                      return Center(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: DashboardCard(
                                title: "Gamechart",
                                body: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: defaultPadding,
                            ),
                            Expanded(
                              flex: 3,
                              child: DashboardCard(
                                title: "Spiderchart",
                                body: Container(),
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }

                  return snapshot.data
                          .mapNullable((final SplayTreeSet<CompareTeam> data) {
                        if (isPC(context)) {
                          return Row(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: CompareGamechartCard(data, teams),
                              ),
                              SizedBox(width: defaultPadding),
                              Expanded(
                                flex: 3,
                                child: SpiderChartCard(teams, data),
                              ),
                            ],
                          );
                        } else {
                          return CarouselSlider(
                            items: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: CompareGamechartCard(data, teams),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: SpiderChartCard(teams, data),
                              ),
                            ],
                            options: CarouselOptions(
                              height: 3500,
                              aspectRatio: 2.0,
                              viewportFraction: 1,
                            ),
                          );
                        }
                      }) ??
                      (throw Exception("No data"));
                },
              ),
            )
          ],
        ),
      );
}
