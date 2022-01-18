import "package:flutter/cupertino.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/app.dart";

class ClimbHelper {
  static int climbId(final String i, final BuildContext context) {
    switch (i) {
      case "Choose a climb result":
        return Ids.of(context).climbIds["No attempt"]!;
      default:
        return Ids.of(context).climbIds[i]!;
    }
  }

  static Future<Map<String, int>> queryclimbId() => fetchEnum("climb_2022");
}

class DrivetrainHelper {
  static int getDrivetrainId(final String s, final BuildContext context) {
    switch (s) {
      case "Choose a DriveTrain":
        return Ids.of(context).driveMotorIds["Not answered"]!;
      default:
        return Ids.of(context).driveMotorIds[s]!;
    }
  }

  static Future<Map<String, int>> queryDrivetrainId() =>
      fetchEnum("drivetrain");
}

class DriveMotorHelper {
  static int getDrivetrainId(final String s, final BuildContext context) {
    switch (s) {
      case "Choose a Drive Motor":
        return Ids.of(context).driveTrains["Not answered"]!;
      default:
        return Ids.of(context).driveTrains[s]!;
    }
  }

  static Future<Map<String, int>> queryDrivemotorId() =>
      fetchEnum("drivemotor");
}

Future<Map<String, int>> fetchEnum(final String table) async {
  final String query = """
query {
    $table {
        id
        title
    }
}
""";
  return (await getClient().query(QueryOptions(document: gql(query))))
      .mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable(
          (final Map<String, dynamic> result) => <String, int>{
            for (final dynamic entry in (result[table] as List<dynamic>))
              entry["title"] as String: entry["id"] as int
          },
        ) ??
        (throw Exception("Query $table returned null")),
  );
}
