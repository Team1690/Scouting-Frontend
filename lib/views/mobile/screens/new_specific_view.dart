import "dart:async";

import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/event_model.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/event_submit_button.dart";
import "package:scouting_frontend/views/mobile/screens/robot_image.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/selector.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";
import "package:scouting_frontend/views/mobile/team_and_match_selection.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/mobile/screens/locations_vars.dart";

class SecondaryTechnical extends StatefulWidget {
  @override
  State<SecondaryTechnical> createState() => _SecondaryTechnicalState();
}

class _SecondaryTechnicalState extends State<SecondaryTechnical> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final CarouselController carouselController = CarouselController();
  TextEditingController nameController = TextEditingController();
  TextEditingController matchController = TextEditingController();
  TextEditingController teamContorller = TextEditingController();
  late final LocationVars vars = LocationVars(
    robotMatchStatusId:
        IdProvider.of(context).robotMatchStatus.nameToId["Worked"] as int,
  );
  final FocusNode node = FocusNode();
  List<MatchEvent> events = <MatchEvent>[];
  late final Map<int, int> robotMatchStatusIndexToId = <int, int>{
    -1: IdProvider.of(context).robotMatchStatus.nameToId["Worked"]!,
    0: IdProvider.of(context)
        .robotMatchStatus
        .nameToId["Didn't come to field"]!,
    1: IdProvider.of(context).robotMatchStatus.nameToId["Didn't work on field"]!
  };
  int time = 0;
  Timer? _timer;
  Timer? get timer => _timer;
  set timer(final Timer? t) {
    _timer?.cancel();
    _timer = t;
    time = 0;
  }

  @override
  Widget build(final BuildContext context) {
    final Map<int, String> startingPosProvider =
        IdProvider.of(context).startingPosIds.idToName;
    final int notOnFieldId = IdProvider.of(context)
        .robotMatchStatus
        .nameToId["Didn't come to field"] as int;
    final Map<String, int> locationsProvider =
        IdProvider.of(context).locationIds.nameToId;
    return Scaffold(
      drawer: SideNavBar(),
      appBar: AppBar(
        actions: <Widget>[RobotImageButton(teamId: () => vars.team?.id)],
        centerTitle: true,
        title: const Text("Technical"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: formKey,
          child: GestureDetector(
            onTap: node.unfocus,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SectionDivider(label: "Pre-match"),
                      const SizedBox(
                        height: 5,
                      ),
                      Divider(
                        color: Colors.black.withOpacity(0.4),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: nameController, //index of nameController
                        validator: (final String? value) =>
                            value != null && value.isNotEmpty
                                ? null
                                : "Please enter your name",
                        onChanged: (final String p0) {
                          vars.scouterName = p0;
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          hintText: "Scouter names",
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TeamAndMatchSelection(
                        matchController: matchController,
                        teamNumberController: teamContorller,
                        onChange: (
                          final ScheduleMatch selectedMatch,
                          final LightTeam? selectedTeam,
                        ) {
                          setState(() {
                            vars.team = selectedTeam;
                            vars.scheduleMatch = selectedMatch;
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
                        isSelected: <bool>[vars.isRematch],
                        onPressed: (final int i) {
                          setState(() {
                            vars.isRematch = !vars.isRematch;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Visibility(
                        visible: notOnFieldId != vars.robotMatchStatusId,
                        child: Selector<int>(
                          options: startingPosProvider.keys.toList(),
                          placeholder: "Choose a starting position",
                          value: vars.startingLocationId,
                          makeItem: (final int index) =>
                              startingPosProvider[index]!,
                          onChange: ((final int currentValue) {
                            setState(() {
                              vars.startingLocationId = currentValue;
                            });
                          }),
                          validate: (final int? submmission) =>
                              notOnFieldId != vars.robotMatchStatusId
                                  ? submmission
                                      .onNull("Please pick a starting position")
                                  : null,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 50,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              events.add(
                                MatchEvent(
                                  eventTypeId:
                                      locationsProvider["Entered Community"]!,
                                  timestamp: 0,
                                ),
                              );
                              timer = Timer.periodic(
                                  const Duration(milliseconds: 100),
                                  (final Timer timer) {
                                setState(() {
                                  time = 100 * timer.tick;
                                });
                              });
                            });
                          },
                          child: const Text("Start Game"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 50,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              events = <MatchEvent>[];
                              timer = null;
                            });
                          },
                          child: const Text("Reset Time"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      Text(() {
                        final int seconds = time ~/ 1000;
                        final int minutes = seconds ~/ 60;
                        return "${minutes.toString().padLeft(2, "0")}:${(seconds % 60).toString().padLeft(2, "0")}";
                      }()),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: time == 0
                        ? <Align>[
                            const Align(
                              alignment: Alignment.center,
                              child: Text("Please Start The Match Timer"),
                            )
                          ]
                        : <Widget>[
                            SectionDivider(label: "Match"),
                            const SizedBox(
                              height: 5,
                            ),
                            Divider(
                              color: Colors.black.withOpacity(0.4),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ...<Widget>[
                              Container(
                                color: events.isEmpty
                                    ? Colors.transparent
                                    : events.last.eventTypeId ==
                                            locationsProvider[
                                                "Entered Community"]!
                                        ? Colors.white
                                        : Colors.transparent,
                                padding: const EdgeInsets.all(8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      events.add(
                                        MatchEvent(
                                          eventTypeId: locationsProvider[
                                              "Entered Community"]!,
                                          timestamp: time,
                                        ),
                                      );
                                    });
                                  },
                                  child: const Text("Community"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                  ),
                                ),
                              ),
                              Container(
                                color: events.isEmpty
                                    ? Colors.transparent
                                    : events.last.eventTypeId ==
                                            locationsProvider[
                                                "Entered Open Field"]!
                                        ? Colors.white
                                        : Colors.transparent,
                                padding: const EdgeInsets.all(8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      events.add(
                                        MatchEvent(
                                          eventTypeId: locationsProvider[
                                              "Entered Open Field"]!,
                                          timestamp: time,
                                        ),
                                      );
                                    });
                                  },
                                  child: const Text("Open Field"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                              ),
                              Container(
                                color: events.isEmpty
                                    ? Colors.transparent
                                    : events.last.eventTypeId ==
                                            locationsProvider["Entered Feeder"]!
                                        ? Colors.white
                                        : Colors.transparent,
                                padding: const EdgeInsets.all(8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      events.add(
                                        MatchEvent(
                                          eventTypeId: locationsProvider[
                                              "Entered Feeder"]!,
                                          timestamp: time,
                                        ),
                                      );
                                    });
                                  },
                                  child: const Text("Feeder"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                  ),
                                ),
                              )
                            ].toList().expand(
                                  (final Widget element) => <Widget>[
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    SizedBox(height: 150, child: element),
                                  ],
                                ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                  ),
                  Column(
                    children: <Widget>[
                      SectionDivider(label: "Post-match"),
                      const SizedBox(
                        height: 15,
                      ),
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
                            vars.robotMatchStatusId =
                                robotMatchStatusIndexToId[i]!;
                            if (vars.robotMatchStatusId == notOnFieldId) {
                              vars.startingLocationId = null;
                            }
                          });
                        },
                        selected: <int, int>{
                          for (final MapEntry<int, int> i
                              in robotMatchStatusIndexToId.entries)
                            i.value: i.key
                        }[vars.robotMatchStatusId]!,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: EventSubmitButton(
                      events: filterEvents(events),
                      isSecondary: true,
                      validate: () => formKey.currentState!.validate(),
                      resetForm: () {
                        setState(() {
                          timer = null;
                          vars.clear(context);
                          matchController.clear();
                          teamContorller.clear();
                          events = <MatchEvent>[];
                        });
                      },
                      mutation: r"""
                        mutation A($scouter_name :String, $schedule_match_id: Int,$is_rematch: Boolean,$starting_position_id: Int,$robot_match_status_id:Int,$team_id: Int, ){
  insert__2023_secondary_technical(objects:{scouter_name:$scouter_name,schedule_match_id:$schedule_match_id,starting_position_id:$starting_position_id,robot_match_status_id:$robot_match_status_id,is_rematch:$is_rematch,team_id:$team_id}){
    affected_rows
     returning{
      id
    }
  }
}""",
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

List<MatchEvent> filterEvents(final List<MatchEvent> events) => events
    .where((final MatchEvent event) => event.timestamp <= 153000)
    .toList();
