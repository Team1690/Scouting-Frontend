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
  // bool tab = true;
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
          SegmentControl(
            headers: ['Auto', 'Tele'],
            children: [
              AutoData(
                  shotsInTargetPrecent: widget.shotsInTargetPrecent,
                  successfulClimbsPrecent: widget.successfulClimbsPrecent),
              Container(
                height: 150,
                color: Colors.orange,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class AutoData extends StatelessWidget {
  const AutoData({
    Key key,
    @required this.shotsInTargetPrecent,
    @required this.successfulClimbsPrecent,
  }) : super(key: key);

  final double shotsInTargetPrecent;
  final double successfulClimbsPrecent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
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
