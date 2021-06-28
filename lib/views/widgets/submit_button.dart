import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class SubmitButton extends StatefulWidget {
  final Future<http.Response> Function() uploadData;

  const SubmitButton({this.uploadData, Key key}) : super(key: key);

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

// TODO implement the function to get the desired state
ButtonState getResponseState(final http.Response response) =>
    200 <= response.statusCode && response.statusCode < 300
        ? ButtonState.success
        : ButtonState.fail;

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
        switch (_state) {
          case ButtonState.idle:
            setState(() {
              _state = ButtonState.loading;
            });

            final response = await widget.uploadData();
            setState(() => _state = getResponseState(response));
            break;

          case ButtonState.fail:
          case ButtonState.success:
          default:
            setState(() => _state = ButtonState.idle);
            break;
        }
      },
      state: _state,
    );
  }
}
