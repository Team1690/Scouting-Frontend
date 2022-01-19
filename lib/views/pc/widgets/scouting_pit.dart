import "package:flutter/material.dart";
import "package:scouting_frontend/views/mobile/pit_vars.dart";
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
          child: Text(
            """
                      Drive Train Type: ${data.driveTrainType}
                      Drive Train Motor: ${data.driveMotorType}
                      Drive Motor Amount: ${data.driveMotorAmount}
                      Shifter: ${data.shifter}
                      Gearbox: ${data.gearbox}
                      Drive Wheel Type: ${data.driveWheelType}
                      DriveTrain Reliability: ${data.driveTrainReliability}
                      Electronics Reliability: ${data.electronicsReliability}
                      Robot Reliability: ${data.robotReliability}
                      Notes: ${data.notes}
                      """,
            softWrap: false,
          ),
        ),
        CachedNetworkImage(
          width: 150,
          imageUrl: data.url,
          placeholder: (final BuildContext context, final String url) =>
              Center(child: CircularProgressIndicator()),
        )
      ],
    );
  }
}
