import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/globals.dart' as globals;
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/radar_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/scouting_specific.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

// ignore: must_be_immutable
class CompareScreen extends StatefulWidget {
  CompareScreen({
    @required this.teams,
  });
  final List<Team> teams;
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Team chosenTeam = Team();
  List<Team> compareTeamsList = [];
  // List tables;

  void addTeam(team) => compareTeamsList.add(team);

  Widget build(BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TeamsSearchBox(
                        teams: widget.teams,
                        onChange: (Team team) => setState(() => addTeam(team))),
                  ),
                  SizedBox(width: defaultPadding),
                  Expanded(
                      flex: 2,
                      child: ToggleButtons(
                        children: [
                          Icon(Icons.shield_rounded),
                          Icon(Icons.remove_moderator_outlined),
                        ],
                        isSelected: [false, false],
                        onPressed: (int index) {},
                      )),
                ],
              ),
            ),
            SizedBox(height: defaultPadding),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                            flex: 3,
                            child: DashboardCard(
                                title: 'Game Chart',
                                // body: Container(),
                                body: CarouselSlider(
                                  options: CarouselOptions(
                                    height: 3500,
                                    viewportFraction: 1,
                                    // autoPlay: true,
                                  ),
                                  items: List.generate(
                                      2, //TODO: make modular
                                      // compareTeamsList.first.tables.length,
                                      (index) => DashboardLineChart(
                                          dataSets: compareTeamsList
                                              .map((team) => team.tables[index])
                                              .toList())),
                                ))),
                        SizedBox(height: defaultPadding),
                        Expanded(
                          flex: 3,
                          child: DashboardCard(
                            title: 'Game Chart',
                            // body: Container(),
                            body: CarouselSlider(
                              options: CarouselOptions(
                                height: 3500,
                                viewportFraction: 1,
                                // autoPlay: true,
                              ),
                              items: List.generate(
                                  2, //TODO: make modular
                                  // compareTeamsList.first.tables.length,
                                  (index) => DashboardLineChart(
                                      dataSets: compareTeamsList
                                          .map((team) => team.tables[index])
                                          .toList())),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: defaultPadding),
                  Expanded(
                      flex: 2,
                      child: DashboardCard(
                        title: 'Compare Spider Chart',
                        body: Center(
                          child: SpiderChart(numberOfFeatures: 4, data: [
                            chosenTeam.spider,
                          ], ticks: [
                            0,
                            25,
                            50,
                            75,
                            100
                          ], features: [
                            "PPG",
                            "BPG",
                            "Auto Points",
                            "Climb",
                          ]),
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
