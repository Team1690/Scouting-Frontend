import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
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
  Widget build(final BuildContext context) {
    return DashboardCard(
      titleWidgets: <Widget>[
        IconButton(
          onPressed: () {
            setState(() {
              currentPickList = currentPickList.nextScreen();
            });
          },
          icon: Icon(Icons.swap_horiz),
        ),
        IconButton(
          onPressed: () => save(List<PickListTeam>.from(data), context),
          icon: Icon(Icons.save),
        ),
      ],
      title: currentPickList.title,
      body: PickList(
        uiList: data,
        onReorder: (final List<PickListTeam> list) => setState(() {
          data = list;
        }),
        screen: currentPickList,
      ),
    );
  }
}