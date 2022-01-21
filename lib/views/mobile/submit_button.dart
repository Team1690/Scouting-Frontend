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
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  ButtonState _state = ButtonState.idle;
  String _errorMessage = "";
  @override
  Widget build(final BuildContext context) {
    return ProgressButton.icon(
      iconedButtons: <ButtonState, IconedButton>{
        ButtonState.idle: IconedButton(
          text: "Submit",
          icon: Icon(Icons.send, color: Colors.white),
          color: Colors.blue[400]!,
        ),
        ButtonState.loading: IconedButton(
          text: "Loading",
          color: Colors.blue[400]!,
        ),
        ButtonState.fail: IconedButton(
          text: "Failed",
          icon: Icon(Icons.cancel, color: Colors.white),
          color: Colors.red.shade300,
        ),
        ButtonState.success: IconedButton(
          text: "Success",
          icon: Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
          color: Colors.green.shade400,
        )
      },
      onPressed: () async {
        if (widget.validate() == false) return;
        if (_state == ButtonState.fail) {
          Navigator.push(
            context,
            MaterialPageRoute<Scaffold>(
              builder: (final BuildContext context) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text("Error message"),
                  ),
                  body: Center(
                    child: Text(_errorMessage),
                  ),
                );
              },
            ),
          );
        }
        if (_state == ButtonState.loading) return;
        setState(() {
          _state = ButtonState.loading;
        });
        final GraphQLClient client = getClient();
        final QueryResult queryResult = await client.mutate(
          MutationOptions(
            document: gql(widget.mutation),
            variables: widget.vars.toHasuraVars(context),
          ),
        );
        if (queryResult.hasException) {
          setState(() {
            _state = ButtonState.fail;
          });
          _errorMessage = queryResult.exception!.graphqlErrors.first.message;
        } else {
          widget.resetForm();
          setState(() {
            _state = ButtonState.success;
          });
        }
        Future<void>.delayed(Duration(seconds: 5), () {
          setState(() {
            _state = ButtonState.idle;
          });
        });
      },
      state: _state,
    );
  }
}
