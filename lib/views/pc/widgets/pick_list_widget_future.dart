import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/pick_list_screen.dart";
import "package:scouting_frontend/views/pc/widgets/pick_list_widget.dart";
import "package:scouting_frontend/models/map_nullable.dart";

class PickListFuture extends StatefulWidget {
  PickListFuture({required this.screen, this.onReorder = ignore});

  final CurrentPickList screen;
  final void Function(List<PickListTeam> list) onReorder;
  @override
  _PickListFutureState createState() => _PickListFutureState();
}

class _PickListFutureState extends State<PickListFuture> {
  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<List<PickListTeam>>(
      future: fetchTeams(),
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
        widget.onReorder(snapshot.data!);
        return PickList(
          onReorder: widget.onReorder,
          uiList: snapshot.data!,
          screen: widget.screen,
        );
      },
    );
  }

  Future<List<PickListTeam>> fetchTeams() async {
    final GraphQLClient client = getClient();
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
    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));

    final List<PickListTeam> teams = result.mapQueryResult(
      (final Map<String, dynamic>? data) =>
          data.mapNullable(
            (final Map<String, dynamic> pickListTeams) =>
                (pickListTeams["team"] as List<dynamic>)
                    .map(
                      (final dynamic e) => PickListTeam(
                        e["id"] as int,
                        e["number"] as int,
                        e["name"] as String,
                        e["first_picklist_index"] as int,
                        e["second_picklist_index"] as int,
                        e["taken"] as bool,
                      ),
                    )
                    .toList(),
          ) ??
          <PickListTeam>[],
    );

    teams.sort(
      (final PickListTeam left, final PickListTeam right) =>
          widget.screen.getIndex(left).compareTo(widget.screen.getIndex(right)),
    );
    return teams;
  }
}
