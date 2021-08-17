import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';

import '../../constants.dart';

class ScoutingSpecific extends StatelessWidget {
  const ScoutingSpecific({
    Key key,
    @required this.msg,
  }) : super(key: key);

  final List<Team> msg;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: msg[0]
            .msg
            .map(
              (e) => Card(
                // shape: ,
                elevation: 10,
                color: bgColor,
                margin: EdgeInsets.fromLTRB(5, 0, 5, defaultPadding),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Text(
                    e,
                    style: TextStyle(color: primaryWhite, fontSize: 12),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
