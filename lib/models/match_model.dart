enum climbOptions {
  climbed,
  faild,
  notAttempted,
}

class Match {
  int teamNumber;
  int matchNumber;

  int autoUpperGoal = 0;
  int autoBottomGoal = 0;
  int autoMissed = 0;

  int teleUpperGoal = 0;
  int teleMissed = 0;

  climbOptions climbStatus;

  Match({
    this.teamNumber = 0,
    this.matchNumber = 0,
    this.autoUpperGoal = 0,
    this.autoBottomGoal = 0,
    this.autoMissed = 0,
    this.teleUpperGoal = 0,
    this.teleMissed = 0,
    this.climbStatus,
  });

  Map<String, dynamic> toJson() => {
        'teamNumber': teamNumber,
        'matchNumber': matchNumber,
      };

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
