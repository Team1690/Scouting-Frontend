import "dart:convert";

import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:progress_state_button/iconed_button.dart";
import "package:progress_state_button/progress_button.dart";
import "package:scouting_frontend/net/hasura_helper.dart";

class SubmitJson extends StatefulWidget {
  SubmitJson({
    required this.mutation,
  });
  final String mutation;

  @override
  State<SubmitJson> createState() => _SubmitJsonState();
}

class _SubmitJsonState extends State<SubmitJson> {
  ButtonState _state = ButtonState.idle;
  String _errorMessage = "";
  String json = "";
  @override
  Widget build(final BuildContext context) => SizedBox(
      width: 100,
      child: AlertDialog(
          content: Form(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
            validator: (pastedString) =>
                pastedString == null || pastedString.isEmpty
                    ? "Please paste a code"
                    : null,
            onChanged: (pastedString) => setState(() {
                  json = pastedString;
                })),
        ProgressButton.icon(
          iconedButtons: <ButtonState, IconedButton>{
            ButtonState.idle: IconedButton(
              text: "Submit",
              icon: const Icon(Icons.send, color: Colors.white),
              color: Colors.blue[400]!,
            ),
            ButtonState.loading: IconedButton(
              text: "Loading",
              color: Colors.blue[400]!,
            ),
            ButtonState.fail: IconedButton(
              text: "Failed",
              icon: const Icon(Icons.cancel, color: Colors.white),
              color: Colors.red.shade300,
            ),
            ButtonState.success: IconedButton(
              text: "Success",
              icon: const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              color: Colors.green.shade400,
            )
          },
          onPressed: () async {
            if (_state == ButtonState.fail) {
              await Navigator.push(
                context,
                MaterialPageRoute<Scaffold>(
                  builder: (final BuildContext context) => Scaffold(
                    appBar: AppBar(
                      title: const Text("Error message"),
                    ),
                    body: Center(
                      child: Text(_errorMessage),
                    ),
                  ),
                ),
              );
            }
            try {
              jsonDecode(json) as Map<String, dynamic>;
            } on Exception {
              setState(() {
                _state = ButtonState.fail;
                _errorMessage = "That is not a valid code";
              });

              return;
            }
            if (json.isEmpty) {
              setState(() {
                _state = ButtonState.fail;
                _errorMessage = "You forgot to enter some fields";
              });
            }
            if (_state == ButtonState.loading) {
              return;
            }
            setState(() {
              _state = ButtonState.loading;
            });
            final GraphQLClient client = getClient();
            final QueryResult<void> queryResult = await client.mutate(
              MutationOptions<void>(
                document: gql(widget.mutation),
                variables: jsonDecode(json) as Map<String, dynamic>,
              ),
            );
            final OperationException? exception = queryResult.exception;
            if (exception != null) {
              setState(() {
                _state = ButtonState.fail;
              });
              final List<GraphQLError> errors = exception.graphqlErrors;
              if (errors.length == 1) {
                final GraphQLError error = errors.single;
                _errorMessage = error.extensions?["code"]?.toString() ==
                        "constraint-violation"
                    ? "That match already exisits check if you scouted that correct robot/wrote the correct match"
                    : error.message;
              } else {
                _errorMessage = errors.join(", ");
              }
            } else {
              setState(() {
                json = "";
                _state = ButtonState.success;
              });
            }
          },
          state: _state,
        )
      ]))));
}
