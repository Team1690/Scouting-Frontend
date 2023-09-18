import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:image_picker/image_picker.dart";
import "package:progress_state_button/iconed_button.dart";
import "package:progress_state_button/progress_button.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class FireBaseSubmitButton extends StatefulWidget {
  FireBaseSubmitButton({
    required this.vars,
    required this.mutation,
    required this.getResult,
    required this.resetForm,
    required this.validate,
  });
  final HasuraVars vars;
  final String mutation;
  final bool Function() validate;
  final void Function() resetForm;
  final XFile? Function() getResult;

  @override
  State<FireBaseSubmitButton> createState() => _FireBaseSubmitButtonState();
}

class _FireBaseSubmitButtonState extends State<FireBaseSubmitButton> {
  ButtonState _state = ButtonState.idle;
  String errorMessage = "";
  String graphqlErrorMessage = "";

  @override
  Widget build(final BuildContext context) => ProgressButton.icon(
        iconedButtons: <ButtonState, IconedButton>{
          ButtonState.idle: IconedButton(
            text: "Submit",
            icon: const Icon(Icons.send, color: Colors.white),
            color: Colors.blue[400]!,
          ),
          ButtonState.loading: IconedButton(
            text: "Loading",
            color: Colors.blue[400]!,
          ),
          ButtonState.fail: IconedButton(
            text: errorMessage,
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
                builder: (final BuildContext context) => Scaffold(
                  appBar: AppBar(
                    title: const Text("Error message"),
                  ),
                  body: Center(
                    child: Text(graphqlErrorMessage),
                  ),
                ),
              ),
            );
            return;
          }

          if (!widget.validate()) {
            setState(() {
              errorMessage = "Input Error";
              _state = ButtonState.fail;
            });

            Future<void>.delayed(
              const Duration(seconds: 5),
              () => setState((() => _state = ButtonState.idle)),
            );
            return;
          } else {
            final int? teamid = widget.vars.toHasuraVars()["team_id"] as int?;
            final XFile? file = widget.getResult();
            uploadResult(
              teamid!,
              file!,
            );
          }
        },
      );

  void uploadResult(final int teamid, final XFile result) async {
    final int a = result.name.lastIndexOf(".");
    final String ext = result.name.substring(a + 1);
    final Reference ref = FirebaseStorage.instance.ref("/files/$teamid.$ext");

    final UploadTask firebaseTask = ref.putData(await result.readAsBytes());

    bool running = true;

    firebaseTask.snapshotEvents.listen((final TaskSnapshot event) async {
      if (event.state == TaskState.running && running) {
        setState(() {
          _state = ButtonState.loading;
        });
        running = false;
      } else if (event.state == TaskState.success) {
        final Map<String, dynamic> vars =
            Map<String, dynamic>.from(widget.vars.toHasuraVars());
        final String url = await ref.getDownloadURL();
        vars["url"] = url;

        final GraphQLClient client = getClient();

        final QueryResult<void> graphqlQueryResult = await client.mutate(
          MutationOptions<void>(
            document: gql(widget.mutation),
            variables: vars,
          ),
        );

        if (graphqlQueryResult.hasException) {
          await ref.delete();
          setState(() {
            _state = ButtonState.fail;
            errorMessage = "Error";
          });

          graphqlErrorMessage = graphqlQueryResult.exception.toString();

          Future<void>.delayed(
            const Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
        } else {
          widget.resetForm();
          setState(() {
            _state = ButtonState.success;
          });
          Future<void>.delayed(
            const Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
        }
      } else if (event.state == TaskState.error) {
        setState(() {
          _state = ButtonState.fail;
          errorMessage = "error";
          graphqlErrorMessage = "Firebase error";
          Future<void>.delayed(
            const Duration(seconds: 5),
            () => setState((() => _state = ButtonState.idle)),
          );
        });
      }
    });
  }
}
