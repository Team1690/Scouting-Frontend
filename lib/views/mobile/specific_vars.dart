import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class SpecificVars implements HasuraVars {
  LightTeam? team;
  String message = "";
  int? matchesId;
  String name = "";
  bool isRematch = false;

  String? faultMessage;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "team_id": team?.id,
      "message": message,
      "is_rematch": isRematch,
      "matches_id": matchesId,
      "scouter_name": name,
      if (faultMessage != null) "fault_message": faultMessage
    };
  }

  void reset() {
    isRematch = false;
    matchesId = null;
    faultMessage = null;
    team = null;
    message = "";
  }
}
