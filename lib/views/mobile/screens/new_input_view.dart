import "dart:async";

import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";

import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/screens/robot_image.dart";
import "package:scouting_frontend/views/mobile/selector.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";
import "package:scouting_frontend/views/mobile/team_and_match_selection.dart";

class UserInput2 extends StatefulWidget {
  @override
  State<UserInput2> createState() => _UserInput2State();
}

class _UserInput2State extends State<UserInput2> {
  void flickerScreen(final int newValue, final int oldValue) {
    screenColor = oldValue > newValue && toggleLightsState
        ? Colors.red
        : oldValue < newValue && toggleLightsState
            ? Colors.green
            : null;

    Timer(const Duration(milliseconds: 10), () {
      setState(() {
        screenColor = null;
      });
    });
  }

  Color? screenColor;

  final TextEditingController matchController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController teamNumberController = TextEditingController();
  final TextEditingController scouterNameController = TextEditingController();
  bool toggleLightsState = false;
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
    final Map<int, String> provider = IdProvider.of(context).balance.idToName;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: SideNavBar(),
      appBar: AppBar(
        actions: <Widget>[
          RobotImageButton(teamId: () => match.scoutedTeam?.id),
          ToggleButtons(
            children: const <Icon>[Icon(Icons.lightbulb)],
            isSelected: <bool>[toggleLightsState],
            onPressed: (final int i) {
              setState(() {
                toggleLightsState = !toggleLightsState;
              });
            },
            renderBorder: false,
          )
        ],
        centerTitle: true,
        elevation: 5,
        title: const Text(
          "Orbit Scouting",
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: scouterNameController,
                      validator: (final String? value) =>
                          value != null && value.isNotEmpty
                              ? null
                              : "Please enter your name",
                      onChanged: (final String name) {
                        match.name = name;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        hintText: "Scouter name",
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TeamAndMatchSelection(
                      onChange: (
                        final ScheduleMatch selectedMatch,
                        final LightTeam? team,
                      ) {
                        setState(() {
                          match.scheduleMatch = selectedMatch;
                          match.scoutedTeam = team;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ToggleButtons(
                      fillColor: const Color.fromARGB(10, 244, 67, 54),
                      selectedColor: Colors.red,
                      selectedBorderColor: Colors.red,
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
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
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "gamepiece in bot"),
                    Switcher(
                      labels: const <String>["Cone", "Cube"],
                      colors: const <Color>[Colors.amber, Colors.deepPurple],
                      onChange: (final int p0) {},
                      selected: 1,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "robot Placement"),
                    Container(
                      color: Colors.blue,
                      width: 300,
                      height: 100,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Events"),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SectionDivider(label: "Cones"),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Top"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Mid"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Low"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Failed"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Feeder"),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Ground"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                  ),
                                ),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 100,
                                        height: 50,
                                        child: element,
                                      ),
                                    ],
                                  )
                                  .toList(),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SectionDivider(label: "Cubes"),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Top"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Mid"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Low"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Failed"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Feeder"),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Ground"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                  ),
                                ),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 100,
                                        height: 50,
                                        child: element,
                                      ),
                                    ],
                                  )
                                  .toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 50,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("Reset"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Auto Balance"),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Selector<int>(
                        validate: (final int? submission) =>
                            submission.onNull("Please pick a balance result"),
                        options: provider.keys.toList(),
                        placeholder: "Choose a balance result",
                        makeItem: (final int index) => provider[index]!,
                        onChange: (final int balance) {
                          setState(() {
                            match.autoBalanceStatus = balance;
                          });
                        },
                        value: match.autoBalanceStatus,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Endgame Balance"),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Selector<int>(
                        validate: (final int? submission) =>
                            submission.onNull("Please pick a balance result"),
                        options: provider.keys.toList(),
                        placeholder: "Choose a balance result",
                        makeItem: (final int index) => provider[index]!,
                        onChange: (final int balance) {
                          setState(() {
                            match.endgameBalanceStatus = balance;
                          });
                        },
                        value: match.endgameBalanceStatus,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Robot State"),
                    Switcher(
                      labels: const <String>[
                        "Not on field",
                        "Didn't work on field"
                      ],
                      colors: const <Color>[
                        Colors.red,
                        Color.fromARGB(255, 198, 29, 228)
                      ],
                      onChange: (final int i) {
                        setState(() {
                          match.robotMatchStatusId =
                              robotMatchStatusIndexToId[i]!;
                        });
                      },
                      selected: <int, int>{
                        for (final MapEntry<int, int> i
                            in robotMatchStatusIndexToId.entries)
                          i.value: i.key
                      }[match.robotMatchStatusId]!,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "results"),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const <Widget>[
                                Text(
                                  "Cones",
                                  style: TextStyle(color: Colors.amber),
                                ),
                                Text("1"),
                                Text("2"),
                                Text("3")
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const <Widget>[
                                Text(
                                  "Cubes",
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                                Text("1"),
                                Text("2"),
                                Text("3")
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SubmitButton(
                      resetForm: () {
                        setState(() {
                          match.clear(context);
                          teamNumberController.clear();
                          matchController.clear();
                        });
                      },
                      validate: () => formKey.currentState!.validate(),
                      vars: match,
                      mutation: mutation,
                    )
                  ],
                ),
              ),
            ),
          ),
          if (screenColor != null)
            Container(
              color: screenColor,
            )
        ],
      ),
    );
  }
}

const String mutation = r"""
hi
""";
