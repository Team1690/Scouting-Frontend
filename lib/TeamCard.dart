import 'package:ScoutingFrontend/SegmentControl.dart';
import 'package:flutter/material.dart';
import 'package:ScoutingFrontend/CircularProgressBar.Dart';

class TeamCard extends StatefulWidget {
  final int teamNumber;
  final String teamName;
  final int shostInTarget;
  final int successfulClimbs;
  final double shotsInTargetPrecent;
  final double successfulClimbsPrecent;
  TeamCard({
    @required final this.teamNumber,
    @required final this.teamName,
    @required final this.shostInTarget,
    @required final this.successfulClimbs,
    @required final this.shotsInTargetPrecent,
    @required final this.successfulClimbsPrecent,
  });

  @override
  _TeamCardState createState() => _TeamCardState();
}

class _TeamCardState extends State<TeamCard> {
  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Text(
            '${widget.teamNumber} - ${widget.teamName}',
            textAlign: TextAlign.center,
          ),
          // Divider(
          //   color: Colors.black,
          //   height: 10,
          // ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 180,
            child: SegmentControl(
              headers: ['Auto', 'Tele'],
              children: [
                AutoData(
                    // shotsInTargetPrecent: widget.shotsInTargetPrecent,
                    // successfulClimbsPrecent: widget.successfulClimbsPrecent
                    ),
                TeleData(
                  shotsInTargetPrecent: widget.shotsInTargetPrecent,
                  successfulClimbsPrecent: widget.successfulClimbsPrecent,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AutoData extends StatelessWidget {
  double bottomGoalAvarage = 31.5;
  double bottomGoalPersistent = 23.5;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Bottom Gaol Avarage: $bottomGoalAvarage',
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Bottom Gaol Persistent: $bottomGoalPersistent',
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Upper Gaol Avarage: $bottomGoalAvarage',
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Upper Gaol Persistent: $bottomGoalPersistent',
        ),
        // Icon(
        //   Icons.surround_sound_outlined,
        //   size: 50,
        // ),
      ],
    );
  }
}

class TeleData extends StatelessWidget {
  const TeleData({
    Key key,
    @required this.shotsInTargetPrecent,
    @required this.successfulClimbsPrecent,
  }) : super(key: key);

  final double shotsInTargetPrecent;
  final double successfulClimbsPrecent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
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
    );
  }
}
