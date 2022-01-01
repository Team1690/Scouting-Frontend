import 'package:scouting_frontend/views/mobile/hasura_vars.dart';

int climbId(final int i) {
  switch (i) {
    case 0:
      return 4;
    case 1:
      return 2;
    case 2:
    default:
      return 1;
  }
}

class Match implements HasuraVars {
  int teamNumber;
  int matchNumber;

  int teamId;

  int autoUpperGoal = 0;
  int teleOuter = 0;
  int teleInner = 0;

  int climbStatus;

  String matchJson;

  Match({
    this.teamId = 0,
    this.teamNumber = 0,
    this.matchNumber = 0,
    this.autoUpperGoal = 0,
    this.teleOuter = 0,
    this.teleInner = 0,
    this.climbStatus = 1,
  });

  @override
  Map<String, dynamic> toHasuraVars() {
    return {
      "auto_balls": autoUpperGoal,
      "climb_id": climbStatus,
      "number": matchNumber,
      "team_id": teamId,
      "teleop_inner": teleInner,
      "teleop_outer": teleOuter,
      "match_type_id": 1,
      "defended_by": 0,
      "initiation_line": true,
    };
  }
}
