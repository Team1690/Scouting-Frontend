import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/globals.dart' as globals;
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';

class CompareScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
        body: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(children: [
              Container(
                child: Row(
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
              ),
            ])));
  }
}
