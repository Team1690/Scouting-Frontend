import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class SpecificVars implements HasuraVars {
  LightTeam? team;
  String? drivetrainAndDriving;
  String? intakeAndConveyor;
  String? shooter;
  String? climb;
  String? defense;
  String? generalNotes;
  ScheduleMatch? matches;
  String name = "";
  bool isRematch = false;

  String? faultMessage;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "team_id": team?.id,
      "drivetrain_and_driving": drivetrainAndDriving,
      "intake_and_conveyor": intakeAndConveyor,
      "shooter": shooter,
      "climb": climb,
      "defense": defense,
      "general_notes": generalNotes,
      "is_rematch": isRematch,
      "matches_id": matches?.id,
      "scouter_name": name,
      if (faultMessage != null) "fault_message": faultMessage
    };
  }

  void reset() {
    isRematch = false;
    matches = null;
    faultMessage = null;
    team = null;
    drivetrainAndDriving = null;
    intakeAndConveyor = null;
    shooter = null;
    climb = null;
    defense = null;
    generalNotes = null;
  }
}
