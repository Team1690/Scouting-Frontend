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

  factory Team.fromJson(Map<String, dynamic> json) {
    if (json['analytics'] != null) {
      return Team(
        teamNumber: json['number'],
        teamName: json['name'],

        //NEW
        matchesPlayed: json['analytics']['matchesPlayed'],
        autoUpperGoalAverage:
            json['analytics']['auto']['upperAverage'].toDouble(),
        autoBottomGoalAverage:
            json['analytics']['auto']['bottomAverage'].toDouble(),
        averageShots:
            json['analytics']['teleop']['averageShotsInTarget'].toDouble(),
        totalShotsSD: json['analytics']['teleop']['shotsSD'].toDouble(),
        climbsPerMatches:
            json['analytics']['teleop']['climbPerMatches'].toDouble(),
        climbsPerAttempts:
            json['analytics']['teleop']['climbPerAttempts'].toDouble(),
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
