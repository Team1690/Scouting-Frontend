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
    required this.matchesClimbed,
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
  final int matchesClimbed;
}

class SpecificData {
  const SpecificData(this.msg);
  final List<SpecificMatch> msg;
}

class SpecificMatch {
  const SpecificMatch({
    required this.isRematch,
    required this.matchNumber,
    required this.matchTypeId,
    required this.scouterNames,
    required this.drivetrainAndDriving,
    required this.intake,
    required this.placement,
    required this.generalNotes,
    required this.defense,
  });
  final int matchNumber;
  final int matchTypeId;
  final String scouterNames;
  final bool isRematch;

  final String? drivetrainAndDriving;
  final String? intake;
  final String? placement;
  final String? defense;
  final String? generalNotes;

  bool isNull(final String val) {
    switch (val) {
      case "DriveTrain And Driving":
        return drivetrainAndDriving == null ? true : false;
      case "Intake":
        return intake == null ? true : false;
      case "Placement":
        return placement == null ? true : false;
      case "Defense":
        return defense == null ? true : false;
      case "General Notes":
        return generalNotes == null ? true : false;
      case "All":
      default:
        return (drivetrainAndDriving == null &&
                intake == null &&
                placement == null &&
                defense == null &&
                generalNotes == null)
            ? true
            : false;
    }
  }
}

class LineChartData {
  LineChartData({
    required this.points,
    required this.title,
    required this.gameNumbers,
    required this.robotMatchStatuses,
  });
  final List<List<int>> points;
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
      case "Pre scouting":
        return "pre";
      case "Practice":
        return "pra";
      case "Quals":
        return "";
      case "Finals":
        return "f";
      case "Semi finals":
        return "sf";
      case "Quarter finals":
        return "qf";
      case "Round robin":
        return "rb";
      case "Einstein finals":
        return "ef";
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
    required this.weight,
    required this.width,
    required this.length,
  });
  final String driveTrainType;
  final int driveMotorAmount;
  final String driveWheelType;
  final bool? hasShifer;
  final bool? gearboxPurchased;
  final String driveMotorType;
  final String notes;
  final int weight;
  final int width;
  final int length;
  final String url;
  final List<String>? faultMessages;
}

class Team {
  Team({
    required this.team,
    required this.specificData,
    required this.pitViewData,
    required this.quickData,
    required this.autoBalanceData,
    required this.endgameBalanceData,
    required this.scoredMissedDataTeleCones,
    required this.scoredMissedDataAutoCones,
    required this.scoredMissedDataAllCones,
    required this.scoredMissedDataTeleCubes,
    required this.scoredMissedDataAutoCubes,
    required this.scoredMissedDataAllCubes,
    required this.scoredMissedDataAll,
    required this.pointsData,
  });
  final LightTeam team;
  final SpecificData specificData;
  final PitData? pitViewData;
  final QuickData quickData;
  final LineChartData autoBalanceData;
  final LineChartData endgameBalanceData;
  final LineChartData pointsData;
  final LineChartData scoredMissedDataTeleCones;
  final LineChartData scoredMissedDataAutoCones;
  final LineChartData scoredMissedDataAllCones;
  final LineChartData scoredMissedDataTeleCubes;
  final LineChartData scoredMissedDataAutoCubes;
  final LineChartData scoredMissedDataAllCubes;
  final LineChartData scoredMissedDataAll;
}
