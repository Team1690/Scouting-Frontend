import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";

class ClimbHelper {
  static final Map<String, int> _ids = <String, int>{};

  static int climbId(final String i) {
    switch (i) {
      case "Choose a climb result":
        return _ids["No attempt"]!;
      default:
        return _ids[i]!;
    }
  }

  static Future<void> queryclimbId() async {
    _ids.addAll(await fetchEnum("climb_2022"));
  }
}

class DrivetrainHelper {
  static final Map<String, int> _ids = <String, int>{};

  static int getDrivetrainId(final String s) {
    switch (s) {
      case "Choose a DriveTrain":
        return _ids["Not answered"]!;
      default:
        return _ids[s]!;
    }
  }

  static Future<void> queryDrivetrainId() async {
    _ids.addAll(await fetchEnum("drivetrain"));
  }
}

class DriveMotorHelper {
  static final Map<String, int> _ids = <String, int>{};

  static int getDrivetrainId(final String s) {
    switch (s) {
      case "Choose a Drive Motor":
        return _ids["Not answered"]!;
      default:
        return _ids[s]!;
    }
  }

  static Future<void> queryDrivemotorId() async {
    _ids.addAll(await fetchEnum("drivemotor"));
  }
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
        (throw Exception("")),
  );
}
