import "package:flutter/material.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/specific/scouting_specific.dart";

class SpecificCard extends StatefulWidget {
  const SpecificCard(this.data);
  final SpecificData data;

  @override
  State<SpecificCard> createState() => _SpecificCardState();
}

class _SpecificCardState extends State<SpecificCard> {
  String? selectorVal;
  List<String> items = <String>[
    "All",
    "Drivetrain And Driving",
    "Intake",
    "Placement",
    "Defense",
    "General Notes"
  ];

  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "Specific Scouting",
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Selector<String>(
                options: items,
                placeholder: "Select Category",
                value: selectorVal,
                makeItem: (final String p0) => p0,
                onChange: (final String p0) {
                  setState(() {
                    selectorVal = p0;
                  });
                },
                validate: (final String p0) => null,
              ),
              const SizedBox(
                height: 15,
              ),
              ScoutingSpecific(
                selectorValue: selectorVal ?? "All",
                msg: widget.data,
              ),
            ],
          ),
        ),
      );
}
