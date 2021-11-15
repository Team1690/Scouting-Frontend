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

  Future<List<Team>> fetchGameChart(int teamId) async {
    final client = getClient();
    final String query = """
query MyQuery (\$team_id: Int){
  team(where: {id: {_eq: \$team_id}}) {
    matches_aggregate{
      aggregate {
        avg {
          auto_balls
          teleop_inner
          teleop_outer
        }
        count(columns: id)
      }
    }
    matches{
      auto_balls
      teleop_inner
      teleop_outer
      climb_id
    }
  }
}


  """;

    final QueryResult result = await client.query(
        QueryOptions(document: gql(query), variables: {"team_id": teamId}));
    if (result.hasException) {
      print(result.exception.toString());
    } //TODO: avoid dynamic
    // for(int i = 0; i < (result.data['team'][0]['matches'] as List<dynamic>).length; i++){
    //   dynamic f = result.data['team'][0]['matches'] as List<dynamic>;
    //   print(((f as List<dynamic>).map((g) => [
    //                 g['auto_balls'] + g['teleop_inner'] + g['teleop_outer'],
    //                 g['climb_id']]).toList()).runtimeType);
    //   print([
    //                 f[i]['auto_balls'] + f[i]['teleop_inner'] + f[i]['teleop_outer'],
    //                 f[i]['climb_id']]);
    // }

    return (result.data['team'] as List<dynamic>)
        .map((e) => Team(
              autoGoalAverage: e['matches_aggregate']['aggregate']['avg']['auto_balls'],
              teleInnerGoalAverage: e['matches_aggregate']['aggregate']['avg']['teleop_inner'],
              teleOuterGoalAverage: e['matches_aggregate']['aggregate']['avg']['teleop_outter'],
              id: teamId,
              tables: ((e['matches'] as List<dynamic>).map((g) => [
                    g['auto_balls'] + g['teleop_inner'] + g['teleop_outer'],
                    g['climb_id']]).toList()))).toList();
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
                                  teams: snapshot.data as List<LightTeam>,
                                  onChange: (LightTeam team) => {
                                        setState(() => addTeam(team)),
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
                                      Text(index.value.number.toString()),
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
                                              .map((team) => team)
                                              .toList())),
                                ))),
                      
                      ],
                    ),
                  ),
                  SizedBox(width: defaultPadding),
                  Expanded(
                      flex: 2,
                      child: DashboardCard(
                        title: 'Compare Spider Chart',
                        body: Center(
                          child: FutureBuilder(future: fetchGameChart(1),builder: (context, snapshot){
                            print(snapshot.data[0].teleInnerGoalAverage);
                            return  SpiderChart(
                              numberOfFeatures: 4,
                              data: (snapshot.data as List<dynamic>).map((e) => [1, 1 , e.teleInnerGoalAverage.toInt() as int, (e.autoGoalAverage.toInt() as int) * 3]).toList(),
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
                              ]);
                          },)
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
