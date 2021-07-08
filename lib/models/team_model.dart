import 'dart:convert';
import 'dart:math';

enum climbOptions {
  climbed,
  faild,
  notAttempted,
}

class Team {
  final int teamNumber;
  final String teamName;

  // NEW PARAMS:
  final int matchesPlayed;
  final double autoUpperGoalAverage;
  final double autoBottomGoalAverage;
  final double averageShots;
  final double totalShotsSD;
  final double climbsPerMatches;
  final double climbsPerAttempts;

  // final int autoBottomGoalTotal;
  // final double autoBottomGoalSD;
  // final int autoUpperGoalTotal;
  // final double autoUpperGoalSD;
  // final int telpUpperGoalTotal;
  // final double telpUpperSD;
  // final double climb;

  // //table use
  // final int shotsInTarget;
  // final int successfulClimbs;

  // //demo use
  // final double shotsInTargetPrecent;
  // final double successfulClimbsPrecent;

  Team({
    this.teamNumber,
    this.teamName,

    //NEW ANALYTICS!!!!
    this.matchesPlayed = 0,
    this.autoUpperGoalAverage = 0,
    this.autoBottomGoalAverage = 0,
    this.averageShots = 0,
    this.totalShotsSD = 0,
    this.climbsPerMatches = 0,
    this.climbsPerAttempts = 0,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    if (json['analytics'] != null) {
      return Team(
        teamNumber: json['number'],
        teamName: json['name'],

        //NEW
        matchesPlayed: json['analytics']['matchesPlayed'],
        autoUpperGoalAverage:
            json['analytics']['auto']['upperAverage'].toDouble(),
        autoBottomGoalAverage:
            json['analytics']['auto']['bottomAverage'].toDouble(),
        averageShots:
            json['analytics']['teleop']['averageShotsInTarget'].toDouble(),
        totalShotsSD: json['analytics']['teleop']['shotsSD'].toDouble(),
        climbsPerMatches:
            json['analytics']['teleop']['climbPerMatches'].toDouble(),
        climbsPerAttempts:
            json['analytics']['teleop']['climbPerAttempts'].toDouble(),
      );
    }
  }

  factory Team.fromJsonLite(Map<String, dynamic> json) {
    return Team(
      teamNumber: json['number'],
      teamName: json['name'],
    );
  }
}
