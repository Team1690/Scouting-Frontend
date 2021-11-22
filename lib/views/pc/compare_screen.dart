import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/carousel_with_indicator.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/radar_chart.dart';
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
  List<LightTeam> compareTeamsList = [];
  // List tables;

  Future<List<LightTeam>> fetchTeams() async {
    final client = getClient();
    final String query = """
query FetchTeams {
  team {
    id
    number
    name
  }
}
  """;

    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) {
      print(result.exception.toString());
    } //TODO: avoid dynamic
    return (result.data['team'] as List<dynamic>)
        .map((e) => LightTeam(e['id'], e['number'], e['name']))
        .toList();
    //.entries.map((e) => LightTeam(e['id']);
  }

  void addTeam(team) => compareTeamsList.add(team);
  void removeTeam(index) => compareTeamsList
      .removeWhere((LightTeam entry) => entry.number == index.value.teamNumber);

  Widget build(BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  teamSearch((LightTeam team) => {
                        setState(() => compareTeamsList.add(
                            new LightTeam(team.id, team.number, team.name)))
                      }),
                  SizedBox(width: defaultPadding),
                  Expanded(
                    flex: 2,
                    child: Row(
                        children: compareTeamsList
                            .asMap()
                            .entries
                            .map(
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding / 2),
                                child: Chip(
                                  label: Text(index.value.number.toString()),
                                  backgroundColor: colors[index.key],
                                  onDeleted: () =>
                                      setState(() => removeTeam(index)),
                                ),
                              ),
                            )
                            .toList()),
                  ),
                  SizedBox(width: defaultPadding),
                  Expanded(flex: 3, child: Container()),
                  SizedBox(width: defaultPadding),
                  Align(
                      alignment: Alignment.centerRight,
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
                                body: CarouselWithIndicator(widgets: []))),
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
                              items: [],
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
