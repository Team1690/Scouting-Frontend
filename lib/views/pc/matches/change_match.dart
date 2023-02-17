import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/selector.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/pc/matches/matches_vars.dart";

class ChangeMatch extends StatefulWidget {
  const ChangeMatch([this.initialVars]);
  final ScheduleMatch? initialVars;
  @override
  State<ChangeMatch> createState() => _ChangeMatchState();
}

class _ChangeMatchState extends State<ChangeMatch> {
  late MatchesVars vars =
      widget.initialVars.mapNullable(MatchesVars.fromScheduleMatch) ??
          MatchesVars();
  List<void Function()> resetControllers =
      List<void Function()>.filled(8, () {});
  final GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController(
      text: widget.initialVars == null ? null : vars.matchNumber.toString(),
    );
    final ScheduleMatch? initialVars = widget.initialVars;
    if (initialVars == null) {
      return;
    }
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
        width: 100,
        height: double.infinity,
        child: AlertDialog(
          title: Text("Add Match"),
          content: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    labelText: "Enter match number",
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  onChanged: ((final String value) {
                    vars.matchNumber = int.tryParse(value);
                  }),
                  validator: (final String? value) =>
                      vars.matchNumber.onNull("Please pick a match number"),
                ),
                SizedBox(
                  height: 20,
                ),
                Selector<int>(
                  options:
                      IdProvider.of(context).matchType.idToName.keys.toList(),
                  placeholder: "Enter match type",
                  value: vars.matchTypeId,
                  makeItem: (final int p0) =>
                      IdProvider.of(context).matchType.idToName[p0]!,
                  onChange: (final int p0) {
                    vars.matchTypeId = p0;
                  },
                  validate: (final int p0) => null,
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 300,
                        height: double.infinity,
                        child: ListView(
                          children: <Widget>[
                            SectionDivider(label: "Blue Teams"),
                            TeamSelectionFuture(
                              buildWithTeam: (
                                final BuildContext context,
                                final LightTeam team,
                                final Widget searchBox,
                                final void Function() resetTeam,
                              ) {
                                resetControllers[0] = resetTeam;
                                vars.blue0 = team;
                                return searchBox;
                              },
                            ),
                            TeamSelectionFuture(
                              buildWithTeam: (
                                final BuildContext context,
                                final LightTeam team,
                                final Widget searchBox,
                                final void Function() resetTeam,
                              ) {
                                resetControllers[1] = resetTeam;
                                vars.blue1 = team;
                                return searchBox;
                              },
                            ),
                            TeamSelectionFuture(
                              buildWithTeam: (
                                final BuildContext context,
                                final LightTeam team,
                                final Widget searchBox,
                                final void Function() resetTeam,
                              ) {
                                resetControllers[2] = resetTeam;
                                vars.blue2 = team;
                                return searchBox;
                              },
                            ),
                            SectionDivider(label: "Blue Sub Team"),
                            TeamSelectionFuture(
                              dontValidate: true,
                              buildWithTeam: (
                                final BuildContext context,
                                final LightTeam team,
                                final Widget searchBox,
                                final void Function() resetTeam,
                              ) {
                                resetControllers[3] = resetTeam;
                                vars.blue3 = team;
                                return Column(
                                  children: <Widget>[
                                    searchBox,
                                    ElevatedButton(
                                      onPressed: resetTeam,
                                      child: Text("Clear"),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        height: double.infinity,
                        child: ListView(
                          children: <Widget>[
                            SectionDivider(label: "Red Teams"),
                            TeamSelectionFuture(
                              buildWithTeam: (
                                final BuildContext context,
                                final LightTeam team,
                                final Widget searchBox,
                                final void Function() resetTeam,
                              ) {
                                resetControllers[4] = resetTeam;
                                vars.red0 = team;
                                return searchBox;
                              },
                            ),
                            TeamSelectionFuture(
                              buildWithTeam: (
                                final BuildContext context,
                                final LightTeam team,
                                final Widget searchBox,
                                final void Function() resetTeam,
                              ) {
                                resetControllers[5] = resetTeam;
                                vars.red1 = team;
                                return searchBox;
                              },
                            ),
                            TeamSelectionFuture(
                              buildWithTeam: (
                                final BuildContext context,
                                final LightTeam team,
                                final Widget searchBox,
                                final void Function() resetTeam,
                              ) {
                                resetControllers[6] = resetTeam;
                                vars.red2 = team;
                                return searchBox;
                              },
                            ),
                            SectionDivider(label: "Red Sub Team"),
                            TeamSelectionFuture(
                              dontValidate: true,
                              buildWithTeam: (
                                final BuildContext context,
                                final LightTeam team,
                                final Widget searchBox,
                                final void Function() resetTeam,
                              ) {
                                resetControllers[7] = resetTeam;
                                vars.red3 = team;
                                return Column(
                                  children: <Widget>[
                                    searchBox,
                                    ElevatedButton(
                                      onPressed: resetTeam,
                                      child: Text("Clear"),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ToggleButtons(
                  fillColor: Color.fromARGB(10, 244, 67, 54),
                  selectedColor: Colors.blue,
                  selectedBorderColor: Colors.blue,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Happened"),
                    )
                  ],
                  isSelected: <bool>[vars.happened],
                  onPressed: (final int i) {
                    setState(() {
                      vars.happened = !vars.happened;
                    });
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                SubmitButton(
                  vars: vars,
                  mutation: widget.initialVars == null ? mutation : update,
                  resetForm: () => resetControllers
                    ..forEach((final void Function() resetController) {
                      resetController();
                    }),
                  validate: () => formKey.currentState!.validate(),
                ),
              ],
            ),
          ),
        ),
      );
}

const String mutation = r"""
mutation InsertMatch($match: matches_insert_input!){
  insert_matches_one(object: $match){
    id
  }
}
""";

const String update = """
mutation UpdateMatch(\$id: Int!,\$match:matches_set_input!){
  update_matches_by_pk(_set:\$match, pk_columns:{id:\$id}){
  	id
  }
}

""";
