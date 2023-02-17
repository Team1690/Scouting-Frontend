import "package:flutter/material.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view/change_fault_status.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view/delete_fault.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view/update_fault_message.dart";

class FaultTile extends StatelessWidget {
  const FaultTile(this.e);
  final FaultEntry e;

  @override
  Widget build(final BuildContext context) => ExpansionTile(
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            EditFault(
              onFinished: handleQueryResult(context),
              faultMessage: e.faultMessage,
              faultId: e.id,
            ),
            DeleteFault(
              faultId: e.id,
              onFinished: handleQueryResult(context),
            ),
            ChangeFaultStatus(
              faultId: e.id,
              onFinished: handleQueryResult(context),
            ),
          ],
        ),
        title: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Text(
                "${e.team.number} ${e.team.name}",
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                "Status: ${e.faultStatus}",
                style: TextStyle(
                  color: faultTitleToColor(
                    e.faultStatus,
                  ),
                ),
              ),
            ),
          ],
        ),
        children: <Widget>[
          ListTile(
            title: Text(e.faultMessage),
          )
        ],
      );
}
