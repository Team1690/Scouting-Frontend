import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/match_dropdown.dart';
import 'package:scouting_frontend/views/mobile/submit_button.dart';
import 'package:scouting_frontend/views/mobile/teams_dropdown.dart';
import 'package:scouting_frontend/models/match_model.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

class Specific extends StatefulWidget {
  @override
  State<Specific> createState() => _SpecificState();
}

class _SpecificState extends State<Specific> {
  String _box;
  final TextEditingController box = TextEditingController();

  Match match = Match();

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(15)),
              FutureBuilder(
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
                          onChange: (LightTeam team) =>
                              {setState(() => match.teamId = team.id)});
                    }
                  }),
              Padding(padding: EdgeInsets.all(14.0)),
              TextField(
                controller: box,
                onChanged: (text) {
                  _box = text;
                },
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 14.0),
                  ),
                  fillColor: secondaryColor,
                  filled: true,
                ),
                maxLines: 18,
              ),
              Padding(padding: EdgeInsets.all(11.0)),
              Align(
                alignment: Alignment.bottomCenter,
                child: SubmitButton(
                  mutation:
                      """mutation MyMutation (\$team_id: Int, \$message: String){
  insert_specific(objects: {team_id: \$team_id, message: \$message}) {
    returning {
      team_id
      message
    }
  }
}
                  """,
                  vars: {
                    "team_id": match.teamId,
                    "message": this._box,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
