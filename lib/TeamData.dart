import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TeamData extends StatelessWidget {
  final int teamNumber;
  final int shostInTarget;
  final int successfulClimbs;
  final double shotsInTargetPrecent;
  final double successfulClimbsPrecent;
  TeamData({
    @required final this.teamNumber,
    @required final this.shostInTarget,
    @required final this.successfulClimbs,
    @required final this.shotsInTargetPrecent,
    @required final this.successfulClimbsPrecent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Team number: ' + teamNumber.toString()),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularPercentIndicator(
            radius: 80,
            lineWidth: 8.0,
            percent: shotsInTargetPrecent,
            center: Text((shotsInTargetPrecent * 100).toStringAsFixed(1) + '%'),
            progressColor: Colors.green,
            animation: true,
            animationDuration: 1200,
            circularStrokeCap: CircularStrokeCap.round,
            footer: Text('Shots'),
          ),
          CircularPercentIndicator(
            radius: 80,
            lineWidth: 8.0,
            percent: successfulClimbsPrecent,
            center:
                Text((successfulClimbsPrecent * 100).toStringAsFixed(1) + '%'),
            progressColor: Colors.purple,
            animation: true,
            animationDuration: 1200,
            circularStrokeCap: CircularStrokeCap.round,
            footer: Text('Climbs'),
          ),
        ],
      ),
    );
  }
}
