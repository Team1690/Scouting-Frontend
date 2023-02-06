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
  List<TextEditingController> teamControllers =
      List<TextEditingController>.generate(
    8,
    (final int i) => TextEditingController(),
  );
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

    teamControllers[0] = TextEditingController(
      text: initialVars.blueAlliance[0].number.toString(),
    );
    teamControllers[1] = TextEditingController(
      text: initialVars.blueAlliance[1].number.toString(),
    );
    teamControllers[2] = TextEditingController(
      text: initialVars.blueAlliance[2].number.toString(),
    );
    teamControllers[3] = TextEditingController(
      text: initialVars.blueAlliance.length == 4
          ? initialVars.blueAlliance[3].number.toString()
          : null,
    );
    teamControllers[4] = TextEditingController(
      text: initialVars.redAlliance[0].number.toString(),
    );
    teamControllers[5] = TextEditingController(
      text: initialVars.redAlliance[1].number.toString(),
    );
    teamControllers[6] = TextEditingController(
      text: initialVars.redAlliance[2].number.toString(),
    );
    teamControllers[7] = TextEditingController(
      text: initialVars.redAlliance.length == 4
          ? initialVars.redAlliance[3].number.toString()
          : null,
    );
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
                              onChange: (final LightTeam team) =>
                                  vars.blue0 = team,
                              controller: teamControllers[0],
                            ),
                            TeamSelectionFuture(
                              onChange: (final LightTeam team) =>
                                  vars.blue1 = team,
                              controller: teamControllers[1],
                            ),
                            TeamSelectionFuture(
                              onChange: (final LightTeam team) =>
                                  vars.blue2 = team,
                              controller: teamControllers[2],
                            ),
                            SectionDivider(label: "Blue Sub Team"),
                            TeamSelectionFuture(
                              dontValidate: true,
                              onChange: (final LightTeam team) =>
                                  vars.blue3 = team,
                              controller: teamControllers[3],
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
                              onChange: (final LightTeam team) =>
                                  vars.red0 = team,
                              controller: teamControllers[4],
                            ),
                            TeamSelectionFuture(
                              onChange: (final LightTeam team) =>
                                  vars.red1 = team,
                              controller: teamControllers[5],
                            ),
                            TeamSelectionFuture(
                              onChange: (final LightTeam team) =>
                                  vars.red2 = team,
                              controller: teamControllers[6],
                            ),
                            SectionDivider(label: "Red Sub Team"),
                            TeamSelectionFuture(
                              dontValidate: true,
                              onChange: (final LightTeam team) =>
                                  vars.red3 = team,
                              controller: teamControllers[7],
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
                  toHasuraVars: () => <String, dynamic>{
                    if (vars.matchesIdToUpdate != null)
                      "id": vars.matchesIdToUpdate,
                    "match": <String, dynamic>{
                      "match_number": vars.matchNumber,
                      "match_type_id": vars.matchTypeId,
                      "blue_0_id": vars.blue0?.id,
                      "blue_1_id": vars.blue1?.id,
                      "blue_2_id": vars.blue2?.id,
                      "blue_3_id": vars.blue3?.id,
                      "red_0_id": vars.red0?.id,
                      "red_1_id": vars.red1?.id,
                      "red_2_id": vars.red2?.id,
                      "red_3_id": vars.red3?.id,
                      "happened": vars.happened,
                    }
                  },
                  mutation: widget.initialVars == null ? mutation : update,
                  resetForm: () {},
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
