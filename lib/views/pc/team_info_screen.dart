import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:scouting_frontend/views/pc/widgets/radar_chart.dart';

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
                                    body: Container(
                                      child: SpiderChart(
                                          numberOfFeatures: 4,
                                          data: [
                                            [
                                              85,
                                              29,
                                              69,
                                              80,
                                            ],
                                            [89, 45, 32, 56],
                                            [68, 30, 19, 100]
                                          ],
                                          ticks: [
                                            0,
                                            25,
                                            50,
                                            75,
                                            100
                                          ],
                                          features: [
                                            "PPG",
                                            "BPG",
                                            "Auto Points",
                                            "Climb %",
                                          ]),
                                    )),
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
