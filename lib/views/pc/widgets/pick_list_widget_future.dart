import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/pc/pick_list_screen.dart';
import 'package:scouting_frontend/views/pc/widgets/pick_list_widget.dart';

class PickListFuture extends StatefulWidget {
  const PickListFuture({Key key, @required this.screen, this.onReorder})
      : super(key: key);

  final CurrentScreen screen;
  final Function(List<PickListTeam> list) onReorder;
  @override
  _PickListFutureState createState() => _PickListFutureState();
}

class _PickListFutureState extends State<PickListFuture> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchTeams(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          widget.onReorder(snapshot.data);
          return PickList(
            onReorder: widget.onReorder,
            uiList: snapshot.data,
            screen: widget.screen,
          );
        });
  }

  Future<List<PickListTeam>> fetchTeams() async {
    final client = getClient();
    final String query = """
    query MyQuery {
  team {
    taken
    second_picklist_index
    first_picklist_index
    id
    name
    number
  }
}

    """;
    final result = await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) {
      throw Exception('Grapgql error ${result.exception}');
    }
    List<PickListTeam> teams =
        (result.data["team"] as List<dynamic>).map<PickListTeam>((e) {
      var team = PickListTeam(e['id'], e['number'], e['name'],
          e['first_picklist_index'], e['second_picklist_index'], e['taken']);
      return team;
    }).toList();

    switch (widget.screen) {
      case CurrentScreen.FIRST:
        teams.sort((team1, team2) {
          return team1.firstListIndex.compareTo(team2.firstListIndex);
        });
        break;
      case CurrentScreen.SECOND:
        teams.sort((team1, team2) {
          return team1.secondListIndex.compareTo(team2.secondListIndex);
        });
        break;
    }

    return teams;
  }
}
