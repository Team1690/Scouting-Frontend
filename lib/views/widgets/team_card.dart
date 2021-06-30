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
            height: 270,
            width: 200,
            child: SegmentControl(
              headers: ['Auto', 'Tele'],
              children: [
                AutoData(
                  bottomGoalAvarage: widget.selectedTeam.autoBottomGoalAvarage,
                  upperGoalAvarage: widget.selectedTeam.autoUpperGoalAvarage,
                ),
                TeleData(
                  avarageShots: widget.selectedTeam.avarageShots,
                  shotsSD: widget.selectedTeam.totalShotsSD,
                  climbsPerMatches: widget.selectedTeam.climbsPerMatches,
                  climbsPerAttempts: widget.selectedTeam.climbsPerAttempts,
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
  AutoData({
    @required this.bottomGoalAvarage,
    @required this.upperGoalAvarage,
  });
  final double bottomGoalAvarage;
  final double upperGoalAvarage;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Bottom Goal Avarage: ${bottomGoalAvarage}',
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Upper Goal Avarage: ${upperGoalAvarage}',
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
    @required this.avarageShots,
    @required this.shotsSD,
    @required this.climbsPerMatches,
    @required this.climbsPerAttempts,
  }) : super(key: key);

  final double avarageShots;
  final double shotsSD;
  final double climbsPerMatches;
  final double climbsPerAttempts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            'Shots Avarage: ${avarageShots.toStringAsFixed(2)}',
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Shots SD: ${shotsSD.toStringAsFixed(2)}',
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressBar(
                precentage: climbsPerMatches,
                fraction: '15/50',
                color: Colors.green,
                footer: '/Matches',
              ),
              CircularProgressBar(
                precentage: climbsPerAttempts,
                fraction: '34/50',
                color: Colors.purple,
                footer: '/Attempts',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
