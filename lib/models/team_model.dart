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
  final double autoUpperGoalAvarage;
  final double autoBottomGoalAvarage;
  final double avarageShots;
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
    this.autoUpperGoalAvarage = 0,
    this.autoBottomGoalAvarage = 0,
    this.avarageShots = 0,
    this.totalShotsSD = 0,
    this.climbsPerMatches = 0,
    this.climbsPerAttempts = 0,

    // //analytics
    // this.autoBottomGoalTotal,
    // this.autoBottomGoalSD,
    // this.autoUpperGoalTotal,
    // this.autoUpperGoalSD,
    // this.telpUpperGoalTotal,
    // this.telpUpperSD,
    // this.climb,

    // //table use
    // this.shotsInTarget,
    // this.successfulClimbs,

    // //demo use
    // this.shotsInTargetPrecent,
    // this.successfulClimbsPrecent,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    if (json['analytics'] != null) {
      return Team(
        teamNumber: json['number'],
        teamName: json['name'],

        //NEW
        matchesPlayed: json['analytics']['matchesPlayed'],
        autoUpperGoalAvarage: json['analytics']['auto']['upperAverage'],
        autoBottomGoalAvarage: json['analytics']['auto']['bottomAverage'],
        avarageShots: json['analytics']['teleop']['averageShotsInTarget'],
        totalShotsSD: json['analytics']['teleop']['shotsSD'],
        climbsPerMatches: json['analytics']['teleop']['climbPerMatches'],
        climbsPerAttempts: json['analytics']['teleop']['climbPerAttempts'],

        //!! OLD OLD
        // autoBottomGoalTotal: json['analytics']['auto']['bottomGoalTotal'],
        // autoBottomGoalSD: json['analytics']['auto']['bottomGoalSD'],
        // autoUpperGoalTotal: json['analytics']['auto']['upperGoalTotal'],
        // autoUpperGoalSD: json['analytics']['auto']['upperGoalSD'],
        // telpUpperGoalTotal: json['analytics']['teleop']['upperGoalTotal'],
        // telpUpperSD: json['analytics']['teleop']['upperGoalSD'],
        // climb: json['analytics']['teleop']['climbPrecentage'],

        //table use
        // shotsInTarget: Random().nextInt(15),
        // shotsInTarget: json['analytics']['auto']['upperGoalTotal'] +
        //     json['analytics']['teleop']['upperGoalTotal'],
        // successfulClimbs: json['analytics']['teleop']['seccessClimb'],

        //demo use
        // shotsInTargetPrecent: Random().nextDouble(),
        // successfulClimbsPrecent: Random().nextDouble(),
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
