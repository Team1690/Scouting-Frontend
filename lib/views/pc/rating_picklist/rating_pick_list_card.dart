import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/rating_picklist/rating_pick_list_screen.dart";
import "package:scouting_frontend/views/pc/rating_picklist/rating_pick_list_widget.dart";

class RatingPicklistCard extends StatefulWidget {
  RatingPicklistCard({
    required this.initialData,
  });
  final List<RatingPickListTeam> initialData;

  @override
  State<RatingPicklistCard> createState() => _RatingPicklistCardState();
}

class _RatingPicklistCardState extends State<RatingPicklistCard> {
  late List<RatingPickListTeam> data = widget.initialData;

  CurrentRatingPickList currentRatingPickList = CurrentRatingPickList.defense;
  @override
  void didUpdateWidget(final RatingPicklistCard oldWidget) {
    if (data != widget.initialData) {
      setState(() {
        data = widget.initialData;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    save(data);
  }

  @override
  Widget build(final BuildContext context) => DashboardCard(
        titleWidgets: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            child: Column(
              children: <Widget>[
                if (!isPC(context)) ...<Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () =>
                            save(List<RatingPickListTeam>.from(data), context),
                        icon: const Icon(Icons.save),
                      ),
                      IconButton(
                        tooltip: "Sort taken",
                        onPressed: () {
                          setState(() {
                            final List<RatingPickListTeam> teamsUntaken = data
                                .where(
                                  (final RatingPickListTeam element) =>
                                      !element.taken,
                                )
                                .toList();
                            final Iterable<RatingPickListTeam> teamsTaken =
                                data.where(
                              (final RatingPickListTeam element) =>
                                  element.taken,
                            );
                            data = teamsUntaken..addAll(teamsTaken);
                            for (int i = 0; i < data.length; i++) {
                              currentRatingPickList.setIndex(data[i], i);
                            }
                          });
                        },
                        icon: const Icon(Icons.sort),
                      ),
                      IconButton(
                        tooltip: "Sort By Rating",
                        onPressed: () {
                          setState(() {
                            data.sort(
                              (
                                final RatingPickListTeam a,
                                final RatingPickListTeam b,
                              ) =>
                                  currentRatingPickList.getRating(a).compareTo(
                                        currentRatingPickList.getRating(b),
                                      ),
                            );
                          });
                        },
                        icon: const Icon(Icons.star_rate),
                      )
                    ],
                  ),
                ],
                Row(
                  children: <Widget>[
                    ToggleButtons(
                      children: <Widget>[
                        const Text("Defense"),
                        const Text("Drive"),
                        const Text("Feeder"),
                        const Text("Ground")
                      ]
                          .map(
                            (final Widget text) => Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isPC(context) ? 30 : 5,
                              ),
                              child: text,
                            ),
                          )
                          .toList(),
                      isSelected: <bool>[
                        currentRatingPickList == CurrentRatingPickList.defense,
                        currentRatingPickList == CurrentRatingPickList.drive,
                        currentRatingPickList == CurrentRatingPickList.feeder,
                        currentRatingPickList == CurrentRatingPickList.ground,
                      ],
                      onPressed: (final int pressedIndex) {
                        if (pressedIndex == 0) {
                          setState(() {
                            currentRatingPickList =
                                CurrentRatingPickList.defense;
                            CurrentRatingPickList.defense;
                          });
                        } else if (pressedIndex == 1) {
                          setState(() {
                            currentRatingPickList = CurrentRatingPickList.drive;
                            CurrentRatingPickList.drive;
                          });
                        } else if (pressedIndex == 2) {
                          setState(() {
                            currentRatingPickList =
                                CurrentRatingPickList.feeder;
                            CurrentRatingPickList.feeder;
                          });
                        } else if (pressedIndex == 3) {
                          setState(() {
                            currentRatingPickList =
                                CurrentRatingPickList.ground;
                            CurrentRatingPickList.ground;
                          });
                        }
                      },
                    ),
                    if (isPC(context)) ...<Widget>[
                      IconButton(
                        onPressed: () =>
                            save(List<RatingPickListTeam>.from(data), context),
                        icon: const Icon(Icons.save),
                      ),
                      IconButton(
                        tooltip: "Sort taken",
                        onPressed: () {
                          setState(() {
                            final List<RatingPickListTeam> teamsUntaken = data
                                .where(
                                  (final RatingPickListTeam element) =>
                                      !element.taken,
                                )
                                .toList();
                            final Iterable<RatingPickListTeam> teamsTaken =
                                data.where(
                              (final RatingPickListTeam element) =>
                                  element.taken,
                            );
                            data = teamsUntaken..addAll(teamsTaken);
                            for (int i = 0; i < data.length; i++) {
                              currentRatingPickList.setIndex(data[i], i);
                            }
                          });
                        },
                        icon: const Icon(Icons.sort),
                      ),
                      IconButton(
                        tooltip: "Sort By Rating",
                        onPressed: () {
                          setState(() {
                            data.sort(
                              (
                                final RatingPickListTeam a,
                                final RatingPickListTeam b,
                              ) =>
                                  currentRatingPickList.getRating(a).compareTo(
                                        currentRatingPickList.getRating(b),
                                      ),
                            );
                          });
                        },
                        icon: const Icon(Icons.star_rate),
                      )
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
        title: "",
        body: RatingPickList(
          uiList: data,
          onReorder: (final List<RatingPickListTeam> list) => setState(() {
            data = list;
          }),
          screen: currentRatingPickList,
        ),
      );
}
