import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';

class NoTeamSelected extends StatelessWidget {
  const NoTeamSelected();

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
        title: '',
        body: Center(
            child: Column(
          children: [
            Expanded(
              child: Container(),
            ),
            Icon(
              Icons.search,
              size: 100,
            ),
            SizedBox(height: defaultPadding),
            Text('Please choose a team in order to display data'),
            Expanded(
              child: Container(),
            ),
          ],
        )));
  }
}
