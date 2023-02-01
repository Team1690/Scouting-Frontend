import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view.dart";

class AddFault extends StatelessWidget {
  const AddFault({required this.onFinished});
  final void Function(QueryResult<void>) onFinished;

  @override
  Widget build(final BuildContext context) {
    return IconButton(
      onPressed: () async {
        LightTeam? team;
        String? newMessage;
        (await showDialog<NewFault>(
          context: context,
          builder: (final BuildContext innerContext) {
            return AlertDialog(
              title: Text("Add team"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TeamSelectionFuture(
                    teams: TeamProvider.of(context).teams,
                    buildWithTeam:
                        (final BuildContext context, final LightTeam newTeam) {
                      team = newTeam;
                      return Container();
                    },
                    controller: TextEditingController(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    maxLines: 4,
                    textDirection: TextDirection.rtl,
                    onChanged: (final String a) {
                      newMessage = a;
                    },
                    decoration: InputDecoration(
                      hintText: "Error message",
                      border: OutlineInputBorder(),
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (team == null || newMessage == null) return;
                    Navigator.of(context).pop(NewFault(newMessage!, team!));
                  },
                  child: Text("Submit"),
                ),
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ))
            .mapNullable((final NewFault p0) async {
          showLoadingSnackBar(context);
          final QueryResult<void> result =
              await _addFault(p0.team.id, p0.message);
          onFinished(result);
        });
      },
      icon: Icon(Icons.add),
    );
  }
}

Future<QueryResult<void>> _addFault(final int teamId, final String message) {
  return getClient().mutate(
    MutationOptions<void>(
      document: gql(_addFaultMutation),
      variables: <String, dynamic>{"team_id": teamId, "fault_message": message},
    ),
  );
}

const String _addFaultMutation = """
mutation AddFault(\$team_id:Int,\$fault_message:String){
  insert_faults(objects: {team_id: \$team_id, message: \$fault_message}) {
    affected_rows
  }
}
""";
