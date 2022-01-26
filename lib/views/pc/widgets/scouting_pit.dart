import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/pc/widgets/team_info_data.dart";
import "package:cached_network_image/cached_network_image.dart";

class ScoutingPit extends StatelessWidget {
  ScoutingPit(this.data);
  final PitData data;
  @override
  Widget build(final BuildContext context) {
    return Row(
      children: <Widget>[
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                  Text("Drivetrain: ${data.driveTrainReliability}"),
                  Text("Electronics: ${data.electronicsReliability}"),
                  Text("Robot: ${data.robotReliability}"),
                  Align(
                    alignment: Alignment.center,
                    child: Text("Notes"),
                  ),
                  Text(
                    data.notes,
                    softWrap: true,
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push<Scaffold>(
              PageRouteBuilder<Scaffold>(
                reverseTransitionDuration: Duration(milliseconds: 700),
                transitionDuration: Duration(milliseconds: 700),
                pageBuilder: (
                  final BuildContext context,
                  final Animation<double> a,
                  final Animation<double> b,
                ) =>
                    GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Scaffold(
                    body: Center(
                      child: Hero(
                        tag: "Robot Image",
                        child: CachedNetworkImage(
                          imageUrl: data.url,
                          placeholder: (
                            final BuildContext context,
                            final String url,
                          ) =>
                              Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            child: Hero(
              tag: "Robot Image",
              child: CachedNetworkImage(
                width: 240,
                imageUrl: data.url,
                placeholder: (final BuildContext context, final String url) =>
                    Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        )
      ],
    );
  }
}
