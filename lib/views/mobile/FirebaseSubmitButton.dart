import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/app.dart';
import 'package:scouting_frontend/views/mobile/FilePickerWidget.dart';

class FireBaseSubmitButton extends StatelessWidget {
  FireBaseSubmitButton({Key key, this.vars, this.mutation, this.onPressed})
      : super(key: key);
  final Map<String, dynamic> vars;
  final String mutation;
  Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: uploadResult, icon: Icon(Icons.send), label: Text('submit'));
  }

  void uploadResult() {
    onPressed();

    if (FilePickerWidget.result == null) {
      App.mesengerKey.currentState.showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Pick a File!')));
      return;
    }
    Reference ref = FirebaseStorage.instance.ref(
        '/files/${DateTime.now()}.${FilePickerWidget.result.files.first.extension}');
    UploadTask task = kIsWeb
        ? ref.putData(FilePickerWidget.result.files.first.bytes)
        : Platform.isAndroid
            ? ref.putFile(File('${FilePickerWidget.result.files.first.path}'))
            : null;
    if (task == null) return;
    task.snapshotEvents.listen((event) async {
      if (event.state == TaskState.success) {
        var url = await ref.getDownloadURL();
        vars['url'] = url;
        FilePickerWidget.result = null;
        FilePickerWidget.controller.value = false;
        final client = getClient();
        client
            .mutate(MutationOptions(document: gql(mutation), variables: vars));
      }
    });
  }
}
