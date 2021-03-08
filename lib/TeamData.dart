import 'package:flutter/material.dart';

class TeamData extends StatelessWidget {
  final String teamNumber;
  final String content;
  TeamData({final this.teamNumber, final this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(teamNumber),
      content: Text(content),
    );
  }
}
