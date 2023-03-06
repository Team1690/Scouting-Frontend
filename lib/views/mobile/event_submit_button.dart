import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:progress_state_button/iconed_button.dart";
import "package:progress_state_button/progress_button.dart";
import "package:scouting_frontend/models/event_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class EventSubmitButton extends StatefulWidget {
  EventSubmitButton({
    required this.vars,
    required this.mutation,
    required this.resetForm,
    required this.validate,
    required this.events,
    required this.isSpecific,
  });
  final bool Function() validate;
  final HasuraVars vars;
  final String mutation;
  final void Function() resetForm;
  final List<MatchEvent> events;
  final bool isSpecific;

  @override
  State<EventSubmitButton> createState() => _EventSubmitButtonState();
}

class _EventSubmitButtonState extends State<EventSubmitButton> {
  ButtonState _state = ButtonState.idle;
  String _errorMessage = "";
  String eventMutation = "";

  void validateResult(
    final OperationException? exception,
    final void Function() onSuccess,
  ) {
    if (exception != null) {
      setState(() {
        _state = ButtonState.fail;
      });
      final List<GraphQLError> errors = exception.graphqlErrors;
      final GraphQLError error = errors.first;
      _errorMessage = error.extensions?["code"]?.toString() ==
                  "constraint-violation" ||
              error.extensions?["code"]?.toString() == "Uniqueness violation"
          ? "That match already exists check if you scouted that correct robot/wrote the correct match"
          : error.message;
    } else {
      onSuccess();
    }
  }

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
          final QueryResult<int> queryResult = await client.mutate(
            MutationOptions<int>(
              document: gql(widget.mutation),
              variables: widget.vars.toHasuraVars(),
              parserFn: (final Map<String, dynamic> data) => data[
                      "insert__2023_${widget.isSpecific ? "specific" : "technical_match_v3"}"]
                  ["returning"][0]["id"] as int,
            ),
          );
          final OperationException? exception = queryResult.exception;
          if (widget.events.isNotEmpty) {
            final int id = queryResult.mapQueryResult();
            validateResult(exception, () async {
              for (final MatchEvent event in widget.events) {
                event.matchId = id;
              }
              eventMutation = """
mutation Events(\$objects: [${widget.isSpecific ? "_2023_specific_events_insert_input" : "_2023_new_technical_events_insert_input"}!]!) {
  ${widget.isSpecific ? "insert__2023_specific_events" : "insert__2023_new_technical_events"}(objects: \$objects) {
    affected_rows
  }
}
""";
              final QueryResult<void> eventsQueryResult = await client.mutate(
                MutationOptions<void>(
                  document: gql(eventMutation),
                  variables: <String, dynamic>{
                    "objects": widget.events
                        .map(
                          (final MatchEvent matchEvent) =>
                              matchEvent.toHasuraVars(),
                        )
                        .toList(),
                  },
                ),
              );
              final OperationException? eventException =
                  eventsQueryResult.exception;
              validateResult(eventException, () {
                widget.resetForm();
                setState(() {
                  _state = ButtonState.success;
                });
              });
            });
          } else {
            validateResult(exception, () {
              setState(() {
                widget.resetForm();
                _state = ButtonState.success;
              });
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
