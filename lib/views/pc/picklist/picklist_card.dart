import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_screen.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";

class PicklistCard extends StatefulWidget {
  PicklistCard({
    required this.initialData,
  });
  final List<PickListTeam> initialData;

  @override
  State<PicklistCard> createState() => _PicklistCardState();
}

class _PicklistCardState extends State<PicklistCard> {
  late List<PickListTeam> data = widget.initialData;

  CurrentPickList currentPickList = CurrentPickList.first;
  @override
  void didUpdateWidget(final PicklistCard oldWidget) {
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
          ToggleButtons(
            children: <Widget>[
              const Text("First"),
              const Text("Second"),
              const Text("Third"),
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
              currentPickList == CurrentPickList.first,
              currentPickList == CurrentPickList.second,
              currentPickList == CurrentPickList.third,
            ],
            onPressed: (final int pressedIndex) {
              if (pressedIndex == 0) {
                setState(() {
                  currentPickList = CurrentPickList.first;
                  CurrentPickList.first;
                });
              } else if (pressedIndex == 1) {
                setState(() {
                  currentPickList = CurrentPickList.second;
                  CurrentPickList.second;
                });
              } else if (pressedIndex == 2) {
                setState(() {
                  currentPickList = CurrentPickList.third;
                  CurrentPickList.third;
                });
              }
            },
          ),
          IconButton(
            onPressed: () => save(List<PickListTeam>.from(data), context),
            icon: const Icon(Icons.save),
          ),
          IconButton(
            tooltip: "Sort taken",
            onPressed: () {
              setState(() {
                final List<PickListTeam> teamsUntaken = data
                    .where((final PickListTeam element) => !element.taken)
                    .toList();
                final Iterable<PickListTeam> teamsTaken =
                    data.where((final PickListTeam element) => element.taken);
                data = teamsUntaken..addAll(teamsTaken);
                for (int i = 0; i < data.length; i++) {
                  currentPickList.setIndex(data[i], i);
                }
              });
            },
            icon: const Icon(Icons.sort),
          ),
        ],
        title: "",
        body: PickList(
          uiList: data,
          onReorder: (final List<PickListTeam> list) => setState(() {
            data = list;
          }),
          screen: currentPickList,
        ),
      );
}
