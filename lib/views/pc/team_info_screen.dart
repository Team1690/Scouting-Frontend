import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/team_selection_future.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/team_info_data.dart';

class TeamInfoScreen extends StatefulWidget {
  TeamInfoScreen({Key? key, this.chosenTeam}) {
    if (chosenTeam != null) {
      controller.text = chosenTeam!.number.toString();
    }
  }
  LightTeam? chosenTeam;
  TextEditingController controller = TextEditingController();
  @override
  State<TeamInfoScreen> createState() => _TeamInfoScreenState();
}

class _TeamInfoScreenState extends State<TeamInfoScreen> {
  Future<List<LightTeam>?> fetchTeams() async {
    final GraphQLClient client = getClient();
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
      throw result.exception!;
    } else if (result.data == null) {
      return null;
    }
    return (result.data!['team'] as List<dynamic>)
        .map((dynamic e) =>
            LightTeam(e['id'] as int, e['number'] as int, e['name'] as String))
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
                      child: TeamSelectionFuture(
                        controller: widget.controller,
                        onChange: (newTeam) =>
                            setState(() => widget.chosenTeam = newTeam),
                      )),
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
                child: widget.chosenTeam == null
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
                    : TeamInfoData(team: widget.chosenTeam!),
              )
            ])));
  }
}
