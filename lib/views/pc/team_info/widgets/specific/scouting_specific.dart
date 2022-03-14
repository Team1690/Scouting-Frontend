import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class ScoutingSpecific extends StatelessWidget {
  const ScoutingSpecific({required this.msg});

  final SpecificData msg;
  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: Column(
        children: msg.msg
            .map<Widget>(
              (final SpecificMatch e) => Card(
                // shape: ,
                elevation: 10,
                color: bgColor,
                margin: EdgeInsets.fromLTRB(5, 0, 5, defaultPadding),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          e.message,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: primaryWhite,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
