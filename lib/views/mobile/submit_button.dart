import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';

class SubmitButton extends StatefulWidget {
  final Map<String, dynamic> vars;
  final String mutation;
  final Function onPressed;

  const SubmitButton({this.vars, this.mutation, this.onPressed, Key key})
      : super(key: key);

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

// ButtonState getResponseState(final http.Response response) =>
//     200 == response.statusCode ? ButtonState.success : ButtonState.fail;

class _SubmitButtonState extends State<SubmitButton> {
  ButtonState _state = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
    return ProgressButton.icon(
      iconedButtons: {
        ButtonState.idle: IconedButton(
          text: "Submit",
          icon: Icon(Icons.send, color: Colors.white),
          color: Colors.blue[400],
        ),
        ButtonState.loading: IconedButton(
          text: "Loading",
          color: Colors.blue[400],
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
        final client = getClient();
        client.mutate(MutationOptions(
            document: gql(widget.mutation), variables: widget.vars));
      },
      state: _state,
    );
  }
}
