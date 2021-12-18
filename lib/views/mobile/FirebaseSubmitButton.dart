import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/app.dart';
import 'package:scouting_frontend/views/mobile/FilePickerWidget.dart';

class FireBaseSubmitButton extends StatelessWidget {
  FireBaseSubmitButton(
      {Key key, this.vars, this.mutation, this.resetForm, this.result})
      : super(key: key);
  final Map<String, dynamic> vars;
  final String mutation;
  final Function() resetForm;
  final FilePickerResult Function() result;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () => uploadResult(vars['team_id'] as int, this.result()),
        icon: Icon(Icons.send),
        label: Text('submit'));
  }

  void uploadResult(int teamid, FilePickerResult result) {
    if (result == null) {
      App.messengerKey.currentState.clearSnackBars();
      App.messengerKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Pick a File!',
            style: TextStyle(color: Colors.white),
          )));
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
        App.messengerKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 20),
            backgroundColor: Colors.blue,
            content: Text(
              'Uploading',
              style: TextStyle(color: Colors.white),
            )));
        lastState = event.state;
      }
      if (event.state == TaskState.success) {
        Map<String, dynamic> vars = Map.from(this.vars);
        var url = await ref.getDownloadURL();
        vars['url'] = url;

        final client = getClient();

        final queryResult = await client
            .mutate(MutationOptions(document: gql(mutation), variables: vars));

        if (queryResult.hasException) {
          ref.delete();
          App.messengerKey.currentState.clearSnackBars();
          App.messengerKey.currentState.showSnackBar(SnackBar(
              duration: Duration(seconds: 10),
              backgroundColor: Colors.red,
              content: Text(
                'Upload Failed ' +
                    queryResult.exception.graphqlErrors.first.message,
                style: TextStyle(color: Colors.white),
              )));
        } else {
          resetForm();

          App.messengerKey.currentState.clearSnackBars();
          App.messengerKey.currentState.showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Uploaded succsesfully',
                style: TextStyle(color: Colors.white),
              )));
        }
      }
    });
  }
}
