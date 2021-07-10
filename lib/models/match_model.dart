enum ClimbOptions {
  climbed,
  failed,
  notAttempted,
}

int climbOptionToInt(final ClimbOptions option) {
  switch (option) {
    case ClimbOptions.climbed:
      return 0;
    case ClimbOptions.failed:
      return 1;
    case ClimbOptions.notAttempted:
    default:
      return 2;
  }
}

ClimbOptions intToClimbOption(final int i) {
  switch (i) {
    case 0:
      return ClimbOptions.climbed;
    case 1:
      return ClimbOptions.failed;
    case 2:
    default:
      return ClimbOptions.notAttempted;
  }
}

class Match {
  int teamNumber;
  int matchNumber;

  int autoUpperGoal = 0;
  int autoBottomGoal = 0;

  int teleUpperGoal = 0;

  ClimbOptions climbStatus;

  String matchJson;

  Match({
    this.teamNumber = 0,
    this.matchNumber = 0,
    this.autoUpperGoal = 0,
    this.autoBottomGoal = 0,
    this.teleUpperGoal = 0,
    this.climbStatus = ClimbOptions.notAttempted,
  });

  Map<String, dynamic> toJson() => {
        'number': matchNumber,
        'team': teamNumber,
        'auto': {
          'upperGoal': autoUpperGoal,
          'bottomGoal': autoBottomGoal,
        },
        'teleop': {
          'upperGoal': teleUpperGoal,
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
