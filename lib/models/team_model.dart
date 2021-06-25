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

    //Analytics
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
    if (json['analytic'] != null) {
      print(json['analytic']);
      return Team(
        teamNumber: json['number'],
        teamName: json['name'],
        autoBottomGoalTotal: json['analytic']['auto']['bottomGoalTotal'],
        autoBottomGoalSD: json['analytic']['auto']['bottomGoalSD'],
        autoUpperGoalTotal: json['analytic']['auto']['upperGoalTotal'],
        autoUpperGoalSD: json['analytic']['auto']['upperGoalSD'],
        telpUpperGoalTotal: json['analytic']['teleop']['upperGoalTotal'],
        telpUpperSD: json['analytic']['teleop']['upperGoalSD'],
        climb: json['analytic']['teleop']['climbPrecentage'],

        //table use
        // shotsInTarget: Random().nextInt(15),
        shotsInTarget: json['analytic']['auto']['upperGoalTotal'] +
            json['analytic']['teleop']['upperGoalTotal'],
        successfulClimbs: Random().nextInt(15),

        //demo use
        shotsInTargetPrecent: Random().nextDouble(),
        successfulClimbsPrecent: Random().nextDouble(),
      );
    }
  }
}
