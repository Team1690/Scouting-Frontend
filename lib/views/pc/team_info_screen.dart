import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/navigation_tab.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:scouting_frontend/views/pc/widgets/spider_chart.dart';
import 'package:flutter/material.dart';
import 'package:multi_charts/multi_charts.dart';

class TeamInfoScreen extends StatelessWidget {
  @override
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
                                // flex: 2,
                                child: DashboardCard(
                                    title: 'Quick Data',
                                    body: SpiderChart(values: [
                                      9,
                                      8,
                                      6,
                                      5,
                                      2,
                                    ], labels: [
                                      "Points per Game",
                                      "Balls per Game",
                                      "Auto points",
                                      "Climbs %",
                                      "Total climbs",
                                    ], maxValue: 10)),
                              ),
                              SizedBox(width: defaultPadding),
                              Expanded(
                                // flex:
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
                            body: CarouselSlider(
                              options: CarouselOptions(
                                height: 3500,
                                viewportFraction: 1,
                                autoPlay: true,
                              ),
                              items: [
                                DashboardLineChart(),
                                DashboardLineChart(),
                                DashboardLineChart(),
                              ],
                            ),
                            // body: Padding(
                            //   padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                            //   child: LineChart(LineChartData(
                            //     lineBarsData: List.generate(
                            //         1,
                            //         (index1) => LineChartBarData(
                            //             spots: List.generate(
                            //                 10,
                            //                 (index) => FlSpot(index.toDouble(),
                            //                     index.toDouble())))),
                            //   ))),
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
                        body: Container(),
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
