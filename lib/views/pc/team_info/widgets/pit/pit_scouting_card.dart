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
            Align(
              alignment: Alignment.center,
              child: Text(
                "Robot Fault",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Row(
              children: <Widget>[
                Spacer(
                  flex: 5,
                ),
                Icon(
                  data.hasFault ? Icons.warning : Icons.check,
                  color: data.hasFault ? Colors.yellow[700] : Colors.green,
                ),
                Spacer(),
                Text(data.hasFault ? data.faultMessage : "No Fault"),
                Spacer(
                  flex: 5,
                )
              ],
            ),
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
                "Reliability",
                style: TextStyle(fontSize: 18),
              ),
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                children: <Widget>[
                  Text("Drivetrain: "),
                  Slider(
                    divisions: 4,
                    min: 1,
                    max: 5,
                    value: data.driveTrainReliability.toDouble(),
                    onChanged: (final double a) {},
                    label: data.driveTrainReliability.toString(),
                  )
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                children: <Widget>[
                  Text("Electronics: "),
                  Slider(
                    divisions: 4,
                    min: 1,
                    max: 5,
                    value: data.electronicsReliability.toDouble(),
                    onChanged: (final double a) {},
                    label: data.electronicsReliability.toString(),
                  )
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                children: <Widget>[
                  Text("Robot: "),
                  Slider(
                    divisions: 9,
                    min: 1,
                    max: 10,
                    value: data.robotReliability.toDouble(),
                    onChanged: (final double a) {},
                    label: data.robotReliability.toString(),
                  )
                ],
              ),
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
