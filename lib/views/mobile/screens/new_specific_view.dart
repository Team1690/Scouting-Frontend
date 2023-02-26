import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/event_model.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/dropdown_line.dart";
import "package:scouting_frontend/views/mobile/event_submit_button.dart";
import "package:scouting_frontend/views/mobile/screens/robot_image.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/specific_vars.dart";
import "package:scouting_frontend/views/mobile/team_and_match_selection.dart";

class Specific2 extends StatefulWidget {
  @override
  State<Specific2> createState() => _Specific2State();
}

class _Specific2State extends State<Specific2> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final CarouselController carouselController = CarouselController();
  Stopwatch time = Stopwatch();
  TextEditingController nameController = TextEditingController();
  List<TextEditingController> controllers =
      List<TextEditingController>.generate(
    9,
    (final int i) => TextEditingController(),
  );
  final SpecificVars vars = SpecificVars();
  final FocusNode node = FocusNode();
  List<MatchEvent> events = <MatchEvent>[];

  @override
  Widget build(final BuildContext context) => Scaffold(
        drawer: SideNavBar(),
        appBar: AppBar(
          actions: <Widget>[RobotImageButton(teamId: () => vars.team?.id)],
          centerTitle: true,
          title: const Text("Specific"),
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
                            vars.name = p0;
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
                          matchController:
                              controllers[1], //index of matchController
                          teamNumberController:
                              controllers[2], //index of teamNumberController
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
                          height: 20,
                        ),
                        SizedBox(
                          height: 50,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                time.start();
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
                                time.stop();
                                time.reset();
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
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: time.elapsedMilliseconds == 0
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
                                              IdProvider.of(context)
                                                      .locationIds
                                                      .nameToId[
                                                  "Entered Community"]!
                                          ? Colors.white
                                          : Colors.transparent,
                                  padding: const EdgeInsets.all(8),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        events.add(
                                          MatchEvent(
                                            eventTypeId: IdProvider.of(context)
                                                .locationIds
                                                .nameToId["Entered Community"]!,
                                            timestamp: time.elapsedMilliseconds,
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
                                              IdProvider.of(context)
                                                      .locationIds
                                                      .nameToId[
                                                  "Entered Open Field"]!
                                          ? Colors.white
                                          : Colors.transparent,
                                  padding: const EdgeInsets.all(8),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        events.add(
                                          MatchEvent(
                                            eventTypeId: IdProvider.of(context)
                                                    .locationIds
                                                    .nameToId[
                                                "Entered Open Field"]!,
                                            timestamp: time.elapsedMilliseconds,
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
                                              IdProvider.of(context)
                                                  .locationIds
                                                  .nameToId["Entered Feeder"]!
                                          ? Colors.white
                                          : Colors.transparent,
                                  padding: const EdgeInsets.all(8),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        events.add(
                                          MatchEvent(
                                            eventTypeId: IdProvider.of(context)
                                                .locationIds
                                                .nameToId["Entered Feeder"]!,
                                            timestamp: time.elapsedMilliseconds,
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
                          height: 5,
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.4),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        DropdownLine<String>(
                          onTap: () {
                            setState(() {
                              vars.drivetrainAndDriving =
                                  vars.drivetrainAndDriving.onNull(
                                controllers[3].text,
                              ); //index of drivingController
                            });
                          },
                          value: vars.drivetrainAndDriving,
                          onChange: (final String p0) =>
                              vars.drivetrainAndDriving = p0,
                          controller:
                              controllers[3], //index of drivingController
                          label: "Driving & Drivetrain",
                        ),
                        const SizedBox(height: 15.0),
                        DropdownLine<String>(
                          onTap: () {
                            setState(() {
                              vars.intake = vars.intake.onNull(
                                controllers[4].text,
                              ); //index of intakeController
                            });
                          },
                          value: vars.intake,
                          onChange: (final String p0) => vars.intake = p0,
                          controller:
                              controllers[4], //index of intakeController
                          label: "Intake",
                        ),
                        const SizedBox(height: 15.0),
                        DropdownLine<String>(
                          value: vars.placement,
                          onTap: () {
                            setState(() {
                              vars.placement = vars.placement.onNull(
                                controllers[5].text,
                              ); //index of shooterController
                            });
                          },
                          onChange: (final String p0) => vars.placement = p0,
                          controller:
                              controllers[5], //index of shooterController
                          label: "Placement",
                        ),
                        const SizedBox(height: 15.0),
                        DropdownLine<String>(
                          onTap: () {
                            setState(() {
                              vars.defense = vars.defense.onNull(
                                controllers[6].text,
                              ); //index of defenseController
                            });
                          },
                          value: vars.defense,
                          onChange: (final String p0) => vars.defense = p0,
                          controller:
                              controllers[6], //index of defenseController
                          label: "Defense",
                        ),
                        const SizedBox(height: 15.0),
                        DropdownLine<String>(
                          onTap: () {
                            setState(() {
                              vars.generalNotes = vars.generalNotes.onNull(
                                controllers[7].text,
                              ); //index of notesController
                            });
                          },
                          value: vars.generalNotes,
                          onChange: (final String p0) => vars.generalNotes = p0,
                          controller: controllers[7], //index of notesController
                          label: "General Notes",
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Text(
                                  "Robot fault:     ",
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.fitWidth,
                                child: ToggleButtons(
                                  fillColor:
                                      const Color.fromARGB(10, 244, 67, 54),
                                  focusColor:
                                      const Color.fromARGB(170, 244, 67, 54),
                                  highlightColor:
                                      const Color.fromARGB(170, 244, 67, 54),
                                  selectedBorderColor:
                                      const Color.fromARGB(170, 244, 67, 54),
                                  selectedColor: Colors.red,
                                  children: const <Widget>[
                                    Icon(
                                      Icons.cancel,
                                    )
                                  ],
                                  isSelected: <bool>[vars.faultMessage != null],
                                  onPressed: (final int index) {
                                    assert(index == 0);
                                    setState(() {
                                      vars.faultMessage =
                                          vars.faultMessage.onNull("No input");
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: vars.faultMessage == null
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Container(),
                          secondChild: TextField(
                            controller:
                                controllers[8], //index of faultController
                            textDirection: TextDirection.rtl,
                            onChanged: (final String value) {
                              vars.faultMessage = value;
                            },
                            decoration:
                                const InputDecoration(hintText: "Robot fault"),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: EventSubmitButton(
                            events: filterEvents(events),
                            isSpecific: true,
                            validate: () => formKey.currentState!.validate(),
                            resetForm: () {
                              setState(() {
                                time.stop();
                                time.reset();
                                vars.reset();
                                events = <MatchEvent>[];
                                for (final TextEditingController controller
                                    in controllers) {
                                  controller.clear();
                                }
                              });
                            },
                            mutation: """
                        mutation A(\$defense: String, \$drivetrain_and_driving: String, \$general_notes: String, \$intake: String, \$is_rematch: Boolean, \$placement: String, \$scouter_name: String, \$team_id: Int, \$schedule_match_id: Int, \$fault_message:String){
                          insert__2023_specific(objects: {defense: \$defense, drivetrain_and_driving: \$drivetrain_and_driving, general_notes: \$general_notes, intake: \$intake, is_rematch: \$is_rematch, placement: \$placement, scouter_name: \$scouter_name, team_id: \$team_id, schedule_match_id: \$schedule_match_id}) {
                            affected_rows
                            returning{
                              id
                            }
                          }
                                          ${vars.faultMessage == null ? "" : """
                          insert_faults(objects: {team_id: \$team_id, message: \$fault_message}) {
                            affected_rows
                          }"""}
                                          }
                            """,
                            vars: vars,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

List<MatchEvent> filterEvents(final List<MatchEvent> events) => events
    .where((final MatchEvent event) => event.timestamp <= 153000)
    .toList();
