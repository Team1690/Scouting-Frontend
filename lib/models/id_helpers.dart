import 'package:graphql/client.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';

class ClimbHelper {
  static Map<String, int> _ids = <String, int>{};

  static int get noAttemptId => _ids["no Attempt"]!;

  static int get failedId => _ids["failed"]!;

  static int get level1Id => _ids["level 1"]!;

  static int get level2Id => _ids["level 2"]!;

  static int get level3Id => _ids["level 3"]!;

  static int get level4Id => _ids["level 4"]!;

  static int climbId(final String i) {
    switch (i) {
      case "Choose a climb result":
      case "No attempt":
        return noAttemptId;
      case "Failed":
        return failedId;
      case "Level 1":
        return level1Id;
      case "Level 2":
        return level2Id;
      case "Level 3":
        return level3Id;
      case "Level 4":
        return level4Id;
    }
    throw Exception("This shouldn't Happen but better to be safe than sorry");
  }

  static Future<void> queryclimbId() async {
    final GraphQLClient client = getClient();
    final String query = """
    query MyQuery {
  climb_2022 {
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
        (climb["climb_2022"] as List<dynamic>).forEach((final dynamic element) {
          switch (element["name"] as String) {
            case "failed":
              _ids["failed"] = element["id"] as int;
              break;
            case "no attempt":
              _ids["no Attempt"] = element["id"] as int;
              break;
            case "level 1":
              _ids["level 1"] = element["id"] as int;
              break;
            case "level 2":
              _ids["level 2"] = element["id"] as int;
              break;
            case "level 3":
              _ids["level 3"] = element["id"] as int;
              break;
            case "level 4":
              _ids["level 4"] = element["id"] as int;
              break;
          }
        });
      }),
    );
  }
}

class DrivetrainHelper {
  static final Map<String, int> _ids = <String, int>{};

  static int get swerveId => _ids["swerve"]!;

  static int get notAnsweredId => _ids["not answered"]!;

  static int get westcoastId => _ids["westcoast"]!;

  static int get kitChassisId => _ids["kit chassis"]!;

  static int get customTankId => _ids["custom tank"]!;

  static int get mecanumHId => _ids["mecanum/H"]!;

  static int get otherId => _ids["other"]!;

  static int getDrivetrainId(final String s) {
    switch (s) {
      case "Choose a DriveTrain":
        return _ids["not answered"]!;
      case "Westcoast":
        return _ids["westcoast"]!;
      case "Kit Chassis":
        return _ids["kit chassis"]!;
      case "Custom Tank":
        return _ids["custom tank"]!;
      case "Swerve":
        return _ids["swerve"]!;
      case "Mecanum/H":
        return _ids["mecanum/H"]!;
      case "Other":
        return _ids["other"]!;
    }
    throw Exception("This shouldn't Happen but better to be safe than sorry");
  }

  static Future<void> queryDrivetrainId() async {
    final GraphQLClient client = getClient();
    final String query = """
query MyQuery {
  drivetrain {
    title
    id
  }
}
    """;
    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));

    result.mapQueryResult(
      (final Map<String, dynamic>? data) => data.mapNullable(
        (final Map<String, dynamic> driveTrain) {
          (driveTrain["drivetrain"] as List<dynamic>)
              .forEach((final dynamic element) {
            switch (element["title"] as String) {
              case "Swerve":
                _ids["swerve"] = element["id"] as int;
                break;
              case "Not answered":
                _ids["not answered"] = element["id"] as int;
                break;
              case "Westcoast":
                _ids["westcoast"] = element["id"] as int;
                break;
              case "Kit chassis":
                _ids["kit chassis"] = element["id"] as int;
                break;
              case "Custom tank":
                _ids["custom tank"] = element["id"] as int;
                break;
              case "Mecanum/H":
                _ids["mecanum/H"] = element["id"] as int;
                break;
              case "Other":
                _ids["other"] = element["id"] as int;
                break;
            }
          });
        },
      ),
    );
  }
}

class DriveMotorHelper {
  static final Map<String, int> _ids = <String, int>{};

  static int get notAnsweredId => _ids["not answered"]!;

  static int get falconId => _ids["falcon"]!;

  static int get neoId => _ids["neo"]!;

  static int get cimId => _ids["cim"]!;

  static int get miniCimId => _ids["mini cim"]!;

  static int get otherId => _ids["other"]!;

  static int getDrivetrainId(final String s) {
    switch (s) {
      case "Choose a Drive Motor":
        return _ids["not answered"]!;
      case "Falcon":
        return _ids["falcon"]!;
      case "Neo":
        return _ids["neo"]!;
      case "CIM":
        return _ids["cim"]!;
      case "Mini CIM":
        return _ids["mini cim"]!;
      case "Other":
        return _ids["other"]!;
    }
    throw Exception("This shouldn't Happen but better to be safe than sorry");
  }

  static Future<void> queryDrivemotorId() async {
    final GraphQLClient client = getClient();
    final String query = """
query MyQuery {
  drivemotor {
    title
    id
  }
}
    """;
    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));

    result.mapQueryResult(
      (final Map<String, dynamic>? data) => data.mapNullable(
        (final Map<String, dynamic> driveTrain) {
          (driveTrain["drivemotor"] as List<dynamic>)
              .forEach((final dynamic element) {
            switch (element["title"] as String) {
              case "Falcon":
                _ids["falcon"] = element["id"] as int;
                break;
              case "Not answered":
                _ids["not answered"] = element["id"] as int;
                break;
              case "Neo":
                _ids["neo"] = element["id"] as int;
                break;
              case "CIM":
                _ids["cim"] = element["id"] as int;
                break;
              case "Mini CIM":
                _ids["mini cim"] = element["id"] as int;
                break;
              case "Other":
                _ids["other"] = element["id"] as int;
                break;
            }
          });
        },
      ),
    );
  }
}
