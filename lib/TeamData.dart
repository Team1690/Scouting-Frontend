class TeamData {
  // final int teamNumber;
  final String teamName;

  TeamData({
    // this.teamNumber,
    this.teamName,
  });

  factory TeamData.fromJson(Map<String, dynamic> json) {
    return TeamData(
      // teamNumber: json['team_number'],
      teamName: json['name'],
    );
  }
}
