import 'package:flutter/material.dart';
import 'package:ScoutingFrontend/CircularProgressBar.Dart';

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressBar(
                precentage: shotsInTargetPrecent,
                fraction: '15/50',
                color: Colors.green,
              ),
              CircularProgressBar(
                precentage: successfulClimbsPrecent,
                fraction: '34/50',
                color: Colors.purple,
              ),
            ],
          ),
          // Text('Avarage shots in target per game'),
        ],
      ),
    );
  }
}
