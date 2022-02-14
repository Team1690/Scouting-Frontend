import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class SpecificVars implements HasuraVars {
  int? teamId;
  String message = "";
  int? roleId;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "team_id": teamId,
      "message": message,
      "robot_role_id": roleId
    };
  }

  void reset() {
    teamId = null;
    message = "";
    roleId = null;
  }
}
