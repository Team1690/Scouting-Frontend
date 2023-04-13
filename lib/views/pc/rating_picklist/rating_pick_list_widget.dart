import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/coach_team_info_data.dart";
import "package:scouting_frontend/views/pc/rating_picklist/rating_pick_list_screen.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";
import "package:flutter_switch/flutter_switch.dart";

class RatingPickList extends StatelessWidget {
  RatingPickList({
    required this.uiList,
    required this.screen,
    required this.onReorder,
  }) {
    uiList.sort(
      (final RatingPickListTeam a, final RatingPickListTeam b) =>
          screen.getIndex(a).compareTo(screen.getIndex(b)),
    );
  }

  final List<RatingPickListTeam> uiList;
  final CurrentRatingPickList screen;
  final void Function(List<RatingPickListTeam> list) onReorder;

  void reorderData(final int oldindex, int newindex) {
    if (newindex > oldindex) {
      newindex -= 1;
    }
    final RatingPickListTeam item = uiList.removeAt(oldindex);
    uiList.insert(newindex, item);
    for (int i = 0; i < uiList.length; i++) {
      screen.setIndex(uiList[i], i);
    }
    onReorder(uiList);
  }

  @override
  Widget build(final BuildContext context) => Container(
        child: ReorderableListView(
          buildDefaultDragHandles: true,
          primary: false,
          children: uiList
              .map<Widget>(
                (final RatingPickListTeam pickListTeam) => Card(
                  color: bgColor,
                  key: ValueKey<String>(pickListTeam.toString()),
                  elevation: 2,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      defaultPadding / 4,
                      0,
                      defaultPadding / 4,
                    ),
                    child: isPC(context)
                        ? ExpansionTile(
                            children: <Widget>[
                              ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: <Widget>[
                                          const Spacer(),
                                          Expanded(
                                            child: Icon(
                                              pickListTeam.faultMessages.fold(
                                                () => Icons.check,
                                                (final List<String> _) =>
                                                    Icons.warning,
                                              ),
                                              color: pickListTeam.faultMessages
                                                  .fold(
                                                () => Colors.green,
                                                (final List<String> _) =>
                                                    Colors.yellow[700],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              pickListTeam.faultMessages
                                                      .mapNullable(
                                                    (
                                                      final List<String> p0,
                                                    ) =>
                                                        "Faults: ${p0.length}",
                                                  ) ??
                                                  "No faults",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (pickListTeam.amountOfMatches !=
                                        0) ...<Expanded>[
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Gamepiece points avg: ${pickListTeam.avgGamepiecePoints.toStringAsFixed(1)}",
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Avg Gamepieces Delivered: ${pickListTeam.avgDelivered.toStringAsFixed(1)}",
                                        ),
                                      ),
                                    ] else
                                      ...List<Spacer>.filled(
                                        4,
                                        const Spacer(
                                          flex: 2,
                                        ),
                                      ),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute<TeamInfoScreen>(
                                            builder:
                                                (final BuildContext context) =>
                                                    TeamInfoScreen(
                                              initalTeam: pickListTeam.team,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Team info",
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                              ListTile(
                                title: Row(
                                  children: <Widget>[
                                    const Spacer(),
                                    Expanded(
                                      child: Text(
                                        "Avg Balancing Robots: ${pickListTeam.avgBalancePartners.toStringAsFixed(1)}",
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Best Balance: ${pickListTeam.maxBalanceTitle}",
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Didn't work on field: ${pickListTeam.robotMatchStatusToAmount[RobotMatchStatus.didntWorkOnField]}",
                                        style: const TextStyle(
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Didn't come to field: ${pickListTeam.robotMatchStatusToAmount[RobotMatchStatus.didntComeToField]}",
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    const Spacer()
                                  ],
                                ),
                              )
                            ],
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    pickListTeam.toString(),
                                  ),
                                ),
                                if (pickListTeam.amountOfMatches !=
                                    0) ...<Widget>[
                                  const Spacer(),
                                  Expanded(
                                    child: Text(
                                      pickListTeam.drivetrain ?? "No pit :(",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Worked: ${pickListTeam.robotMatchStatusToAmount[RobotMatchStatus.worked]}",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Avg Scored Gamepieces : ${pickListTeam.avgGamepieces.toStringAsFixed(1)}",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Auto Gamepieces: ${pickListTeam.autoGamepieceAvg.toStringAsFixed(1)}",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Auto Balance: ${pickListTeam.avgAutoBalancePoints.toStringAsFixed(1)}/${pickListTeam.matchesBalanced}/${pickListTeam.amountOfMatches}",
                                    ),
                                  ),
                                ]
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      element,
                                    ],
                                  )
                                  .toList(),
                            ),
                            trailing: const SizedBox(),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  width: 50,
                                  child: TextFormField(
                                    minLines: 1,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 18),
                                    initialValue:
                                        (screen.getIndex(pickListTeam) + 1)
                                            .toString(),
                                    keyboardType: TextInputType.number,
                                    onFieldSubmitted: (final String value) =>
                                        reorderData(
                                      screen.getIndex(pickListTeam),
                                      int.tryParse(value).mapNullable(
                                            (final int parsedInt) =>
                                                (parsedInt - 1) % uiList.length,
                                          ) ??
                                          screen.getIndex(pickListTeam),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                FlutterSwitch(
                                  value: pickListTeam.taken,
                                  activeColor: Colors.red,
                                  inactiveColor: primaryColor,
                                  height: 25,
                                  width: 100,
                                  onToggle: (final bool val) {
                                    pickListTeam.taken = val;
                                    onReorder(uiList);
                                  },
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onDoubleTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<CoachTeamData>(
                                  builder: (final BuildContext context) =>
                                      CoachTeamData(pickListTeam.team),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      pickListTeam.toString(),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const SizedBox(),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    width: 36,
                                    child: TextFormField(
                                      minLines: 1,
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 10),
                                      initialValue:
                                          (screen.getIndex(pickListTeam) + 1)
                                              .toString(),
                                      keyboardType: TextInputType.number,
                                      onFieldSubmitted: (final String value) =>
                                          reorderData(
                                        screen.getIndex(pickListTeam),
                                        int.tryParse(value).mapNullable(
                                              (final int parsedInt) =>
                                                  (parsedInt - 1) %
                                                  uiList.length,
                                            ) ??
                                            screen.getIndex(pickListTeam),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FlutterSwitch(
                                    value: pickListTeam.taken,
                                    activeColor: Colors.red,
                                    inactiveColor: primaryColor,
                                    height: 25,
                                    width: 50,
                                    onToggle: (final bool val) {
                                      pickListTeam.taken = val;
                                      onReorder(uiList);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              )
              .toList(),
          onReorder: reorderData,
        ),
      );
}

int validateId(final int id) =>
    id <= 0 ? throw ArgumentError("Invalid Id") : id;
int validateNumber(final int number) =>
    number < 0 ? throw ArgumentError("Invalid Team Number") : number;
String validateName(final String name) =>
    name == "" ? throw ArgumentError("Invalid Team Name") : name;

class RatingPickListTeam {
  RatingPickListTeam({
    required this.feederListIndex,
    required this.defenseListIndex,
    required this.driveListIndex,
    required this.groundListIndex,
    required this.taken,
    required this.avgGamepiecePoints,
    required this.avgAutoBalancePoints,
    required this.team,
    required this.faultMessages,
    required this.amountOfMatches,
    required this.robotMatchStatusToAmount,
    required this.autoGamepieceAvg,
    required this.avgGamepieces,
    required this.avgDelivered,
    required this.avgBalancePartners,
    required this.matchesBalanced,
    required this.maxBalanceTitle,
    required this.drivetrain,
    required this.defenseRating,
    required this.driveRating,
    required this.feederRating,
    required this.groundRating,
  });
  final String? drivetrain;
  final String maxBalanceTitle;
  final int amountOfMatches;
  final double avgGamepiecePoints;
  final double avgAutoBalancePoints;
  final double autoGamepieceAvg;
  final double avgGamepieces;
  final double avgDelivered;
  final double avgBalancePartners;

  final LightTeam team;
  final List<String>? faultMessages;
  final Map<RobotMatchStatus, int> robotMatchStatusToAmount;
  final int matchesBalanced;
  final double defenseRating;
  final double driveRating;
  final double groundRating;
  final double feederRating;
  int defenseListIndex;
  int driveListIndex;
  int groundListIndex;
  int feederListIndex;
  bool taken;

  @override
  String toString() => "${team.name} ${team.number}";
}
