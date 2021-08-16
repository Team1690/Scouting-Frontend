import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/globals.dart' as globals;
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/pick_list_widget.dart';

class PickListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
        body: Container(
      child: Row(
        children: [
          Expanded(
              child: DashboardCard(
                  title: 'first pick list',
                  body:
                      Expanded(child: PickList(pickList: globals.secondList)))),
          Expanded(
              child: DashboardCard(
                  title: 'second pick list',
                  body: Expanded(child: PickList(pickList: globals.thirdList))))
        ],
      ),
    ));
  }
}
