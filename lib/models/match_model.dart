enum climbOptions {
  climbed,
  faild,
  notAttempted,
}

class Match {
  final int teamNumber;
  final int matchNumber;

  final int autoUpperGoal;
  final int autoBottomGoal;
  final int autoMissed;

  final int teleUpperGoal;
  final int teleMissed;

  final climbOptions climbStatus;

  Match({
    this.teamNumber,
    this.matchNumber,
    this.autoUpperGoal,
    this.autoBottomGoal,
    this.autoMissed,
    this.teleUpperGoal,
    this.teleMissed,
    this.climbStatus,
  });

  // factory Team.fromJson(Map<String, dynamic> json) {
  //   return Team(
  //     teamNumber: json['number'],
  //     teamName: json['name'],

  //     //table use
  //     shotsInTarget: Random().nextInt(100),
  //     successfulClimbs: Random().nextInt(15),

  //     //demo use
  //     shotsInTargetPrecent: Random().nextDouble(),
  //     successfulClimbsPrecent: Random().nextDouble(),
  //   );
  // }
}
