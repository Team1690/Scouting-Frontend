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

import "../../../models/id_enums.dart";

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
  bool toggleLightsState = false;
  late final Match match = Match(
    robotMatchStatusId: IdProvider.of(context)
        .robotMatchStatus
        .enumToId[RobotMatchStatus.worked] as int,
  );
  // -1 means nothing

  late final Map<int, int> robotMatchStatusIndexToId = <int, int>{
    -1: IdProvider.of(context)
        .robotMatchStatus
        .enumToId[RobotMatchStatus.worked]!,
    0: IdProvider.of(context)
        .robotMatchStatus
        .enumToId[RobotMatchStatus.didntComeToField]!,
    1: IdProvider.of(context)
        .robotMatchStatus
        .enumToId[RobotMatchStatus.didntWorkOnField]!
  };
  @override
  Widget build(final BuildContext context) {
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
                    SizedBox(
                      height: 20,
                    ),
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
                                Counter(
                                  color: Colors.amber,
                                  label: "   Top Scored",
                                  icon: Icons.arrow_circle_up,
                                  count: match.autoConesTop,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.autoConesTop);
                                      match.autoConesTop = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.amber,
                                  label: "   Mid Scored",
                                  icon: Icons.arrow_circle_left,
                                  count: match.autoConesMid,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.autoConesMid);
                                      match.autoConesMid = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.amber,
                                  label: "   Low Scored",
                                  icon: Icons.arrow_circle_down,
                                  count: match.autoConesLow,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.autoConesLow);
                                      match.autoConesLow = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.amber,
                                  count: match.autoConesFailed,
                                  label: "      Failed      ",
                                  icon: Icons.error,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.autoConesFailed);
                                      match.autoConesFailed = p0;
                                    });
                                  },
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
                                Counter(
                                  color: Colors.deepPurple,
                                  label: "   Top Scored",
                                  icon: Icons.arrow_circle_up,
                                  count: match.autoCubesTop,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.autoCubesTop);
                                      match.autoCubesTop = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.deepPurple,
                                  label: "   Mid Scored",
                                  icon: Icons.arrow_circle_left,
                                  count: match.autoCubesMid,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.autoCubesMid);
                                      match.autoCubesMid = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.deepPurple,
                                  label: "   Low Scored",
                                  icon: Icons.arrow_circle_down,
                                  count: match.autoCubesLow,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.autoCubesLow);
                                      match.autoCubesLow = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.deepPurple,
                                  count: match.autoCubesFailed,
                                  label: "      Failed      ",
                                  icon: Icons.error,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.autoCubesFailed);
                                      match.autoCubesFailed = p0;
                                    });
                                  },
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
                        validate: (final int? p0) =>
                            p0.onNull("Please pick a balance result"),
                        options: IdProvider.of(context)
                            .balance
                            .idToEnum
                            .keys
                            .toList(),
                        placeholder: "Choose a balance result",
                        makeItem: (final int p0) =>
                            IdProvider.of(context).balance.idToEnum[p0]!.title,
                        onChange: (final int p0) {
                          setState(() {
                            match.autoBalanceStatus = p0;
                          });
                        },
                        value: match.autoBalanceStatus,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Teleoperated"),
                    SizedBox(
                      height: 10,
                    ),
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
                                Counter(
                                  color: Colors.amber,
                                  label: "   Top Scored",
                                  icon: Icons.arrow_circle_up,
                                  count: match.teleConesTop,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.teleConesTop);
                                      match.teleConesTop = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.amber,
                                  label: "   Mid Scored",
                                  icon: Icons.arrow_circle_left,
                                  count: match.teleConesMid,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.teleConesMid);
                                      match.teleConesMid = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.amber,
                                  label: "   Low Scored",
                                  icon: Icons.arrow_circle_down,
                                  count: match.teleConesLow,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.teleConesLow);
                                      match.teleConesLow = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.amber,
                                  count: match.teleConesFailed,
                                  label: "      Failed      ",
                                  icon: Icons.error,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.teleConesFailed);
                                      match.teleConesFailed = p0;
                                    });
                                  },
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
                                Counter(
                                  color: Colors.deepPurple,
                                  label: "   Top Scored",
                                  icon: Icons.arrow_circle_up,
                                  count: match.teleCubesTop,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.teleCubesTop);
                                      match.teleCubesTop = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.deepPurple,
                                  label: "   Mid Scored",
                                  icon: Icons.arrow_circle_left,
                                  count: match.teleCubesMid,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.teleCubesMid);
                                      match.teleCubesMid = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.deepPurple,
                                  label: "   Low Scored",
                                  icon: Icons.arrow_circle_down,
                                  count: match.teleCubesLow,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.teleCubesLow);
                                      match.teleCubesLow = p0;
                                    });
                                  },
                                ),
                                Counter(
                                  color: Colors.deepPurple,
                                  count: match.teleCubesFailed,
                                  label: "      Failed      ",
                                  icon: Icons.error,
                                  onChange: (final int p0) {
                                    setState(() {
                                      flickerScreen(p0, match.teleCubesFailed);
                                      match.teleCubesFailed = p0;
                                    });
                                  },
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
                        validate: (final int? p0) =>
                            p0.onNull("Please pick a balance result"),
                        options: IdProvider.of(context)
                            .balance
                            .idToEnum
                            .keys
                            .toList(),
                        placeholder: "Choose a balance result",
                        makeItem: (final int p0) =>
                            IdProvider.of(context).balance.idToEnum[p0]!.title,
                        onChange: (final int p0) {
                          setState(() {
                            match.endgameBalanceStatus = p0;
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
