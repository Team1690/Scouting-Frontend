import "package:scouting_frontend/models/team_model.dart";

class QuickData {
  QuickData({
    required this.avgBalancePartners,
    required this.avgAutoBalancePoints,
    required this.avgEndgameBalancePoints,
    required this.avgAutoConesTop,
    required this.avgAutoConesMid,
    required this.avgAutoConesLow,
    required this.avgAutoConesDelivered,
    required this.avgAutoConesFailed,
    required this.avgTeleConesTop,
    required this.avgTeleConesMid,
    required this.avgTeleConesLow,
    required this.avgTeleConesDelivered,
    required this.avgTeleConesFailed,
    required this.avgAutoCubesTop,
    required this.avgAutoCubesMid,
    required this.avgAutoCubesLow,
    required this.avgAutoCubesDelivered,
    required this.avgAutoCubesFailed,
    required this.avgTeleCubesTop,
    required this.avgTeleCubesMid,
    required this.avgTeleCubesLow,
    required this.avgTeleCubesDelivered,
    required this.avgTeleCubesFailed,
    required this.matchesBalancedAuto,
    required this.matchesBalancedEndgame,
    required this.highestBalanceTitleAuto,
    required this.firstPicklistIndex,
    required this.secondPicklistIndex,
    required this.amoutOfMatches,
    required this.avgGamepiecePoints,
    required this.avgGamepieces,
    required this.avgAutoGamepieces,
    required this.avgTeleGamepieces,
    required this.avgDelivered,
  });
  final int amoutOfMatches;
  final double avgGamepiecePoints;
  final double avgAutoConesTop;
  final double avgAutoConesMid;
  final double avgAutoConesLow;
  final double avgAutoConesDelivered;
  final double avgAutoConesFailed;
  final double avgTeleConesTop;
  final double avgTeleConesMid;
  final double avgTeleConesLow;
  final double avgTeleConesDelivered;
  final double avgTeleConesFailed;
  final double avgAutoCubesTop;
  final double avgAutoCubesMid;
  final double avgAutoCubesLow;
  final double avgAutoCubesDelivered;
  final double avgAutoCubesFailed;
  final double avgTeleCubesTop;
  final double avgTeleCubesMid;
  final double avgTeleCubesLow;
  final double avgTeleCubesDelivered;
  final double avgTeleCubesFailed;
  final String highestBalanceTitleAuto;
  final int firstPicklistIndex;
  final int secondPicklistIndex;
  final int matchesBalancedAuto;
  final int matchesBalancedEndgame;
  final double avgAutoBalancePoints;
  final double avgEndgameBalancePoints;
  final double avgGamepieces;
  final double avgDelivered;
  final double avgAutoGamepieces;
  final double avgTeleGamepieces;
  final double avgBalancePartners;
}

class AutoByPosData {
  AutoByPosData({
    required this.matchesBalancedAuto,
    required this.highestBalanceTitleAuto,
    required this.amoutOfMatches,
    required this.avgAutoGampepiecePoints,
    required this.avgAutoDelivered,
    required this.avgBalancePoints,
  });
  final int amoutOfMatches;
  final String highestBalanceTitleAuto;
  final int matchesBalancedAuto;
  final double avgAutoDelivered;
  final double avgAutoGampepiecePoints;
  final double avgBalancePoints;
}

class AutoData {
  AutoData({
    required this.dataNearGate,
    required this.middleData,
    required this.nearFeederData,
  });
  final AutoByPosData nearFeederData;
  final AutoByPosData middleData;
  final AutoByPosData dataNearGate;
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
      case "Drivetrain And Driving":
        return drivetrainAndDriving == null;
      case "Intake":
        return intake == null;
      case "Placement":
        return placement == null;
      case "Defense":
        return defense == null;
      case "General Notes":
        return generalNotes == null;
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
  String toString() => "${isRematch ? "R" : ""}${shortenType(type)}$number";

  static String shortenType(final String matchType) {
    switch (matchType) {
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
      case "Double elims":
        return "de";
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
    required this.hasGroundIntake,
    required this.canScoreTop,
    required this.spaceBetweenWheels,
  });
  final int spaceBetweenWheels;
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
  final bool hasGroundIntake;
  final bool canScoreTop;
}

class Team {
  Team({
    required this.team,
    required this.specificData,
    required this.pitViewData,
    required this.quickData,
    required this.autoBalanceData,
    required this.endgameBalanceData,
    required this.teleConesData,
    required this.autoConesData,
    required this.allConesData,
    required this.teleCubesData,
    required this.autoCubesData,
    required this.allCubesData,
    required this.allData,
    required this.pointsData,
    required this.autoData,
  });
  final LightTeam team;
  final SpecificData specificData;
  final PitData? pitViewData;
  final QuickData quickData;
  final LineChartData autoBalanceData;
  final LineChartData endgameBalanceData;
  final LineChartData pointsData;
  final LineChartData teleConesData;
  final LineChartData autoConesData;
  final LineChartData allConesData;
  final LineChartData teleCubesData;
  final LineChartData autoCubesData;
  final LineChartData allCubesData;
  final LineChartData allData;
  final AutoData autoData;
}
