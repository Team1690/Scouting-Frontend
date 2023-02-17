import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:progress_state_button/iconed_button.dart";
import "package:progress_state_button/progress_button.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class SubmitButton extends StatefulWidget {
  SubmitButton({
    required this.vars,
    required this.mutation,
    required this.resetForm,
    required this.validate,
  });
  final bool Function() validate;
  final HasuraVars vars;
  final String mutation;
  final void Function() resetForm;

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  ButtonState _state = ButtonState.idle;
  String _errorMessage = "";
  @override
  Widget build(final BuildContext context) => ProgressButton.icon(
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
          if (!widget.validate()) {
            setState(() {
              _state = ButtonState.fail;
              _errorMessage = "You forgot to enter some fields";
            });
            Future<void>.delayed(const Duration(seconds: 5), () {
              setState(() {
                _state = ButtonState.idle;
              });
            });
            return;
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
              variables: widget.vars.toHasuraVars(),
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
            widget.resetForm();
            setState(() {
              _state = ButtonState.success;
            });
          }
          Future<void>.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _state = ButtonState.idle;
              });
            }
          });
        },
        state: _state,
      );
}
