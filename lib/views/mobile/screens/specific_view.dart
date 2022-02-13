import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";

import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/specific_vars.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";

class Specific extends StatefulWidget {
  @override
  State<Specific> createState() => _SpecificState();
}

class _SpecificState extends State<Specific> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController teamSelectionController = TextEditingController();
  final SpecificVars vars = SpecificVars();
  final FocusNode node = FocusNode();
  Map<int, int> indexToId() => <int, int>{
        0: IdProvider.of(context).robotRole.nameToId["Upper shooter"]!,
        1: IdProvider.of(context).robotRole.nameToId["Lower shooter"]!,
        2: IdProvider.of(context).robotRole.nameToId["Defender"]!,
        3: IdProvider.of(context).robotRole.nameToId["Misc"]!
      };
  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: node.unfocus,
      child: Scaffold(
        drawer: SideNavBar(),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Specific"),
        ),
        body: Padding(
          padding: EdgeInsets.all(14),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(14)),
                  TeamSelectionFuture(
                    onChange: (final LightTeam team) {
                      vars.teamId = team.id;
                    },
                    controller: teamSelectionController,
                  ),
                  SizedBox(height: 14.0),
                  TextField(
                    focusNode: node,
                    textDirection: TextDirection.rtl,
                    controller: messageController,
                    onChanged: (final String text) {
                      vars.message = text;
                    },
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 4.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 4.0),
                      ),
                      fillColor: secondaryColor,
                      filled: true,
                    ),
                    maxLines: 18,
                  ),
                  SizedBox(height: 14),
                  FormField<int>(
                    initialValue: null,
                    validator: (final int? value) {
                      return vars.roleId.onNull("Pick an option");
                    },
                    builder: (final FormFieldState<int> state) => Column(
                      children: <Widget>[
                        Switcher(
                          labels: <String>[
                            "Upper shooter",
                            "Lower shooter",
                            "Defender",
                            "Misc"
                          ],
                          colors: <Color>[
                            Colors.green,
                            Colors.yellow,
                            Colors.deepPurple,
                            Colors.indigoAccent
                          ],
                          onChange: (final int index) {
                            state.didChange(index);
                            setState(() {
                              vars.roleId = indexToId()[index];
                            });
                          },
                          selected: <int, int>{
                                for (MapEntry<int, int> entry
                                    in indexToId().entries)
                                  entry.value: entry.key
                              }[vars.roleId] ??
                              -1,
                        ),
                        if (state.hasError)
                          Text(
                            state.errorText!,
                            style: TextStyle(color: Colors.red),
                          )
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SubmitButton(
                      validate: () => formKey.currentState!.validate(),
                      resetForm: () {
                        setState(() {
                          vars.reset();
                          teamSelectionController.clear();
                          messageController.clear();
                        });
                      },
                      mutation:
                          """mutation MyMutation (\$team_id: Int, \$message: String, \$robot_role_id: Int){
                  insert_specific(objects: {team_id: \$team_id, message: \$message, robot_role_id: \$robot_role_id}) {
                    returning {
                  team_id
                  message
                    }
                  }
                  }
                      """,
                      vars: vars,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
