import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view.dart";

class DeleteFault extends StatelessWidget {
  const DeleteFault({required this.faultId, required this.onFinished});
  final int faultId;
  final void Function(QueryResult) onFinished;

  @override
  Widget build(final BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () async {
        showLoadingSnackBar(context);
        final QueryResult result = await deleteFault(faultId);
        onFinished(result);
      },
    );
  }
}

Future<QueryResult> deleteFault(final int id) async {
  return getClient().mutate(
    MutationOptions(
      document: gql(_deleteFaultMutaton),
      variables: <String, dynamic>{"id": id},
    ),
  );
}

const String _deleteFaultMutaton = """
mutation MyMutation(\$id: Int) {
  delete_faults(where: {id: {_eq: \$id}}) {
    affected_rows
  }
}
""";