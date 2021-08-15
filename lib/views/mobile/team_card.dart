import 'package:scouting_frontend/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/segment_control.dart';
import 'package:scouting_frontend/views/mobile/circular_progress_bar.Dart';

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
                  team: widget.selectedTeam,
                ),
                TeleData(
                  team: widget.selectedTeam,
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
    @required this.team,
  });

  final Team team;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 60,
        ),
        Text(
          'Bottom Goal Average: ${team.autoBottomGoalAverage.toStringAsFixed(2)}',
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Upper Goal Average: ${team.autoUpperGoalAverage.toStringAsFixed(2)}',
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
    @required this.team,
  }) : super(key: key);

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            'Shots Average: ${team.averageShots.toStringAsFixed(2)}',
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Shots SD: ${team.totalShotsSD.toStringAsFixed(2)}',
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressBar(
                precentage: team.climbsPerMatches,
                fraction: '??/??',
                color: Colors.green,
                footer: '/Matches',
              ),
              CircularProgressBar(
                precentage: team.climbsPerAttempts,
                fraction: '??/??',
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
