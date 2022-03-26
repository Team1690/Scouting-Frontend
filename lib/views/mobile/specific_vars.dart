import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class SpecificVars implements HasuraVars {
  int? teamId;
  String message = "";
  int? matchNumber;
  int? matchTypeId;
  String name = "";
  bool isRematch = false;

  String? faultMessage;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "team_id": teamId,
      "message": message,
      "is_rematch": isRematch,
      "match_number": matchNumber,
      "match_type_id": matchTypeId,
      "scouter_name": name,
      if (faultMessage != null) "fault_message": faultMessage
    };
  }

  void reset() {
    matchTypeId = null;
    isRematch = false;
    matchNumber = null;
    faultMessage = null;
    teamId = null;
    message = "";
  }
}
