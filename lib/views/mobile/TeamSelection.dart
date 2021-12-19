import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

class TeamSelection extends StatefulWidget {
  TeamSelection({Key key, this.onChange, this.controller}) : super(key: key);
  @required
  final TextEditingController controller;
  final Function(LightTeam) onChange;
  @override
  State<TeamSelection> createState() => _TeamSelectionState();
}

class _TeamSelectionState extends State<TeamSelection> {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchTeams(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error has happened in the future! ' +
                snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return Stack(alignment: AlignmentDirectional.center, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    hintText: 'Search Team',
                    enabled: false,
                  ),
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ]);

            // const CircularProgressIndicator();
          } else {
            return Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: TeamsSearchBox(
                typeAheadController: widget.controller,
                teams: snapshot.data as List<LightTeam>,
                onChange: (LightTeam) {
                  setState(() {
                    widget.onChange(LightTeam);
                  });
                },
              ),
            );
          }
        });
  }
}
