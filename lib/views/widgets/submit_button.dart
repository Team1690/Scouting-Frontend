import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class SubmitButton extends StatefulWidget {
  final Function onPressed;

  const SubmitButton({this.onPressed, Key key}) : super(key: key);

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

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
      onPressed: () {
        widget.onPressed();
        switch (_state) {
          case ButtonState.idle:
            setState(() {
              _state = ButtonState.loading;
            });
            // FutureBuilder(
            //   future: widget.futureResponse,
            //   builder: (context, snapshot) {
            //     print(snapshot.data);
            //     if (snapshot.hasError) {
            //       setState(() {
            //         _state = ButtonState.fail;
            //       });
            //     }
            //     if (snapshot.hasData) {
            //       setState(() {
            //         _state = ButtonState.success;
            //       });
            //     }
            //   },
            // );
            Future.delayed(
              Duration(seconds: 1),
              () => setState(() => _state = ButtonState.success
                  // _state = Random.secure().nextDouble() < 0.65 // 65% seccuss
                  //     ? ButtonState.success
                  //     : ButtonState.fail,
                  ),
            );
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
