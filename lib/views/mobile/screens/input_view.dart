import "dart:async";

import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";

import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/robot_image.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/mobile/team_and_match_selection.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";

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

    Timer(const Duration(milliseconds: 10), () {
      setState(() {
        screenColor = null;
      });
    });
  }

  Widget _gamePieceCounters(final CounterSpec spec) => Counter(
        plus: spec.plus,
        minus: spec.minus,
        label: spec.label,
        icon: spec.icon,
        onChange: (final int count) {
          setState(() {
            flickerScreen(
              count,
              spec.getValues(),
            );
            spec.updateValues(count);
          });
        },
        count: spec.getValues(),
      );

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
    final Map<int, String> balanceProvider =
        IdProvider.of(context).balance.idToName;
    final Map<int, String> startingPosProvider =
        IdProvider.of(context).startingPositionIds.idToName;
    final int notOnFieldId = IdProvider.of(context)
        .robotMatchStatus
        .nameToId["Didn't come to field"]!;
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
                    Visibility(
                      visible: match.robotMatchStatusId != notOnFieldId,
                      child: Column(
                        children: <Widget>[
                          SectionDivider(label: "Robot Placement"),
                          const SizedBox(
                            height: 15,
                          ),
                          Selector<int>(
                            options: startingPosProvider.keys.toList(),
                            placeholder: "Choose a starting position",
                            value: match.startingPositionId,
                            makeItem: (final int index) =>
                                startingPosProvider[index]!,
                            onChange: ((final int currentValue) =>
                                match.startingPositionId = currentValue),
                            validate: (final int? submmission) =>
                                match.robotMatchStatusId == notOnFieldId
                                    ? null
                                    : submmission.onNull(
                                        "Please pick a starting position",
                                      ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
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
                                ...<CounterSpec>[
                                  CounterSpec.amberColors(
                                    "High Scored",
                                    Icons.arrow_circle_up_outlined,
                                    () => match.autoConesTop,
                                    (final int score) =>
                                        match.autoConesTop = score,
                                  ),
                                  CounterSpec.amberColors(
                                    "Mid Scored",
                                    Icons.adjust,
                                    () => match.autoConesMid,
                                    (final int score) =>
                                        match.autoConesMid = score,
                                  ),
                                  CounterSpec.amberColors(
                                    "Low Scored",
                                    Icons.arrow_circle_down,
                                    () => match.autoConesLow,
                                    (final int score) =>
                                        match.autoConesLow = score,
                                  ),
                                  CounterSpec.amberColors(
                                    "Delivered",
                                    Icons.delivery_dining_rounded,
                                    () => match.autoConesDelivered,
                                    (final int score) =>
                                        match.autoConesDelivered = score,
                                  ),
                                  CounterSpec.amberColors(
                                    "Failed",
                                    Icons.error_outline,
                                    () => match.autoConesFailed,
                                    (final int score) =>
                                        match.autoConesFailed = score,
                                  ),
                                ].map(_gamePieceCounters),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      const SizedBox(
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
                                ...<CounterSpec>[
                                  CounterSpec.purpleColors(
                                    "High Scored",
                                    Icons.arrow_circle_up_outlined,
                                    () => match.autoCubesTop,
                                    (final int score) =>
                                        match.autoCubesTop = score,
                                  ),
                                  CounterSpec.purpleColors(
                                    "Mid Scored",
                                    Icons.adjust,
                                    () => match.autoCubesMid,
                                    (final int score) =>
                                        match.autoCubesMid = score,
                                  ),
                                  CounterSpec.purpleColors(
                                    "Low Scored",
                                    Icons.arrow_circle_down,
                                    () => match.autoCubesLow,
                                    (final int score) =>
                                        match.autoCubesLow = score,
                                  ),
                                  CounterSpec.purpleColors(
                                    "Delivered",
                                    Icons.delivery_dining_rounded,
                                    () => match.autoCubesDelivered,
                                    (final int score) =>
                                        match.autoCubesDelivered = score,
                                  ),
                                  CounterSpec.purpleColors(
                                    "Failed",
                                    Icons.error_outline,
                                    () => match.autoCubesFailed,
                                    (final int score) =>
                                        match.autoCubesFailed = score,
                                  ),
                                ].map(_gamePieceCounters),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      const SizedBox(
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
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: match.robotMatchStatusId != notOnFieldId,
                      child: ToggleButtons(
                        fillColor: const Color.fromARGB(10, 244, 67, 54),
                        selectedColor: Colors.green,
                        selectedBorderColor: Colors.green,
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Mobility"),
                          )
                        ],
                        isSelected: <bool>[match.mobility],
                        onPressed: (final int i) {
                          setState(() {
                            match.mobility = !match.mobility;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Visibility(
                      visible: match.robotMatchStatusId != notOnFieldId,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Selector<int>(
                          validate: (final int? submission) => submission
                              .onNull("Please pick an auto balance result"),
                          options: balanceProvider.keys.toList(),
                          placeholder: "Choose an auto balance result",
                          makeItem: (final int index) =>
                              balanceProvider[index]!,
                          onChange: (final int balance) {
                            setState(() {
                              match.autoBalanceStatus = balance;
                            });
                          },
                          value: match.autoBalanceStatus,
                        ),
                      ),
                    ),
                    const SizedBox(
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
                                ...<CounterSpec>[
                                  CounterSpec.amberColors(
                                    "High Scored",
                                    Icons.arrow_circle_up_outlined,
                                    () => match.teleConesTop,
                                    (final int score) =>
                                        match.teleConesTop = score,
                                  ),
                                  CounterSpec.amberColors(
                                    "Mid Scored",
                                    Icons.adjust,
                                    () => match.teleConesMid,
                                    (final int score) =>
                                        match.teleConesMid = score,
                                  ),
                                  CounterSpec.amberColors(
                                    "Low Scored",
                                    Icons.arrow_circle_down,
                                    () => match.teleConesLow,
                                    (final int score) =>
                                        match.teleConesLow = score,
                                  ),
                                  CounterSpec.amberColors(
                                    "Delivered",
                                    Icons.delivery_dining_rounded,
                                    () => match.teleConesDelivered,
                                    (final int score) =>
                                        match.teleConesDelivered = score,
                                  ),
                                  CounterSpec.amberColors(
                                    "Failed",
                                    Icons.error_outline,
                                    () => match.teleConesFailed,
                                    (final int score) =>
                                        match.teleConesFailed = score,
                                  ),
                                ].map(_gamePieceCounters),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      const SizedBox(
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
                                ...<CounterSpec>[
                                  CounterSpec.purpleColors(
                                    "High Scored",
                                    Icons.arrow_circle_up_outlined,
                                    () => match.teleCubesTop,
                                    (final int score) =>
                                        match.teleCubesTop = score,
                                  ),
                                  CounterSpec.purpleColors(
                                    "Mid Scored",
                                    Icons.adjust,
                                    () => match.teleCubesMid,
                                    (final int score) =>
                                        match.teleCubesMid = score,
                                  ),
                                  CounterSpec.purpleColors(
                                    "Low Scored",
                                    Icons.arrow_circle_down,
                                    () => match.teleCubesLow,
                                    (final int score) =>
                                        match.teleCubesLow = score,
                                  ),
                                  CounterSpec.purpleColors(
                                    "Delivered",
                                    Icons.delivery_dining_rounded,
                                    () => match.teleCubesDelivered,
                                    (final int score) =>
                                        match.teleCubesDelivered = score,
                                  ),
                                  CounterSpec.purpleColors(
                                    "Failed",
                                    Icons.error_outline,
                                    () => match.teleCubesFailed,
                                    (final int score) =>
                                        match.teleCubesFailed = score,
                                  ),
                                ].map(_gamePieceCounters),
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      const SizedBox(
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
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: match.robotMatchStatusId != notOnFieldId,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Selector<int>(
                          validate: (final int? submission) => submission
                              .onNull("Please pick an endgame balance result"),
                          options: balanceProvider.keys.toList(),
                          placeholder: "Choose an endgame balance result",
                          makeItem: (final int index) =>
                              balanceProvider[index]!,
                          onChange: (final int balance) {
                            setState(() {
                              match.endgameBalanceStatus = balance;
                              match.balancedWith = balanceProvider[balance] ==
                                          "Balanced" ||
                                      balanceProvider[balance] == "Unbalanced"
                                  ? 0
                                  : null;
                            });
                          },
                          value: match.endgameBalanceStatus,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Visibility(
                      visible: match.balancedWith != null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            textAlign: TextAlign.center,
                            "Balanced with:",
                          ),
                          Slider(
                            onChanged: (final double amountOfBots) =>
                                setState(() {
                              match.balancedWith = amountOfBots.toInt();
                            }),
                            value: (match.balancedWith ?? 0).toDouble(),
                            min: 0,
                            max: 2,
                            divisions: 2,
                            label: (match.balancedWith ?? 0).toString(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Robot fault"),
                    Switcher(
                      borderRadiusGeometry: defaultBorderRadius,
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
                          if (match.robotMatchStatusId == notOnFieldId) {
                            match.autoBalanceStatus = IdProvider.of(context)
                                .balance
                                .nameToId["No attempt"];
                            match.endgameBalanceStatus = IdProvider.of(context)
                                .balance
                                .nameToId["No attempt"];
                          }
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
mutation InsertTechnicalMatch($auto_mobility: Boolean,$balanced_with: Int, $starting_position_id: Int, $tele_cubes_delivered: Int, $tele_cones_delivered: Int, $auto_cubes_delivered: Int, $auto_cones_delivered: Int, $auto_cones_mid: Int, $auto_balance_id: Int, $auto_cones_failed: Int, $auto_cones_low: Int, $auto_cones_top: Int, $auto_cubes_failed: Int, $auto_cubes_low: Int, $auto_cubes_mid: Int, $auto_cubes_top: Int, $endgame_balance_id: Int, $robot_match_status_id: Int, $scouter_name: String, $team_id: Int, $tele_cones_failed: Int, $tele_cones_low: Int, $tele_cubes_top: Int, $tele_cubes_mid: Int, $tele_cubes_low: Int, $tele_cubes_failed: Int, $tele_cones_top: Int, $tele_cones_mid: Int, $is_rematch: Boolean, $schedule_match_id: Int) {
  insert__2023_technical_match(objects: {auto_mobility: $auto_mobility, balanced_with: $balanced_with, starting_position_id: $starting_position_id, auto_balance_id: $auto_balance_id, tele_cubes_delivered: $tele_cubes_delivered, tele_cones_delivered: $tele_cones_delivered, auto_cubes_delivered: $auto_cubes_delivered, auto_cones_delivered: $auto_cones_delivered, auto_cones_failed: $auto_cones_failed, auto_cones_low: $auto_cones_low, auto_cones_mid: $auto_cones_mid, auto_cones_top: $auto_cones_top, auto_cubes_failed: $auto_cubes_failed, auto_cubes_low: $auto_cubes_low, auto_cubes_mid: $auto_cubes_mid, auto_cubes_top: $auto_cubes_top, endgame_balance_id: $endgame_balance_id, robot_match_status_id: $robot_match_status_id, scouter_name: $scouter_name, team_id: $team_id, tele_cones_failed: $tele_cones_failed, tele_cones_low: $tele_cones_low, tele_cones_mid: $tele_cones_mid, tele_cones_top: $tele_cones_top, tele_cubes_failed: $tele_cubes_failed, tele_cubes_low: $tele_cubes_low, tele_cubes_top: $tele_cubes_top, tele_cubes_mid: $tele_cubes_mid, is_rematch: $is_rematch, schedule_match_id: $schedule_match_id}) {
    returning {
      id
    }
  }
}
""";
