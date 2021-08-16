import 'dart:math';
import 'package:faker/faker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/get_teams_api.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/navigation_tab.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TeamInfoScreen extends StatelessWidget {
  TeamInfoScreen({@required this.data});
  final List<Team> data;
  @override
  Widget build(BuildContext context) {
    // print(data[0].msg[0]);
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
                    child: TextField(
                        decoration:
                            InputDecoration(hintText: 'Search Team Number')),
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
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DashboardCard(
                                  title: 'Quick Data',
                                  body: Column(
                                    children: [
                                      Text(
                                          'Average shootig points: ${data[0].averageShots * 2.5}'),
                                      Text(
                                          'Average ball Scored: ${data[0].averageShots}'),
                                      Text(
                                          'Average auto shootig points: ${data[0].averageShots * 0.5}')
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: defaultPadding),
                              Expanded(
                                flex: 3,
                                child: DashboardCard(
                                  title: 'Pit Scouting',
                                  body: Container(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: defaultPadding),
                        Expanded(
                          flex: 4,
                          child: DashboardCard(
                            title: 'Game Chart',
                            // body: Container(),
                            body: CarouselSlider(
                              options: CarouselOptions(
                                height: 3500,
                                viewportFraction: 1,
                                // autoPlay: true,
                              ),
                              items: [
                                DashboardLineChart(),
                                // DashboardLineChart(),
                                // DashboardLineChart(),
                              ],
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
                        title: 'Scouting Specific',
                        body: SingleChildScrollView(
                          child: Column(
                            children: data[0]
                                .msg
                                .map(
                                  (e) => Card(
                                    // shape: ,
                                    elevation: 10,
                                    color: bgColor,
                                    margin: EdgeInsets.fromLTRB(
                                        5, 0, 5, defaultPadding),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(defaultPadding),
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                            color: primaryWhite, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
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
