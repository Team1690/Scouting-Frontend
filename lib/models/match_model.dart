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

  int teleUpperGoal = 0;
  int teleMissed = 0;

  climbOptions climbStatus;

  String matchJson;

  Match({
    this.teamNumber = 0,
    this.matchNumber = 0,
    this.autoUpperGoal = 0,
    this.autoBottomGoal = 0,
    this.teleUpperGoal = 0,
    this.teleMissed = 0,
    this.climbStatus = climbOptions.notAttempted,
  });

  Map<String, dynamic> toJson() => {
        'number': matchNumber + 50,
        'team': teamNumber,
        'autoData': {
          'upperGoal': autoUpperGoal,
          'bottomGoal': autoBottomGoal,
        },
        'teleopData': {
          'upperGoal': teleUpperGoal,
          'missed': teleMissed,
          'climbed': climbStatus
                  .toString()
                  .substring(climbStatus.toString().indexOf('.') + 1)[0]
                  .toUpperCase() +
              climbStatus
                  .toString()
                  .substring(climbStatus.toString().indexOf('.') + 1)
                  .substring(1),
        }
      };
}
