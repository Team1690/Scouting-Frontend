import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/picklist/fetch_picklist.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_screen.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";

class PickListFuture extends StatelessWidget {
  PickListFuture({required this.screen, required this.onReorder});

  final CurrentPickList screen;
  final void Function(List<PickListTeam> list) onReorder;
  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<List<PickListTeam>>(
      future: fetchPicklist(screen),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<List<PickListTeam>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == null) {
          return Center(
            child: Text("No Teams"),
          );
        }
        onReorder(snapshot.data!);
        return PickList(
          onReorder: onReorder,
          uiList: snapshot.data!,
          screen: screen,
        );
      },
    );
  }
}
