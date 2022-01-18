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
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class FireBaseSubmitButton extends StatefulWidget {
  FireBaseSubmitButton({
    required this.vars,
    required this.mutation,
    required this.getResult,
    this.resetForm = empty,
  });
  final HasuraVars vars;
  final String mutation;
  final void Function() resetForm;
  final FilePickerResult? Function() getResult;

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
              builder: (final BuildContext context) {
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

        final int? teamid =
            widget.vars.toHasuraVars(context)["team_id"] as int?;
        final FilePickerResult? file = widget.getResult();

        if (teamid == null || file == null) {
          setState(() {
            if (teamid == null && file == null) {
              errorMessage = "Pick a Team and File";
            } else {
              errorMessage = teamid == null ? "Pick a Team" : "Pick a File";
            }
            _state = ButtonState.fail;
          });

          Future<void>.delayed(
            Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
          return;
        } else {
          uploadResult(
            teamid,
            file,
          );
        }
      },
    );
  }

  void uploadResult(final int teamid, final FilePickerResult result) {
    final Reference ref = FirebaseStorage.instance
        .ref("/files/$teamid.${result.files.first.extension}");

    final UploadTask firebaseTask = kIsWeb
        ? ref.putData(result.files.first.bytes!)
        : Platform.isAndroid
            ? ref.putFile(File(result.files.first.path!))
            : throw PlatformException(
                code: "This error shouldn't happen but better safe than sorry",
              );

    bool running = true;

    firebaseTask.snapshotEvents.listen((final TaskSnapshot event) async {
      if (event.state == TaskState.running && running) {
        setState(() {
          _state = ButtonState.loading;
        });
        running = false;
      } else if (event.state == TaskState.success) {
        final Map<String, dynamic> vars =
            Map<String, dynamic>.from(widget.vars.toHasuraVars(context));
        final String url = await ref.getDownloadURL();
        vars["url"] = url;

        final GraphQLClient client = getClient();

        final QueryResult graphqlQueryResult = await client.mutate(
          MutationOptions(document: gql(widget.mutation), variables: vars),
        );

        if (graphqlQueryResult.hasException) {
          ref.delete();
          setState(() {
            _state = ButtonState.fail;
            errorMessage = "Error";
          });

          graphqlErrorMessage = graphqlQueryResult.exception.toString();

          Future<void>.delayed(
            Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
        } else {
          widget.resetForm();
          setState(() {
            _state = ButtonState.success;
          });
          Future<void>.delayed(
            Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
        }
      } else if (event.state == TaskState.error) {
        setState(() {
          _state = ButtonState.fail;
          errorMessage = "error";
          graphqlErrorMessage = "Firebase error";
          Future<void>.delayed(
            Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
        });
      }
    });
  }
}
