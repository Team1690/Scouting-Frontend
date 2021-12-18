import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/app.dart';
import 'package:scouting_frontend/views/mobile/FilePickerWidget.dart';

class FireBaseSubmitButton extends StatefulWidget {
  FireBaseSubmitButton(
      {Key key, this.vars, this.mutation, this.resetForm, this.result})
      : super(key: key);
  final Map<String, dynamic> vars;
  final String mutation;
  final Function() resetForm;
  final FilePickerResult Function() result;

  @override
  State<FireBaseSubmitButton> createState() => _FireBaseSubmitButtonState();
}

class _FireBaseSubmitButtonState extends State<FireBaseSubmitButton> {
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
          text: "Error",
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
      state: _state,
      onPressed: () =>
          uploadResult(widget.vars['team_id'] as int, this.widget.result()),
    );
  }

  void uploadResult(int teamid, FilePickerResult result) {
    if (teamid == null) {
      setState(() {
        _state = ButtonState.fail;
      });

      App.messengerKey.currentState.clearSnackBars();
      App.messengerKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Pick a Team',
            style: TextStyle(color: Colors.white),
          )));
      Future.delayed(Duration(seconds: 5),
          () => setState((() => _state = ButtonState.idle)));
      return;
    } else if (result == null) {
      setState(() {
        _state = ButtonState.fail;
      });

      App.messengerKey.currentState.clearSnackBars();
      App.messengerKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Pick a File!',
            style: TextStyle(color: Colors.white),
          )));
      Future.delayed(Duration(seconds: 5),
          () => setState((() => _state = ButtonState.idle)));
      return;
    }
    Reference ref = FirebaseStorage.instance
        .ref('/files/$teamid.${result.files.first.extension}');

    UploadTask task = kIsWeb
        ? ref.putData(result.files.first.bytes)
        : Platform.isAndroid
            ? ref.putFile(File(result.files.first.path))
            : null;

    if (task == null) {
      App.messengerKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'An Error Occurred',
            style: TextStyle(color: Colors.white),
          )));
      return;
    }
    TaskState lastState;
    task.snapshotEvents.listen((event) async {
      if (event.state == TaskState.running && event.state != lastState) {
        setState(() {
          _state = ButtonState.loading;
        });
        lastState = event.state;
      }
      if (event.state == TaskState.success) {
        Map<String, dynamic> vars = Map.from(this.widget.vars);
        var url = await ref.getDownloadURL();
        vars['url'] = url;

        final client = getClient();

        final queryResult = await client.mutate(
            MutationOptions(document: gql(widget.mutation), variables: vars));

        if (queryResult.hasException) {
          ref.delete();
          setState(() {
            _state = ButtonState.fail;
          });
          App.messengerKey.currentState.clearSnackBars();
          App.messengerKey.currentState.showSnackBar(SnackBar(
              duration: Duration(seconds: 5),
              backgroundColor: Colors.red,
              content: Text(
                'Upload Failed ' +
                    queryResult.exception.graphqlErrors.first.message,
                style: TextStyle(color: Colors.white),
              )));
        } else {
          widget.resetForm();
          setState(() {
            _state = ButtonState.success;
          });
          Future.delayed(Duration(seconds: 5),
              () => setState((() => _state = ButtonState.idle)));
        }
      }
    });
  }
}
