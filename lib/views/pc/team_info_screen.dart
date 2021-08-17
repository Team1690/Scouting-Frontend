import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/team_info_data.dart';

class TeamInfoScreen extends StatelessWidget {
  TeamInfoScreen({@required this.data});
  final List<Team> data;
  @override
  Widget build(BuildContext context) {
    // print(data[0].msg[0]);
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                      decoration:
                          InputDecoration(hintText: 'Search Team Number')),
                ),
                SizedBox(width: defaultPadding),
                Expanded(
                    flex: 2,
                    child: ToggleButtons(
                      children: [
                        Icon(Icons.shield_rounded),
                        Icon(Icons.remove_moderator_outlined),
                      ],
                      isSelected: [false, false],
                      onPressed: (int index) {},
                    )),
              ],
            ),
            SizedBox(height: defaultPadding),
            Expanded(
              // flex: 10,
              child: TeamInfoData(team: data[0]),
            ),
          ],
        ),
      ),
    );
  }
}
