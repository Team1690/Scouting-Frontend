class Team {
  // final int teamNumber;
  final String teamName;

  Team({
    // this.teamNumber,
    this.teamName,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      // teamNumber: json['team_number'],
      teamName: json['name'],
    );
  }
}
