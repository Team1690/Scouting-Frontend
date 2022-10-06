import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view.dart";

class EditFault extends StatelessWidget {
  const EditFault({
    required this.faultMessage,
    required this.faultId,
    required this.onFinished,
  });
  final String faultMessage;
  final int faultId;
  final void Function(QueryResult<void>) onFinished;
  @override
  Widget build(final BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () async {
        final TextEditingController controller = TextEditingController();
        controller.text = faultMessage;
        (await showDialog<String>(
          context: context,
          builder: (final BuildContext context) => AlertDialog(
            title: Text("Edit message"),
            content: TextField(
              maxLines: 4,
              controller: controller,
              autofocus: true,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: "Error message",
              ),
            ),
            actions: <TextButton>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop<String>(
                    controller.text,
                  );
                },
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              )
            ],
          ),
        ))
            .mapNullable((
          final String message,
        ) async {
          showLoadingSnackBar(context);
          final QueryResult<void> result = await updateFaultMessage(
            faultId,
            message,
          );
          onFinished(result);
        });
      },
    );
  }
}

Future<QueryResult<void>> updateFaultMessage(
  final int id,
  final String message,
) async {
  return getClient().mutate(
    MutationOptions<void>(
      document: gql(updateMessage),
      variables: <String, dynamic>{"id": id, "message": message},
    ),
  );
}

const String updateMessage = """
mutation UpdateFaultMessage(\$id: Int, \$message: String) {
  update_faults(where: {id: {_eq: \$id}}, _set: {message: \$message}) {
    affected_rows
  }
}
""";
