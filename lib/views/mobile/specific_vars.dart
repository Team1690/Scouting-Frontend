import 'package:scouting_frontend/models/matches_model.dart';
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class SpecificVars implements HasuraVars {
  LightTeam? team;
  String message = "";
  ScheduleMatch? matches;
  String name = "";
  bool isRematch = false;

  String? faultMessage;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "team_id": team?.id,
      "message": message,
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
    message = "";
  }
}
