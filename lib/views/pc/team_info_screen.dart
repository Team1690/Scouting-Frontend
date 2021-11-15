import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/team_info_data.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';
import 'package:graphql/client.dart';

class TeamInfoScreen extends StatefulWidget {
  @override
  State<TeamInfoScreen> createState() => _TeamInfoScreenState();
}

class _TeamInfoScreenState extends State<TeamInfoScreen> {
  int chosenTeam;

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
    print(result.data);
    return (result.data['team'] as List<dynamic>)
        .map((e) => LightTeam(e['id'], e['number'], e['name']))
        .toList();
    //.entries.map((e) => LightTeam(e['id']);
  }

  @override
  Widget build(BuildContext context) {
    // print(data[0].msg[0]);
    return DashboardScaffold(
        body: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(children: [
              Row(
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
                                        setState(() => chosenTeam = team.number)
                                      });
                            }
                          })),
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
              SizedBox(height: defaultPadding),
              Expanded(
                flex: 10,
                child: chosenTeam == null
                    ? DashboardCard(
                        title: '',
                        body: Center(
                            child: Column(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            Icon(
                              Icons.search,
                              size: 100,
                            ),
                            SizedBox(height: defaultPadding),
                            Text(
                                'Please choose a team in order to display data'),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        )))
                    : TeamInfoData(team: chosenTeam),
              )
            ])));
  }
}
