import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";

import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/main_app_bar.dart";
import "package:scouting_frontend/views/mobile/selector.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/match_dropdown.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";

class UserInput extends StatefulWidget {
  @override
  State<UserInput> createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  final TextEditingController matchNumberController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController teamNumberController = TextEditingController();
  final TextEditingController scouterNameController = TextEditingController();
  late final Match match = Match(
    robotMatchStatusId:
        IdProvider.of(context).robotMatchStatus.nameToId["Worked"] as int,
  );
  // -1 means nothing

  late final Map<int, int> robotMatchStatusIndexToId = <int, int>{
    -1: IdProvider.of(context).robotMatchStatus.nameToId["Worked"]!,
    0: IdProvider.of(context)
        .robotMatchStatus
        .nameToId["Didn't come to field"]!,
    1: IdProvider.of(context).robotMatchStatus.nameToId["Didn't work on field"]!
  };
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: SideNavBar(),
      appBar: MainAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Column(
              children: <Widget>[
                SectionDivider(label: "Match Details"),
                MatchTextBox(
                  validate: (final String? p0) {
                    if (p0 == null || p0.isEmpty) {
                      return "Please enter a match number";
                    }
                    return null;
                  },
                  onChange: (final int value) => match.matchNumber = value,
                  controller: matchNumberController,
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: scouterNameController,
                  validator: (final String? value) =>
                      value != null && value.isNotEmpty
                          ? null
                          : "Please enter your name",
                  onChanged: (final String p0) {
                    match.name = p0;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    hintText: "Scouter name",
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TeamSelectionFuture(
                  controller: teamNumberController,
                  onChange: (final LightTeam team) {
                    match.team = team;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Selector<int>(
                  options:
                      IdProvider.of(context).matchType.idToName.keys.toList(),
                  placeholder: "Match type",
                  value: match.matchTypeId,
                  makeItem: (final int id) =>
                      IdProvider.of(context).matchType.idToName[id]!,
                  onChange: (final int id) {
                    match.matchTypeId = id;
                  },
                  validate: (final int i) =>
                      i.onNull("Please pick a match type"),
                ),
                SizedBox(
                  height: 15,
                ),
                ToggleButtons(
                  fillColor: Color.fromARGB(10, 244, 67, 54),
                  selectedColor: Colors.red,
                  selectedBorderColor: Colors.red,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Rematch"),
                    )
                  ],
                  isSelected: <bool>[match.isRematch],
                  onPressed: (final int i) {
                    setState(() {
                      match.isRematch = !match.isRematch;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                SectionDivider(label: "Autonomous"),
                SizedBox(
                  height: 20,
                ),
                Counter(
                  label: "Upper scored",
                  icon: Icons.sports_baseball,
                  count: match.autoHigh,
                  onChange: (final int p0) {
                    setState(() {
                      match.autoHigh = p0;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Counter(
                  label: "Lower scored",
                  icon: Icons.sports_baseball_outlined,
                  count: match.autoLow,
                  onChange: (final int p0) {
                    setState(() {
                      match.autoLow = p0;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Counter(
                  count: match.autoMissed,
                  label: "      Missed      ",
                  icon: Icons.error,
                  onChange: (final int p0) {
                    setState(() {
                      match.autoMissed = p0;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                SectionDivider(label: "Teleoperated"),
                SizedBox(
                  height: 10,
                ),
                Counter(
                  count: match.teleHigh,
                  label: "Upper scored",
                  icon: Icons.sports_baseball,
                  onChange: (final int p0) {
                    setState(() {
                      match.teleHigh = p0;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Counter(
                  count: match.teleLow,
                  label: "Lower scored",
                  icon: Icons.sports_baseball_outlined,
                  onChange: (final int p0) {
                    setState(() {
                      match.teleLow = p0;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Counter(
                  count: match.teleMissed,
                  label: "      Missed      ",
                  icon: Icons.error,
                  onChange: (final int p0) {
                    setState(() {
                      match.teleMissed = p0;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                SectionDivider(label: "Robot fault"),
                Switcher(
                  labels: <String>["Not on field", "Didn't work on field"],
                  colors: <Color>[
                    Colors.red,
                    Color.fromARGB(255, 198, 29, 228)
                  ],
                  onChange: (final int i) {
                    setState(() {
                      match.robotMatchStatusId = robotMatchStatusIndexToId[i]!;
                    });
                  },
                  selected: <int, int>{
                    for (final MapEntry<int, int> i
                        in robotMatchStatusIndexToId.entries)
                      i.value: i.key
                  }[match.robotMatchStatusId]!,
                ),
                SizedBox(
                  height: 20,
                ),
                SectionDivider(label: "Climb"),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Selector<int>(
                    validate: (final int? p0) =>
                        p0.onNull("Please pick a climb result"),
                    options:
                        IdProvider.of(context).climb.idToName.keys.toList(),
                    placeholder: "Choose a climb result",
                    makeItem: (final int p0) =>
                        IdProvider.of(context).climb.idToName[p0]!,
                    onChange: (final int p0) {
                      setState(() {
                        match.climbStatus = p0;
                      });
                    },
                    value: match.climbStatus,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SubmitButton(
                  resetForm: () {
                    setState(() {
                      match.clear(context);
                      teamNumberController.clear();
                      matchNumberController.clear();
                    });
                  },
                  validate: () {
                    return formKey.currentState!.validate();
                  },
                  vars: match,
                  mutation: mutation,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String mutation = """
mutation MyMutation(\$auto_lower: Int, \$auto_upper: Int, \$auto_missed: Int, \$climb_id: Int, \$match_number: Int, \$team_id: Int, \$tele_lower: Int, \$tele_upper: Int, \$tele_missed: Int, \$scouter_name: String, \$match_type_id:Int, \$robot_match_status_id: Int,\$is_rematch: Boolean) {
  insert_match_2022(objects: {auto_lower: \$auto_lower, auto_upper: \$auto_upper, auto_missed: \$auto_missed, climb_id: \$climb_id, match_number: \$match_number, team_id: \$team_id, tele_lower: \$tele_lower, tele_upper: \$tele_upper, tele_missed: \$tele_missed, scouter_name: \$scouter_name, match_type_id: \$match_type_id, robot_match_status_id: \$robot_match_status_id, is_rematch: \$is_rematch}) {
    returning {
      id
    }
  }
}
""";
