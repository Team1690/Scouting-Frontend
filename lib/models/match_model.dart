import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class Match implements HasuraVars {
  Match({
    this.teamId = 0,
    this.teamNumber = 0,
    this.matchNumber = 0,
    this.autoUpperGoal = 0,
    this.teleOuter = 0,
    this.teleInner = 0,
    this.climbStatus = 1,
  });
  int teamNumber;
  int matchNumber;

  int teamId;

  int autoUpperGoal = 0;
  int teleOuter = 0;
  int teleInner = 0;

  int climbStatus;

  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
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
  static Map<String, int> _ids = <String, int>{};

  static int get successId => _ids["succeeded"]!;

  static int get noAttemptId => _ids["noAttempt"]!;

  static int get failedId => _ids["failed"]!;

  static int climbId(final int i) {
    if (!querySuccess) {
      throw Exception("climb id query didnt succeed");
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
    final GraphQLClient client = getClient();
    final String query = """
    query MyQuery {
  climb {
    id
    name
  }
}

    """;
    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));

    result.mapQueryResult(
      (final Map<String, dynamic>? data) =>
          data.mapNullable((final Map<String, dynamic> climb) {
        (climb["climb"] as List<dynamic>).forEach((final dynamic element) {
          switch (element["name"] as String) {
            case "failed":
              _ids["failed"] = element["id"] as int;
              break;
            case "No attempt":
              _ids["noAttempt"] = element["id"] as int;
              break;
            case "Succeeded":
              _ids["succeeded"] = element["id"] as int;
              break;
          }
        });
        querySuccess = true;
      }),
    );
  }
}
