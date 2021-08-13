import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/navigation_tab.dart';

class TeamInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                        decoration: InputDecoration(
                            hintText: 'Search Team Number',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryWhite),
                            ),
                            fillColor: primaryWhite,
                            border: OutlineInputBorder())),
                  ),
                ],
              ),
            ),
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
                                  body: Container(),
                                ),
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
                            body: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                              child: LineChart(LineChartData(
                                  lineBarsData: List.generate(
                                      1,
                                      (index1) => LineChartBarData(
                                          spots: List.generate(
                                              10,
                                              (index) => FlSpot(
                                                  index.toDouble(),
                                                  index.toDouble())))))),
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
                        title: 'Scouting Spesific',
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
