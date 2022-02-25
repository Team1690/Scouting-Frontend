import "dart:collection";

import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/compare/models/fetch_compare.dart";
import "package:scouting_frontend/views/pc/compare/widgets/lineChart/compare_gamechart_card.dart";
import "package:scouting_frontend/views/pc/compare/widgets/spiderChart/spider_chart_card.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/models/map_nullable.dart";

class CompareScreen<E extends num> extends StatefulWidget {
  @override
  _CompareScreenState<E> createState() => _CompareScreenState<E>();
}

class _CompareScreenState<E extends num> extends State<CompareScreen<E>> {
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
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TeamSelectionFuture(
                      onChange: (final LightTeam team) {
                        if (teams.contains(team)) return;
                        setState(() {
                          teams.add(
                            team,
                          );
                        });
                      },
                      controller: controller,
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
                  ToggleButtons(
                    children: <Widget>[
                      Icon(Icons.shield_rounded),
                      Icon(Icons.remove_moderator_outlined),
                    ],
                    isSelected: <bool>[false, false],
                    //Currently unused feature
                    onPressed: (final int index) {},
                  ),
                ],
              ),
            ),
            SizedBox(height: defaultPadding),
            Expanded(
              flex: 5,
              child: FutureBuilder<SplayTreeSet<CompareTeam<E>>>(
                future: teams.isEmpty
                    ? Future<SplayTreeSet<CompareTeam<E>>>(
                        always(SplayTreeSet<CompareTeam<E>>()),
                      )
                    : fetchData<E>(
                        teams.map((final LightTeam e) => e.id).toList(),
                      ),
                builder: (
                  final BuildContext context,
                  final AsyncSnapshot<SplayTreeSet<CompareTeam<E>>?> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return DashboardScaffold(
                      body: Text(snapshot.error!.toString()),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                  }

                  return snapshot.data.mapNullable(
                        (final SplayTreeSet<CompareTeam<E>> data) => Row(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: CompareGamechartCard<E>(data, teams),
                            ),
                            SizedBox(width: defaultPadding),
                            Expanded(
                              flex: 3,
                              child: SpiderChartCard<E>(teams, data),
                            ),
                          ],
                        ),
                      ) ??
                      (throw Exception("No data"));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
