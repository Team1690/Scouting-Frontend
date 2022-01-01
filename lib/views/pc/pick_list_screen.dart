import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/pick_list_widget.dart';
import 'package:scouting_frontend/views/pc/widgets/pick_list_widget_future.dart';

import '../constants.dart';

class PickListScreen extends StatefulWidget {
  @override
  State<PickListScreen> createState() => _PickListScreenState();
}

class _PickListScreenState extends State<PickListScreen> {
  List<PickListTeam> teams;
  CurrentScreen currentScreen = CurrentScreen.FIRST;
  @override
  Widget build(BuildContext context) {
    String title;
    switch (currentScreen) {
      case CurrentScreen.FIRST:
        title = 'First PickList';
        break;
      case CurrentScreen.SECOND:
        title = 'Second PickList';
        break;
    }
    return DashboardScaffold(
        body: Padding(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Expanded(
            child: DashboardCard(
                titleWidgets: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          switch (currentScreen) {
                            case CurrentScreen.FIRST:
                              currentScreen = CurrentScreen.SECOND;
                              break;
                            case CurrentScreen.SECOND:
                              currentScreen = CurrentScreen.FIRST;
                              break;
                          }
                        });
                      },
                      icon: Icon(Icons.arrow_upward)),
                  IconButton(
                    onPressed: save,
                    icon: Icon(Icons.save),
                  ),
                  IconButton(
                      onPressed: () => setState(() {}),
                      icon: Icon(Icons.refresh))
                ],
                title: title,
                body: PickListFuture(
                  onReorder: (list) => teams = list,
                  screen: currentScreen,
                )),
          ),
        ],
      ),
    ));
  }

  void save() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 5),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Saving', style: TextStyle(color: Colors.white))],
      ),
      backgroundColor: Colors.blue,
    ));
    final client = getClient();
    List<PickListTeam> teams = List.from(this.teams);
    final String query = """
  mutation M(\$objects: [team_insert_input!]!) {
  insert_team(objects: \$objects, on_conflict: {constraint: team_pkey, update_columns: [taken, first_picklist_index, second_picklist_index]}) {
    affected_rows
    returning {
      id
    }
  }
}

  """;

    Map<String, dynamic> vars = {
      "objects": teams
          .map((e) => {
                "id": e.id,
                "name": e.name,
                "number": e.number,
                "first_picklist_index": e.firstListIndex,
                "second_picklist_index": e.secondListIndex,
                "taken": e.controller.value
              })
          .toList()
    };

    QueryResult result = await client
        .mutate(MutationOptions(document: gql(query), variables: vars));
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 5),
        content: Text('Error: ${result.exception}'),
        backgroundColor: Colors.red,
      ));
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Saved',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        backgroundColor: Colors.green,
      ));
    }
  }
}

enum CurrentScreen { FIRST, SECOND }
