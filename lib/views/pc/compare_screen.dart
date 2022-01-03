import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/radar_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

// ignore: must_be_immutable
class CompareScreen extends StatefulWidget {
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Team chosenTeam = Team();
  List<Team> compareTeamsList = [];
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
      .removeWhere((Team entry) => entry.teamNumber == index.value.teamNumber);

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
                      child: FutureBuilder(
                          future: fetchTeams(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error has happened in the future! ' +
                                  snapshot.error.toString());
                            } else if (!snapshot.hasData) {
                              return Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.search),
                                        border: const OutlineInputBorder(),
                                        hintText: 'Search Team',
                                        enabled: false,
                                      ),
                                    ),
                                    Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ]);

                              // const CircularProgressIndicator();
                            } else {
                              return TeamsSearchBox(
                                  typeAheadController: TextEditingController(),
                                  teams: snapshot.data as List<LightTeam>,
                                  onChange: (LightTeam team) => {
                                        setState(() => compareTeamsList.add(
                                            new Team(
                                                teamNumber: team.number,
                                                id: team.id)))
                                      });
                            }
                          })),
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
                                  label:
                                      Text(index.value.teamNumber.toString()),
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
                                body: CarouselSlider(
                                  options: CarouselOptions(
                                    height: 3500,
                                    viewportFraction: 1,
                                    // autoPlay: true,
                                  ),
                                  items: List.generate(
                                      2, //TODO: make modular
                                      // compare TeamsList.first.tables.length,
                                      (index) => DashboardLineChart(
                                          colors: colors,
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
                                      colors: Colors.primaries,
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
                          child: SpiderChart(
                              numberOfFeatures: 4,
                              data: compareTeamsList
                                  .map((team) => team.spider)
                                  .toList(),
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
