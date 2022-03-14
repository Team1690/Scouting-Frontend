import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class SpecificVars implements HasuraVars {
  int? teamId;
  String message = "";
  String? faultMessage;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "team_id": teamId,
      "message": message,
      if (faultMessage != null) "fault_message": faultMessage
    };
  }

  void reset() {
    faultMessage = null;
    teamId = null;
    message = "";
  }
}
