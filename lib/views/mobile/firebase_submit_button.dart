// ignore_for_file: always_specify_types

import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:graphql/client.dart";
import "package:progress_state_button/iconed_button.dart";
import "package:progress_state_button/progress_button.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class FireBaseSubmitButton extends StatefulWidget {
  FireBaseSubmitButton({
    final Key? key,
    required this.vars,
    required this.mutation,
    required this.result,
    final void Function()? resetForm,
  }) : super(key: key) {
    this.resetForm = resetForm ?? () {};
  }
  final HasuraVars vars;
  final String mutation;
  late final void Function() resetForm;
  final FilePickerResult? Function() result;

  @override
  State<FireBaseSubmitButton> createState() => _FireBaseSubmitButtonState();
}

class _FireBaseSubmitButtonState extends State<FireBaseSubmitButton> {
  ButtonState _state = ButtonState.idle;
  String errorMessage = "";
  String graphqlErrorMessage = "";

  @override
  Widget build(final BuildContext context) {
    return ProgressButton.icon(
      iconedButtons: {
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
          text: errorMessage,
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
      onPressed: () {
        if (_state == ButtonState.loading) return;

        if (_state == ButtonState.fail) {
          setState(() {
            _state = ButtonState.idle;
          });

          Navigator.push(
            context,
            MaterialPageRoute<Scaffold>(
              builder: (final context) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text("Error message"),
                  ),
                  body: Center(
                    child: Text(graphqlErrorMessage),
                  ),
                );
              },
            ),
          );
          return;
        }
        uploadResult(
          widget.vars.toHasuraVars()["team_id"] as int?,
          widget.result(),
        );
      },
    );
  }

  void uploadResult(final int? teamid, final FilePickerResult? result) {
    if (teamid == null || result == null) {
      setState(() {
        if (teamid == null && result == null) {
          errorMessage = "Pick a Team and File";
        } else {
          errorMessage = teamid == null ? "Pick a Team" : "Pick a File";
        }
        _state = ButtonState.fail;
      });

      Future.delayed(
        Duration(seconds: 5),
        () => setState((() => _state = ButtonState.idle)),
      );
      return;
    }

    final Reference ref = FirebaseStorage.instance
        .ref("/files/$teamid.${result.files.first.extension}");

    final UploadTask? firebaseTask = kIsWeb
        ? ref.putData(result.files.first.bytes!)
        : Platform.isAndroid
            ? ref.putFile(File(result.files.first.path!))
            : null;

    if (firebaseTask == null) {
      //this error will only happen if you run the app on a platform which is not web or android and i dont think you can do that
      throw PlatformException(code: "");
    }

    bool running = true;

    firebaseTask.snapshotEvents.listen((final event) async {
      if (event.state == TaskState.running && running) {
        setState(() {
          _state = ButtonState.loading;
        });
        running = false;
      } else if (event.state == TaskState.success) {
        final Map<String, dynamic> vars =
            Map<String, dynamic>.from(widget.vars.toHasuraVars());
        final url = await ref.getDownloadURL();
        vars["url"] = url;

        final client = getClient();

        final graphqlQueryResult = await client.mutate(
          MutationOptions(document: gql(widget.mutation), variables: vars),
        );

        if (graphqlQueryResult.hasException) {
          ref.delete();
          setState(() {
            _state = ButtonState.fail;
            errorMessage = "Error";
          });

          graphqlErrorMessage = graphqlQueryResult.exception.toString();

          Future.delayed(
            Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
        } else {
          widget.resetForm();
          setState(() {
            _state = ButtonState.success;
          });
          Future.delayed(
            Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
        }
      } else if (event.state == TaskState.error) {
        setState(() {
          _state = ButtonState.fail;
          errorMessage = "error";
          graphqlErrorMessage = "Firebase error";
          Future.delayed(
            Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
        });
      }
    });
  }
}
