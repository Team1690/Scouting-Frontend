import "dart:async";

import "package:carousel_slider/carousel_controller.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/event_model.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";

import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/technical_match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/carousel_with_indicator.dart";
import "package:scouting_frontend/views/mobile/event_submit_button.dart";
import "package:scouting_frontend/views/mobile/screens/robot_image.dart";
import "package:scouting_frontend/views/mobile/selector.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
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
  final CarouselController carouselController = CarouselController();
  final TextEditingController matchController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController teamNumberController = TextEditingController();
  final TextEditingController scouterNameController = TextEditingController();
  List<MatchEvent> events = <MatchEvent>[];
  Stopwatch time = Stopwatch();
  bool toggleLightsState = false;
  late final TechnicalMatch match = TechnicalMatch(
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
    final Map<int, String> balanceProvider =
        IdProvider.of(context).balance.idToName;
    final Map<int, String> startingPosProvider =
        IdProvider.of(context).startingPosIds.idToName;
    final Map<String, int> robotActionsProvider =
        IdProvider.of(context).robotActionIds.nameToId;

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
          Form(
            key: formKey,
            child: CarouselWithIndicator(
              widgets: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SectionDivider(label: "Pre-match"),
                    const SizedBox(
                      height: 20,
                    ),
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
                      matchController: matchController,
                      teamNumberController: teamNumberController,
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
                      height: 15,
                    ),
                    SectionDivider(label: "Robot Placement"),
                    const SizedBox(
                      height: 15,
                    ),
                    Selector<int>(
                      options: startingPosProvider.keys.toList(),
                      placeholder: "Choose a starting position",
                      value: match.startingPosId,
                      makeItem: (final int index) =>
                          startingPosProvider[index]!,
                      onChange: ((final int currentValue) =>
                          match.startingPosId = currentValue),
                      validate: (final int? submmission) =>
                          submmission.onNull("Please pick a starting position"),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          carouselController.animateToPage(1);
                          time.start();
                        },
                        child: const Text("Start Game"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Selector<int>(
                        validate: (final int? submission) =>
                            submission.onNull("Please pick a balance result"),
                        options: balanceProvider.keys.toList(),
                        placeholder: "Choose a balance result",
                        makeItem: (final int index) => balanceProvider[index]!,
                        onChange: (final int balance) {
                          setState(() {
                            match.autoBalanceStatus = balance;
                          });
                        },
                        value: match.autoBalanceStatus,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
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
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId:
                                            robotActionsProvider["Top Cone"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
                                  child: const Text("Top"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId:
                                            robotActionsProvider["Mid Cone"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
                                  child: const Text("Mid"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId:
                                            robotActionsProvider["Low Cone"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
                                  child: const Text("Low"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId: robotActionsProvider[
                                            "Feeder Cone"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
                                  child: const Text("Feeder"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId: robotActionsProvider[
                                            "Ground Cone"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
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
                                        width: 120,
                                        height: 50,
                                        child: element,
                                      ),
                                    ],
                                  )
                                  .toList(),
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.black.withOpacity(0.4),
                            thickness: 2,
                            indent: 35,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SectionDivider(label: "Cubes"),
                                ElevatedButton(
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId:
                                            robotActionsProvider["Top Cube"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
                                  child: const Text("Top"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId:
                                            robotActionsProvider["Mid Cube"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
                                  child: const Text("Mid"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId:
                                            robotActionsProvider["Low Cube"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
                                  child: const Text("Low"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId: robotActionsProvider[
                                            "Feeder Cube"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
                                  child: const Text("Feeder"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    events.add(
                                      MatchEvent(
                                        eventTypeId: robotActionsProvider[
                                            "Ground Cube"]!,
                                        timestamp: time.elapsedMilliseconds,
                                      ),
                                    );
                                  },
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
                                        width: 120,
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
                      height: 15,
                    ),
                    SizedBox(
                      height: 40,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          events.remove(events.last);
                        },
                        child: const Text("Reset"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    SectionDivider(label: "Post-match"),
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Endgame Balance"),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Selector<int>(
                        validate: (final int? submission) =>
                            submission.onNull("Please pick a balance result"),
                        options: balanceProvider.keys.toList(),
                        placeholder: "Choose a balance result",
                        makeItem: (final int index) => balanceProvider[index]!,
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
                              children: <Widget>[
                                const Text(
                                  "Cones",
                                  style: TextStyle(color: Colors.amber),
                                ),
                                Text(
                                  events
                                      .where(
                                        (final MatchEvent event) =>
                                            event.eventTypeId ==
                                            IdProvider.of(context)
                                                .robotActionIds
                                                .nameToId["Top Cone"]!,
                                      )
                                      .length
                                      .toString(),
                                ),
                                Text(
                                  events
                                      .where(
                                        (final MatchEvent event) =>
                                            event.eventTypeId ==
                                            IdProvider.of(context)
                                                .robotActionIds
                                                .nameToId["Mid Cone"]!,
                                      )
                                      .length
                                      .toString(),
                                ),
                                Text(
                                  events
                                      .where(
                                        (final MatchEvent event) =>
                                            event.eventTypeId ==
                                            IdProvider.of(context)
                                                .robotActionIds
                                                .nameToId["Low Cone"]!,
                                      )
                                      .length
                                      .toString(),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text(
                                  "Cubes",
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                                Text(
                                  events
                                      .where(
                                        (final MatchEvent event) =>
                                            event.eventTypeId ==
                                            IdProvider.of(context)
                                                .robotActionIds
                                                .nameToId["Top Cube"]!,
                                      )
                                      .length
                                      .toString(),
                                ),
                                Text(
                                  events
                                      .where(
                                        (final MatchEvent event) =>
                                            event.eventTypeId ==
                                            IdProvider.of(context)
                                                .robotActionIds
                                                .nameToId["Mid Cube"]!,
                                      )
                                      .length
                                      .toString(),
                                ),
                                Text(
                                  events
                                      .where(
                                        (final MatchEvent event) =>
                                            event.eventTypeId ==
                                            IdProvider.of(context)
                                                .robotActionIds
                                                .nameToId["Low Cube"]!,
                                      )
                                      .length
                                      .toString(),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    EventSubmitButton(
                      events: events,
                      isSpecific: false,
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
                if (screenColor != null)
                  Container(
                    color: screenColor,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const String mutation = r"""
hi
""";
