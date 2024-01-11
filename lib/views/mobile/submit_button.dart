import "dart:convert";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/services.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/views/mobile/manage_preferences.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:progress_state_button/iconed_button.dart";
import "package:progress_state_button/progress_button.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "dart:developer" as developer;

class SubmitButton extends StatefulWidget {
  SubmitButton({
    required this.getJson,
    required this.mutation,
    required this.resetForm,
    required this.validate,
    this.onSubmissionSuccess,
    this.vars,
  });
  final bool Function() validate;
  final Map<String, dynamic> Function() getJson;
  final String mutation;
  final void Function() resetForm;
  final void Function()? onSubmissionSuccess;
  final Match? vars;

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  Connectivity connectivity = Connectivity();
  bool isOffline = true;
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
          ),
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
              if (mounted) {
                setState(() {
                  _state = ButtonState.idle;
                });
              }
            });
            return;
          }
          if (_state == ButtonState.loading) {
            return;
          }
          setState(() {
            _state = ButtonState.loading;
          });

          if (widget.vars != null && (await getConnectivity() ?? false)) {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setString(
              "M${widget.vars!.scheduleMatch!.matchNumber}_RM${widget.vars!.isRematch}_T${widget.vars!.scoutedTeam!.number}",
              jsonEncode(widget.vars),
            );
            widget.resetForm();
            setState(() {
              _state = ButtonState.success;
            });
            Future<void>.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  _state = ButtonState.idle;
                });
              }
            });
          } else {
            (await showDialog(
              context: context,
              builder: (final BuildContext dialogContext) =>
                  ManagePreferences(mutation: widget.mutation),
            ));

            final GraphQLClient client = getClient();
            final QueryResult<void> queryResult = await client.mutate(
              MutationOptions<void>(
                document: gql(widget.mutation),
                variables: widget.getJson(),
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
              widget.onSubmissionSuccess?.call();
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
          }
        },
        state: _state,
      );

  Future<bool?> getConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log("Couldn't check connectivity status", error: e);
      return null;
    }

    await updateConnectionStatus(result);
    return isOffline;
  }

  Future<void> updateConnectionStatus(final ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      isOffline = true;
    } else {
      isOffline = false;
    }
  }
}
