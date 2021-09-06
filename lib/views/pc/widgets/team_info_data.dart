import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/radar_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/scouting_specific.dart';

import '../../constants.dart';

class TeamInfoData extends StatefulWidget {
  const TeamInfoData({
    Key key,
    @required this.team,
  }) : super(key: key);

  final Team team;

  @override
  State<TeamInfoData> createState() => _TeamInfoDataState();
}

class _TeamInfoDataState extends State<TeamInfoData> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: DashboardCard(
                          title: 'Quick Data',
                          body: SpiderChart(numberOfFeatures: 4, data: [
                            widget.team.spider,
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
                            "Climb %",
                          ]),
                        )),
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
                    items: widget.team.tables
                        .map((table) => DashboardLineChart(
                              colors: colors,
                              dataSets: [table],
                            ))
                        .toList(),
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
              body: ScoutingSpecific(msg: widget.team.msg),
            ))
      ],
    );
  }
}
