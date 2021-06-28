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

  final int autoBottomGoalTotal;
  final double autoBottomGoalSD;
  final int autoUpperGoalTotal;
  final double autoUpperGoalSD;
  final int telpUpperGoalTotal;
  final double telpUpperSD;
  final double climb;

  //table use
  final int shotsInTarget;
  final int successfulClimbs;

  //demo use
  final double shotsInTargetPrecent;
  final double successfulClimbsPrecent;

  Team({
    this.teamNumber,
    this.teamName,

    //analyticss
    this.autoBottomGoalTotal,
    this.autoBottomGoalSD,
    this.autoUpperGoalTotal,
    this.autoUpperGoalSD,
    this.telpUpperGoalTotal,
    this.telpUpperSD,
    this.climb,

    //table use
    this.shotsInTarget,
    this.successfulClimbs,

    //demo use
    this.shotsInTargetPrecent,
    this.successfulClimbsPrecent,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    if (json['analytics'] != null) {
      return Team(
        teamNumber: json['number'],
        teamName: json['name'],
        autoBottomGoalTotal: json['analytics']['auto']['bottomGoalTotal'],
        autoBottomGoalSD: json['analytics']['auto']['bottomGoalSD'],
        autoUpperGoalTotal: json['analytics']['auto']['upperGoalTotal'],
        autoUpperGoalSD: json['analytics']['auto']['upperGoalSD'],
        telpUpperGoalTotal: json['analytics']['teleop']['upperGoalTotal'],
        telpUpperSD: json['analytics']['teleop']['upperGoalSD'],
        climb: json['analytics']['teleop']['climbPrecentage'],

        //table use
        // shotsInTarget: Random().nextInt(15),
        shotsInTarget: json['analytics']['auto']['upperGoalTotal'] +
            json['analytics']['teleop']['upperGoalTotal'],
        successfulClimbs: json['analytics']['teleop']['seccessClimb'],

        //demo use
        shotsInTargetPrecent: Random().nextDouble(),
        successfulClimbsPrecent: Random().nextDouble(),
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
