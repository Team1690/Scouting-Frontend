import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";

class SpecificVars {
  LightTeam? team;
  String? drivetrainAndDriving;
  String? intake;
  String? placement;
  String? defense;
  String? generalNotes;
  ScheduleMatch? scheduleMatch;
  String name = "";
  bool isRematch = false;

  String? faultMessage;

  void reset() {
    isRematch = false;
    scheduleMatch = null;
    faultMessage = null;
    team = null;
    drivetrainAndDriving = null;
    intake = null;
    placement = null;
    defense = null;
    generalNotes = null;
  }
}
