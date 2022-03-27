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
    required this.highestLevelTitle,
    required this.firstPicklistIndex,
    required this.secondPicklistIndex,
    required this.amoutOfMatches,
  });
  final int amoutOfMatches;
  final double avgBallPoints;
  final double avgClimbPoints;
  final double avgAutoUpperScored;
  final double avgAutoMissed;
  final double avgAutoLowScored;
  final double avgTeleUpperScored;
  final double avgTeleMissed;
  final double avgTeleLowScored;
  final String highestLevelTitle;
  final int firstPicklistIndex;
  final int secondPicklistIndex;
}

class SpecificData {
  const SpecificData(this.msg);
  final List<SpecificMatch> msg;
}

class SpecificMatch {
  const SpecificMatch({
    required this.message,
    required this.isRematch,
    required this.matchNumber,
    required this.matchTypeId,
    required this.scouterNames,
  });
  final String message;
  final int matchNumber;
  final int matchTypeId;
  final String scouterNames;
  final bool isRematch;
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
    required this.isRematch,
  });
  final String type;
  final int number;
  final bool isRematch;

  @override
  bool operator ==(final Object other) =>
      other is MatchIdentifier &&
      other.type == type &&
      other.number == number &&
      other.isRematch == isRematch;

  @override
  int get hashCode => Object.hash(type, number, isRematch);

  @override
  String toString() {
    return "${isRematch ? "R" : ""}${shortenType(type)}$number";
  }

  static String shortenType(final String type) {
    switch (type) {
      case "Practice":
        return "pr";
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
    required this.faultMessages,
  });
  final String driveTrainType;
  final int driveMotorAmount;
  final String driveWheelType;
  final bool? hasShifer;
  final bool? gearboxPurchased;
  final String driveMotorType;
  final String notes;
  final String url;
  final List<String>? faultMessages;
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
    required this.scoredMissedDataAll,
    required this.pointsData,
  });
  final LightTeam team;
  final SpecificData specificData;
  final PitData? pitViewData;
  final QuickData quickData;
  final LineChartData<E> climbData;
  final LineChartData<E> pointsData;
  final LineChartData<E> scoredMissedDataTele;
  final LineChartData<E> scoredMissedDataAuto;
  final LineChartData<E> scoredMissedDataAll;
}
