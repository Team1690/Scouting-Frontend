import 'dart:math';

enum climbOptions {
  climbed,
  faild,
  notAttempted,
}

class Team {
  final int teamNumber;
  final String teamName;
  final int autoUpperGoal;
  final int autobottomGoal;
  final int telpUpperGoal;
  final int teleMissed;
  final int climb;

  //table use
  final int shotsInTarget;
  final int successfulClimbs;

  //demo use
  final double shotsInTargetPrecent;
  final double successfulClimbsPrecent;

  Team({
    this.teamNumber,
    this.teamName,

    //matchdata
    this.autoUpperGoal,
    this.autobottomGoal,
    this.telpUpperGoal,
    this.teleMissed,
    this.climb,

    //table use
    this.shotsInTarget,
    this.successfulClimbs,

    //demo use
    this.shotsInTargetPrecent,
    this.successfulClimbsPrecent,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamNumber: json['number'],
      teamName: json['name'],

      //table use
      shotsInTarget: Random().nextInt(100),
      successfulClimbs: Random().nextInt(15),

      //demo use
      shotsInTargetPrecent: Random().nextDouble(),
      successfulClimbsPrecent: Random().nextDouble(),
    );
  }
}
