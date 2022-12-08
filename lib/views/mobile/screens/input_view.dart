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
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";

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

  Color? screenColor;

  final TextEditingController matchController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController teamNumberController = TextEditingController();
  final TextEditingController scouterNameController = TextEditingController();
  bool toggleLightsState = true;
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
      appBar: AppBar(
        actions: <Widget>[
          RobotImageButton(teamId: () => match.team?.id),
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
                    MatchSelectionFuture(
                      controller: matchController,
                      matches: MatchesProvider.of(context).matches,
                      onChange: (final ScheduleMatch selectedMatch) {
                        setState(() {
                          match.match = selectedMatch;
                        });
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TeamSelectionFuture(
                      teams: match.match?.matchTypeId ==
                              IdProvider.of(context)
                                  .matchType
                                  .nameToId["Practice"]!
                          ? TeamProvider.of(context).teams
                          : <LightTeam?>[
                              match.match?.blue0,
                              match.match?.blue1,
                              match.match?.blue2,
                              match.match?.blue3,
                              match.match?.red0,
                              match.match?.red1,
                              match.match?.red2,
                              match.match?.red3
                            ].whereType<LightTeam>().toList(),
                      controller: teamNumberController,
                      onChange: (final LightTeam team) {
                        setState(() {
                          match.team = team;
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
                    SizedBox(
                      height: 20,
                    ),
                    Counter(
                      label: "Upper scored",
                      icon: Icons.sports_baseball,
                      count: match.autoHigh,
                      onChange: (final int p0) {
                        setState(() {
                          flickerScreen(p0, match.autoHigh);
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
                          flickerScreen(p0, match.autoLow);
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
                          flickerScreen(p0, match.autoMissed);
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
                          flickerScreen(p0, match.teleHigh);
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
                          flickerScreen(p0, match.teleLow);
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
                          flickerScreen(p0, match.teleMissed);
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
mutation InsertMatch($auto_lower: Int, $auto_upper: Int, $auto_missed: Int, $climb_id: Int, $matches_id: Int, $team_id: Int, $tele_lower: Int, $tele_upper: Int, $tele_missed: Int, $scouter_name: String, $robot_match_status_id: Int, $is_rematch: Boolean) {
  insert_match(objects: {auto_lower: $auto_lower, auto_upper: $auto_upper, auto_missed: $auto_missed, climb_id: $climb_id, team_id: $team_id, tele_lower: $tele_lower, tele_upper: $tele_upper, tele_missed: $tele_missed, scouter_name: $scouter_name, robot_match_status_id: $robot_match_status_id, is_rematch: $is_rematch, matches_id: $matches_id}) {
    returning {
      id
    }
  }
}
""";
