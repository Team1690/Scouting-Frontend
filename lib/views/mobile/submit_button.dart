import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/mobile/hasura_vars.dart';

class SubmitButton extends StatefulWidget {
  final HasuraVars vars;
  final String mutation;
  final Function() resetForm;

  const SubmitButton({this.vars, this.mutation, this.resetForm, Key key})
      : super(key: key);

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

// ButtonState getResponseState(final http.Response response) =>
//     200 == response.statusCode ? ButtonState.success : ButtonState.fail;

class _SubmitButtonState extends State<SubmitButton> {
  ButtonState _state = ButtonState.idle;
  String _errorMessage = '';
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
        if (_state == ButtonState.fail) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Error message'),
              ),
              body: Center(
                child: Text(_errorMessage),
              ),
            );
          }));
        }
        if (_state == ButtonState.loading) return;
        setState(() {
          _state = ButtonState.loading;
        });
        final client = getClient();
        final queryResult = await client.mutate(MutationOptions(
            document: gql(widget.mutation),
            variables: widget.vars.toHasuraVars()));
        if (queryResult.hasException) {
          setState(() {
            _state = ButtonState.fail;
          });
          _errorMessage = queryResult.exception.graphqlErrors.first.message;
        } else {
          widget.resetForm();
          setState(() {
            _state = ButtonState.success;
          });
        }
        Future.delayed(Duration(seconds: 5), () {
          setState(() {
            _state = ButtonState.idle;
          });
        });
      },
      state: _state,
    );
  }
}
