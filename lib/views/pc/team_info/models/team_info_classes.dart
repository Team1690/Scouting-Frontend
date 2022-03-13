import "package:scouting_frontend/models/team_model.dart";

class QuickData {
  QuickData({
    required this.avgAutoLowScored,
    required this.avgAutoMissed,
    required this.avgAutoUpperScored,
    required this.avgBallPoints,
    required this.avgClimbPoints,
    required this.avgTeleLowScored,
    required this.avgTeleMissed,
    required this.avgTeleUpperScored,
    required this.scorePercentAuto,
    required this.scorePercentTele,
  });
  final double avgBallPoints;
  final double avgClimbPoints;
  final double avgAutoUpperScored;
  final double avgAutoMissed;
  final double avgAutoLowScored;
  final double scorePercentAuto;
  final double avgTeleUpperScored;
  final double avgTeleMissed;
  final double avgTeleLowScored;
  final double scorePercentTele;
}

class SpecificData {
  SpecificData(this.msg, this.role);
  final String role;
  final List<SpecificMatch> msg;
}

class SpecificMatch {
  const SpecificMatch(this.message, this.role);
  final String message;
  final String? role;
}

class LineChartData<E extends num> {
  LineChartData({
    required this.points,
    required this.title,
    required this.gameNumbers,
    required this.robotMatchStatuses,
  });
  final List<List<E>> points;
  final List<List<RobotMatchStatus>> robotMatchStatuses;
  final List<MatchIdentifier> gameNumbers;
  final String title;
}

enum RobotMatchStatus { worked, didntComeToField, didntWorkOnField }

class MatchIdentifier {
  const MatchIdentifier({
    required this.number,
    required this.type,
  });
  final String type;
  final int number;
  @override
  String toString() {
    return "${shortenType(type)}$number";
  }

  static String shortenType(final String type) {
    switch (type) {
      case "Quals":
        return "";
      case "Finals":
        return "f";
      case "Semi finals":
        return "sf";
      case "Quarter finals":
        return "qf";
    }
    throw Exception("Not a supported match type");
  }
}

class PitData {
  PitData({
    required this.driveTrainType,
    required this.driveMotorAmount,
    required this.driveMotorType,
    required this.driveWheelType,
    required this.gearboxPurchased,
    required this.notes,
    required this.hasShifer,
    required this.url,
    required this.faultMessage,
  });
  final String driveTrainType;
  final int driveMotorAmount;
  final String driveWheelType;
  final bool? hasShifer;
  final bool? gearboxPurchased;
  final String driveMotorType;
  final String notes;
  final String url;
  final String? faultMessage;
}

class Team<E extends num> {
  Team({
    required this.team,
    required this.specificData,
    required this.pitViewData,
    required this.quickData,
    required this.climbData,
    required this.scoredMissedDataTele,
    required this.scoredMissedDataAuto,
  });
  final LightTeam team;
  final SpecificData specificData;
  final PitData? pitViewData;
  final QuickData quickData;
  final LineChartData<E> climbData;
  final LineChartData<E> scoredMissedDataTele;
  final LineChartData<E> scoredMissedDataAuto;
}
