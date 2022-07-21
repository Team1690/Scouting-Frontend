import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/pc/picklist/fetch_picklist.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";
import "package:scouting_frontend/views/pc/picklist/picklist_card.dart";

class PickListScreen extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return isPC(context)
        ? DashboardScaffold(
            body: pickList(context),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("Picklist"),
              centerTitle: true,
            ),
            drawer: SideNavBar(),
            body: pickList(context),
          );
  }

  Padding pickList(final BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(defaultPadding),
      child: StreamBuilder<List<PickListTeam>>(
        stream: fetchPicklist(),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<PickListTeam>> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null) {
            return Center(
              child: Text("No Teams"),
            );
          }
          return PicklistCard(initialData: snapshot.data!);
        },
      ),
    );
  }
}

void save(
  final List<PickListTeam> teams, [
  final BuildContext? context,
]) async {
  if (context != null) {
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
  }
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
            "colors_index": e.team.colorsIndex,
            "first_picklist_index": e.firstListIndex,
            "second_picklist_index": e.secondListIndex,
            "taken": e.taken
          },
        )
        .toList()
  };

  final QueryResult<void> result = await client
      .mutate(MutationOptions<void>(document: gql(query), variables: vars));
  if (context != null) {
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
      "${name[0].toUpperCase()}${name.substring(1).toLowerCase()} Picklist";

  CurrentPickList nextScreen() =>
      map(() => CurrentPickList.second, () => CurrentPickList.first);

  int getIndex(final PickListTeam team) =>
      map(() => team.firstListIndex, () => team.secondListIndex);

  int setIndex(final PickListTeam team, final int index) => map(
        () => team.firstListIndex = index,
        () => team.secondListIndex = index,
      );
}
