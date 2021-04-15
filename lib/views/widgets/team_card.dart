import 'package:scouting_frontend/views/widgets/segment_control.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/widgets/circular_progress_bar.Dart';

class TeamCard extends StatefulWidget {
  final Team selectedTeam;

  TeamCard({
    @required final this.selectedTeam,
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
            '${widget.selectedTeam.teamNumber} - ${widget.selectedTeam.teamName}',
            textAlign: TextAlign.center,
          ),
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
                    //TODO: add TeamData variables
                    // shotsInTargetPrecent: widget.shotsInTargetPrecent,
                    // successfulClimbsPrecent: widget.successfulClimbsPrecent
                    ),
                TeleData(
                  shotsInTargetPrecent:
                      widget.selectedTeam.shotsInTargetPrecent,
                  successfulClimbsPrecent:
                      widget.selectedTeam.shotsInTargetPrecent,
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
  final double bottomGoalAvarage = 31.5;
  final double bottomGoalPersistent = 23.5;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Bottom Goal Avarage: $bottomGoalAvarage',
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Bottom Goal Persistent: $bottomGoalPersistent',
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Upper Goal Avarage: $bottomGoalAvarage',
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Upper Goal Persistent: $bottomGoalPersistent',
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
