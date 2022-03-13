import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class PitScoutingCard extends StatelessWidget {
  PitScoutingCard(this.data);
  final PitData data;
  @override
  Widget build(final BuildContext context) {
    return DashboardCard(
      title: "Pit Scouting",
      body: SingleChildScrollView(
        primary: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (data.faultMessages == null ||
                data.faultMessages!.isEmpty) ...<Widget>[
              Row(
                children: <Widget>[
                  Spacer(
                    flex: 5,
                  ),
                  Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  Spacer(),
                  Text(
                    "No Fault",
                    style: TextStyle(fontSize: 18),
                  ),
                  Spacer(
                    flex: 5,
                  )
                ],
              ),
            ] else ...<Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Faults",
                    style: TextStyle(fontSize: 18),
                  ),
                  Icon(
                    Icons.warning,
                    color: Colors.yellow[700],
                  )
                ],
              ),
              ...data.faultMessages!.map(Text.new).toList().expand(
                    (final Text element) => <Widget>[
                      element,
                      SizedBox(
                        height: 20,
                      )
                    ],
                  )
            ],
            Align(
              alignment: Alignment.center,
              child: Text(
                "Drivetrain",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Text("Drivetrain: ${data.driveTrainType}"),
            Text("Drive motor: ${data.driveMotorType}"),
            Text("Drive motor amount: ${data.driveMotorAmount}"),
            Text("Drive wheel: ${data.driveWheelType}"),
            Row(
              children: <Widget>[
                Text("Has shifter:"),
                data.hasShifer.mapNullable(
                      (final bool hasShifter) => hasShifter
                          ? Icon(
                              Icons.done,
                              color: Colors.lightGreen,
                            )
                          : Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                    ) ??
                    Text(" Not answered"),
              ],
            ),
            Text(
              "Gearbox: ${data.gearboxPurchased.mapNullable((final bool p0) => p0 ? "purchased" : "custom") ?? "Not answered"}",
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Notes",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Text(
              data.notes,
              softWrap: true,
              textDirection: TextDirection.rtl,
            )
          ],
        ),
      ),
    );
  }
}
