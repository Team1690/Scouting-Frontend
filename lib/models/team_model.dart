enum climbOptions {
  climbed,
  faild,
  notAttempted,
}

enum dataPoint {
  x,
  y,
}

class LightTeam {
  LightTeam(this.id, this.number, this.name);
  final int id;
  final int number;
  final String name;
}

class Team {
  final int id;
  final int teamNumber;
  final String teamName;

  // NEW PARAMS:
  final int matchesPlayed;
  final double teleInnerGoalAverage;
  final double teleOuterGoalAverage;
  final double autoGoalAverage;
  // final double averageShots;
  final double totalShotsSD;
  final int climbFailed;
  final int climbSuccess;

  //test
  final List<String> msg;
  final int averageShots;
  final List<int> spider;

  Team({
    required this.id,
    required this.teamNumber,
    required this.teamName,

    //NEW ANALYTICS!!!!
    this.matchesPlayed = 0,
    this.teleInnerGoalAverage = 0,
    this.teleOuterGoalAverage = 0,
    this.autoGoalAverage = 0,
    this.averageShots = 0,
    this.totalShotsSD = 0,
    this.climbFailed = 0,
    this.climbSuccess = 0,
    this.msg = const <String>[],
    this.spider = const <int>[0, 0, 0, 0],
  });
}
