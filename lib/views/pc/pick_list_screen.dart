import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/globals.dart' as globals;
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/pick_list_widget.dart';

import '../constants.dart';

class PickListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
        body: Padding(
      padding: EdgeInsets.all(defaultPadding),
      child: Row(
        children: [
          Expanded(
              child: DashboardCard(
                  title: 'first pick list',
                  body: PickList(pickList: globals.secondList))),
          SizedBox(width: defaultPadding),
          Expanded(
              child: DashboardCard(
                  title: 'second pick list',
                  body: PickList(pickList: globals.thirdList)))
        ],
      ),
    ));
  }
}
