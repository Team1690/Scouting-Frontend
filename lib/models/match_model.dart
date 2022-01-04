import 'package:graphql/client.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/mobile/hasura_vars.dart';

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
      "climb_id": ClimbHelper.climbId(climbStatus),
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

extension ClimbHelper on Match {
  static bool querySuccess = false;
  static int _succeeded;
  static int _noAttempt;
  static int _failed;

  static int get successId {
    return _succeeded;
  }

  static int get noAttemptId {
    return _noAttempt;
  }

  static int get failedId {
    return _failed;
  }

  static int climbId(final int i) {
    if (!querySuccess) {
      throw GraphQLError(message: 'climb id query didnt succeed');
    }
    switch (i) {
      case 0:
        return successId;
      case 1:
        return failedId;
      case 2:
      default:
        return noAttemptId;
    }
  }

  static Future<void> queryclimbId() async {
    final client = getClient();
    final query = """
    query MyQuery {
  climb {
    id
    name
  }
}

    """;
    final result = await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) {
      throw result.exception;
    } else if (result.data == null) {
      throw GraphQLError(message: 'No climb ids found');
    } else {
      (result.data['climb']).forEach((element) {
        switch (element["name"] as String) {
          case "failed":
            _failed = element['id'];
            break;
          case "No attempt":
            _noAttempt = element['id'];
            break;
          case "Succeeded":
            _succeeded = element['id'];
            break;
        }
      });
      querySuccess = true;
    }
  }
}
