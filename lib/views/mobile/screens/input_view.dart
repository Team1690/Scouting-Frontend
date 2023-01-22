import "dart:async";

import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";

import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/matches_search_box_future.dart";
import "package:scouting_frontend/views/mobile/screens/robot_image.dart";
import "package:scouting_frontend/views/mobile/selector.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";
import "package:scouting_frontend/views/mobile/team_selection_matches.dart";

class UserInput extends StatefulWidget {
  @override
  State<UserInput> createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  void flickerScreen(final int newValue, final int oldValue) {
    screenColor = oldValue > newValue && toggleLightsState
        ? Colors.red
        : oldValue < newValue && toggleLightsState
            ? Colors.green
            : null;

    Timer(Duration(milliseconds: 10), () {
      setState(() {
        screenColor = null;
      });
    });
  }

  Widget gamePieceCounters(
    final Color plus,
    final Color minus,
    final List<void Function(int)> updateValues,
    final List<int Function()> getValues,
  ) {
    final List<String> labels = <String>[
      "Top Scored",
      "Mid Scored",
      "Low Scored",
      "Failed"
    ];
    final List<IconData> icons = <IconData>[
      Icons.arrow_circle_up,
      Icons.adjust,
      Icons.arrow_circle_down,
      Icons.error_outline
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...(<int>[0, 1, 2, 3].map((final int index) {
          return Counter(
            plus: plus,
            minus: minus,
            label: labels[index],
            icon: icons[index],
            onChange: (final int count) {
              setState(() {
                flickerScreen(
                  count,
                  getValues[index](),
                );
                updateValues[index](count);
              });
            },
            count: getValues[index](),
          );
        })),
      ],
    );
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
            children: <Icon>[Icon(Icons.lightbulb)],
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
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        hintText: "Scouter name",
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MatchSelectionFuture(
                      controller: matchController,
                      matches: MatchesProvider.of(context).matches,
                      onChange: (final ScheduleMatch selectedMatch) {
                        setState(() {
                          match.scheduleMatch = selectedMatch;
                          match.scoutedTeam = null;
                          teamNumberController.clear();
                        });
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TeamSelectionMatches(
                      match: match.scheduleMatch,
                      controller: teamNumberController,
                      onChange: (final LightTeam team) {
                        setState(() {
                          match.scoutedTeam = team;
                        });
                      },
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
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SectionDivider(label: "Cones"),
                                gamePieceCounters(
                                  Colors.amber,
                                  Colors.amber,
                                  <void Function(int)>[
                                    (final int value) =>
                                        match.autoConesTop = value,
                                    (final int value) =>
                                        match.autoConesMid = value,
                                    (final int value) =>
                                        match.autoConesLow = value,
                                    (final int value) =>
                                        match.autoConesFailed = value
                                  ],
                                  <int Function()>[
                                    () => match.autoConesTop,
                                    () => match.autoConesMid,
                                    () => match.autoConesLow,
                                    () => match.autoConesFailed
                                  ],
                                ),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      element,
                                    ],
                                  )
                                  .toList(),
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black.withOpacity(0.4),
                            thickness: 2,
                            width: 30,
                            indent: 75,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SectionDivider(label: "Cubes"),
                                gamePieceCounters(
                                  Colors.deepPurple,
                                  Colors.deepPurple,
                                  <void Function(int)>[
                                    (final int value) =>
                                        match.autoCubesTop = value,
                                    (final int value) =>
                                        match.autoCubesMid = value,
                                    (final int value) =>
                                        match.autoCubesLow = value,
                                    (final int value) =>
                                        match.autoCubesFailed = value
                                  ],
                                  <int Function()>[
                                    () => match.autoCubesTop,
                                    () => match.autoCubesMid,
                                    () => match.autoCubesLow,
                                    () => match.autoCubesFailed
                                  ],
                                ),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      element,
                                    ],
                                  )
                                  .toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Selector<int>(
                        validate: (final int? result) =>
                            result.onNull("Please pick a balance result"),
                        options: provider.keys.toList(),
                        placeholder: "Choose a balance result",
                        makeItem: (final int index) => provider[index]!,
                        onChange: (final int result) {
                          setState(() {
                            match.autoBalanceStatus = result;
                          });
                        },
                        value: match.autoBalanceStatus,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Teleoperated"),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SectionDivider(label: "Cones"),
                                gamePieceCounters(
                                  Colors.amber,
                                  Colors.amber,
                                  <void Function(int)>[
                                    (final int value) =>
                                        match.teleConesTop = value,
                                    (final int value) =>
                                        match.teleConesMid = value,
                                    (final int value) =>
                                        match.teleConesLow = value,
                                    (final int value) =>
                                        match.teleConesFailed = value
                                  ],
                                  <int Function()>[
                                    () => match.teleConesTop,
                                    () => match.teleConesMid,
                                    () => match.teleConesLow,
                                    () => match.teleConesFailed
                                  ],
                                ),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      element,
                                    ],
                                  )
                                  .toList(),
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black.withOpacity(0.4),
                            thickness: 2,
                            width: 30,
                            indent: 75,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SectionDivider(label: "Cubes"),
                                gamePieceCounters(
                                  Colors.deepPurple,
                                  Colors.deepPurple,
                                  <void Function(int)>[
                                    (final int value) =>
                                        match.teleCubesTop = value,
                                    (final int value) =>
                                        match.teleCubesMid = value,
                                    (final int value) =>
                                        match.teleCubesLow = value,
                                    (final int value) =>
                                        match.teleCubesFailed = value
                                  ],
                                  <int Function()>[
                                    () => match.teleCubesTop,
                                    () => match.teleCubesMid,
                                    () => match.teleCubesLow,
                                    () => match.teleCubesFailed
                                  ],
                                ),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      element,
                                    ],
                                  )
                                  .toList(),
                            ),
                          )
                        ],
                      ),
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
                    SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Endgame Balance"),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Selector<int>(
                        validate: (final int? result) =>
                            result.onNull("Please pick a balance result"),
                        options: provider.keys.toList(),
                        placeholder: "Choose a balance result",
                        makeItem: (final int index) => provider[index]!,
                        onChange: (final int result) {
                          setState(() {
                            match.endgameBalanceStatus = result;
                          });
                        },
                        value: match.endgameBalanceStatus,
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
                          matchController.clear();
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
mutation InsertTechnicalMatch($auto_cones_mid: Int, $auto_balance_id: Int, $auto_cones_failed: Int, $auto_cones_low: Int, $auto_cones_top: Int, $auto_cubes_failed: Int, $auto_cubes_low: Int, $auto_cubes_mid: Int, $auto_cubes_top: Int, $endgame_balance_id: Int, $robot_match_status_id: Int, $scouter_name: String, $team_id: Int, $tele_cones_failed: Int, $tele_cones_low: Int, $tele_cubes_top: Int, $tele_cubes_mid: Int, $tele_cubes_low: Int, $tele_cubes_failed: Int, $tele_cones_top: Int, $tele_cones_mid: Int, $is_rematch: Boolean, $schedule_match_id: Int) {
  insert__2023_technical_match(objects: {auto_balance_id: $auto_balance_id, auto_cones_failed: $auto_cones_failed, auto_cones_low: $auto_cones_low, auto_cones_mid: $auto_cones_mid, auto_cones_top: $auto_cones_top, auto_cubes_failed: $auto_cubes_failed, auto_cubes_low: $auto_cubes_low, auto_cubes_mid: $auto_cubes_mid, auto_cubes_top: $auto_cubes_top, endgame_balance_id: $endgame_balance_id, robot_match_status_id: $robot_match_status_id, scouter_name: $scouter_name, team_id: $team_id, tele_cones_failed: $tele_cones_failed, tele_cones_low: $tele_cones_low, tele_cones_mid: $tele_cones_mid, tele_cones_top: $tele_cones_top, tele_cubes_failed: $tele_cubes_failed, tele_cubes_low: $tele_cubes_low, tele_cubes_top: $tele_cubes_top, tele_cubes_mid: $tele_cubes_mid, is_rematch: $is_rematch, schedule_match_id: $schedule_match_id}) {
    returning {
      id
    }
  }
}
""";
