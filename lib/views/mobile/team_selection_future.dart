import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

class TeamSelectionFuture extends StatefulWidget {
  TeamSelectionFuture({this.onChange = ignore, required this.controller});
  final TextEditingController controller;
  final void Function(LightTeam) onChange;
  @override
  State<TeamSelectionFuture> createState() => _TeamSelectionFutureState();
}

class _TeamSelectionFutureState extends State<TeamSelectionFuture> {
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

    return result.mapQueryResult((data) =>
        data.mapNullable<List<LightTeam>>((team) =>
            (team['team'] as List<dynamic>)
                .map((final dynamic e) => LightTeam(
                    e['id'] as int, e['number'] as int, e['name'] as String))
                .toList()) ??
        []);
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
              typeAheadController: widget.controller,
              teams: snapshot.data as List<LightTeam>,
              onChange: (LightTeam) {
                setState(() {
                  widget.onChange(LightTeam);
                });
              },
            );
          }
        });
  }
}
