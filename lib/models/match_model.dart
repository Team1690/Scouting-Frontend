import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";

class Match {
  Match({
    required this.robotMatchStatusId,
  });

  void clear(final BuildContext context) {
    autoConesTop = 0;
    autoConesMid = 0;
    autoConesLow = 0;
    autoConesFailed = 0;
    autoCubesTop = 0;
    autoCubesMid = 0;
    autoCubesLow = 0;
    autoCubesFailed = 0;
    teleConesTop = 0;
    teleConesMid = 0;
    teleConesLow = 0;
    teleConesFailed = 0;
    teleCubesTop = 0;
    teleCubesMid = 0;
    teleCubesLow = 0;
    teleCubesFailed = 0;
    autoBalanceStatus = null;
    endgameBalanceStatus = null;
    scheduleMatch = null;
    isRematch = false;
    robotMatchStatusId =
        IdProvider.of(context).robotMatchStatus.nameToId["Worked"]!;
  }

  bool preScouting = false;
  bool isRematch = false;
  ScheduleMatch? scheduleMatch;
  int autoConesTop = 0;
  int autoConesMid = 0;
  int autoConesLow = 0;
  int autoConesFailed = 0;
  int autoCubesTop = 0;
  int autoCubesMid = 0;
  int autoCubesLow = 0;
  int autoCubesFailed = 0;
  int teleConesTop = 0;
  int teleConesMid = 0;
  int teleConesLow = 0;
  int teleConesFailed = 0;
  int teleCubesTop = 0;
  int teleCubesMid = 0;
  int teleCubesLow = 0;
  int teleCubesFailed = 0;
  String? name;
  int? autoBalanceStatus;
  int? endgameBalanceStatus;
  int robotMatchStatusId;
}
