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
  final double autoUpperGoalAverage;
  final double autoBottomGoalAverage;
  // final double averageShots;
  final double totalShotsSD;
  final double climbsPerMatches;
  final double climbsPerAttempts;

  //test
  final List<String> msg;
  final int averageShots;
  final List<List> tables;
  final List<int> spider;

  Team({
    this.id,
    this.teamNumber,
    this.teamName,

    //NEW ANALYTICS!!!!
    this.matchesPlayed = 0,
    this.autoUpperGoalAverage = 0,
    this.autoBottomGoalAverage = 0,
    this.averageShots = 0,
    this.totalShotsSD = 0,
    this.climbsPerMatches = 0,
    this.climbsPerAttempts = 0,
    this.msg = const [],
    this.tables = const [],
    this.spider = const [0, 0, 0, 0],
  });
}
