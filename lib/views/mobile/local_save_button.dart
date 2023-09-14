import "dart:convert";

import "package:flutter/material.dart";
import "package:progress_state_button/iconed_button.dart";
import "package:progress_state_button/progress_button.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:shared_preferences/shared_preferences.dart";

class LocalSaveButton extends StatefulWidget {
  LocalSaveButton({
    required this.vars,
    required this.mutation,
    required this.resetForm,
    required this.validate,
  });
  final bool Function() validate;
  final Match vars;
  final String mutation;
  final void Function() resetForm;

  @override
  State<LocalSaveButton> createState() => _LocalSaveButtonState();
}

class _LocalSaveButtonState extends State<LocalSaveButton> {
  ButtonState _state = ButtonState.idle;
  String _errorMessage = "";
  @override
  Widget build(final BuildContext context) => ProgressButton.icon(
        iconedButtons: <ButtonState, IconedButton>{
          ButtonState.idle: IconedButton(
            text: "Save",
            icon: const Icon(Icons.save, color: Colors.white),
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
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            "SM${widget.vars.scheduleMatch!.matchNumber}_RM${widget.vars.isRematch}_T${widget.vars.scoutedTeam!.number}",
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
        },
        state: _state,
      );
}
