import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget_future.dart";

class PickListScreen extends StatefulWidget {
  @override
  State<PickListScreen> createState() => _PickListScreenState();
}

class _PickListScreenState extends State<PickListScreen> {
  List<PickListTeam> teams = <PickListTeam>[];

  @override
  void dispose() {
    saveWithoutSnackbar(teams);
    super.dispose();
  }

  CurrentPickList currentScreen = CurrentPickList.first;
  @override
  Widget build(final BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: <Widget>[
            Expanded(
              child: DashboardCard(
                titleWidgets: <Widget>[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentScreen = currentScreen.nextScreen();
                      });
                    },
                    icon: Icon(Icons.swap_horiz),
                  ),
                  IconButton(
                    onPressed: () =>
                        save(context, List<PickListTeam>.from(teams)),
                    icon: Icon(Icons.save),
                  ),
                  IconButton(
                    onPressed: () => setState(() {}),
                    icon: Icon(Icons.refresh),
                  )
                ],
                title: currentScreen.title,
                body: PickListFuture(
                  onReorder: (final List<PickListTeam> list) => teams = list,
                  screen: currentScreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void saveWithoutSnackbar(final List<PickListTeam> teams) {
    final GraphQLClient client = getClient();
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

    final Map<String, dynamic> vars = <String, dynamic>{
      "objects": teams
          .map(
            (final PickListTeam e) => <String, dynamic>{
              "id": e.team.id,
              "name": e.team.name,
              "number": e.team.number,
              "first_picklist_index": e.firstListIndex,
              "second_picklist_index": e.secondListIndex,
              "taken": e.controller.value
            },
          )
          .toList()
    };

    client.mutate(MutationOptions(document: gql(query), variables: vars));
  }

  static void save(
    final BuildContext context,
    final List<PickListTeam> teams,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Saving", style: TextStyle(color: Colors.white))
          ],
        ),
        backgroundColor: Colors.blue,
      ),
    );
    final GraphQLClient client = getClient();
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

    final Map<String, dynamic> vars = <String, dynamic>{
      "objects": teams
          .map(
            (final PickListTeam e) => <String, dynamic>{
              "id": e.team.id,
              "name": e.team.name,
              "number": e.team.number,
              "first_picklist_index": e.firstListIndex,
              "second_picklist_index": e.secondListIndex,
              "taken": e.controller.value
            },
          )
          .toList()
    };

    final QueryResult result = await client
        .mutate(MutationOptions(document: gql(query), variables: vars));
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Error: ${result.exception}"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Saved",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

enum CurrentPickList { first, second }

extension CurrentPickListExtension on CurrentPickList {
  T map<T>(final T Function() onFirst, final T Function() onSecond) {
    switch (this) {
      case CurrentPickList.first:
        return onFirst();
      case CurrentPickList.second:
        return onSecond();
    }
  }

  String get title =>
      name[0].toUpperCase() + name.substring(1).toLowerCase() + " Picklist";

  CurrentPickList nextScreen() =>
      map(() => CurrentPickList.second, () => CurrentPickList.first);

  int getIndex(final PickListTeam team) =>
      map(() => team.firstListIndex, () => team.secondListIndex);

  int setIndex(final PickListTeam team, final int index) => map(
        () => team.firstListIndex = index,
        () => team.secondListIndex = index,
      );
}
