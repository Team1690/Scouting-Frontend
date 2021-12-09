int climbId(final int i) {
  switch (i) {
    case 0:
      return 4;
    case 1:
      return 2;
    case 2:
    default:
      return 1;
  }
}

class Match {
  int teamNumber;
  int matchNumber;

  int teamId;

  int autoUpperGoal = 0;
  int teleOuter = 0;
  int teleInner = 0;

  int climbStatus;

  String matchJson;

  Match({
    this.teamId = 0,
    this.teamNumber = 0,
    this.matchNumber = 0,
    this.autoUpperGoal = 0,
    this.teleOuter = 0,
    this.teleInner = 0,
    this.climbStatus = 1,
  });
}
