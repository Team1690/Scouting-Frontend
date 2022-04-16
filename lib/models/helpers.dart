import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

RobotMatchStatus titleToEnum(final String title) {
  switch (title) {
    case "Worked":
      return RobotMatchStatus.worked;
    case "Didn't come to field":
      return RobotMatchStatus.didntComeToField;
    case "Didn't work on field":
      return RobotMatchStatus.didntWorkOnField;
  }
  throw Exception("Isn't a valid title");
}
