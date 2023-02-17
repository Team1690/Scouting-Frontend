import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view.dart";

class DeleteFault extends StatelessWidget {
  const DeleteFault({required this.faultId, required this.onFinished});
  final int faultId;
  final void Function(QueryResult<void>) onFinished;

  @override
  Widget build(final BuildContext context) => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          showLoadingSnackBar(context);
          final QueryResult<void> result = await deleteFault(faultId);
          onFinished(result);
        },
      );
}

Future<QueryResult<void>> deleteFault(final int id) async => getClient().mutate(
      MutationOptions<void>(
        document: gql(_deleteFaultMutaton),
        variables: <String, dynamic>{"id": id},
      ),
    );

const String _deleteFaultMutaton = """
mutation DeleteFault(\$id: Int) {
  delete_faults(where: {id: {_eq: \$id}}) {
    affected_rows
  }
}
""";
