import "package:flutter/material.dart";
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
              child: Text(
                """
Drive Train Type: ${data.driveTrainType}
Drive Train Motor: ${data.driveMotorType}
Drive Motor Amount: ${data.driveMotorAmount}
Drive Wheel Type: ${data.driveWheelType}

Shifter: ${data.shifter}
Gearbox: ${data.gearbox}

DriveTrain Reliability: ${data.driveTrainReliability}
Electronics Reliability: ${data.electronicsReliability}
Robot Reliability: ${data.robotReliability}

Notes: ${data.notes}
""",
                softWrap: true,
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
