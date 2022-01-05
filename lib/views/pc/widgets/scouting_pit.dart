import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/pit_vars.dart';
import 'package:scouting_frontend/views/pc/widgets/team_info_data.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScoutingPit extends StatelessWidget {
  ScoutingPit(this.data);
  final PitViewData data;
  @override
  Widget build(BuildContext context) {
    String newUrl = data.url.substring(0, data.url.length);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Text(
            """
          Drive Train Type: ${data.driveTrainType == PitVars.driveTrainInitialValue ? 'Not Answered' : data.driveTrainType}
          Drive Train Motor: ${data.driveMotorType == PitVars.driveMotorInitialValue ? 'Not Answered' : data.driveMotorType}
          Drive Motor Amount: ${data.driveMotorAmount}
          Shifter: ${data.shifter ?? 'Not Answered'}
          Gearbox: ${data.gearbox ?? 'Not Answered'}
          Drive Wheel Type: ${data.driveWheelType}
          DriveTrain Reliability: ${data.driveTrainReliability}
          Electronics Reliability: ${data.electronicsReliability}
          Robot Reliability: ${data.robotReliability}
          Notes: ${data.notes}
          """,
            softWrap: false,
          ),
          CachedNetworkImage(
            width: 120,
            imageUrl: newUrl,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
          )
        ],
      ),
    );
  }
}
