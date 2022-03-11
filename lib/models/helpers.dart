import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

extension Cast<E extends num> on Iterable<E> {
  Iterable<V> castToGeneric<V extends num>() {
    return map((final E e) {
      if (V == int) {
        return e.toInt() as V;
      } else if (V == double) {
        return e.toDouble() as V;
      }
      throw Exception("Shoudn't happen");
    });
  }
}

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

extension SortMatches on List<dynamic> {
  List<dynamic> sortMatches() {
    final List<dynamic> matches = <dynamic>[];
    final List<String> types = const <String>[
      "Quals",
      "Semi finals",
      "Quartes finals",
      "Finals"
    ];
    for (final String i in types) {
      matches.addAll(
        where(
          (final dynamic element) => element["match_type"]["title"] == i,
        ).toList()
          ..sort(
            (final dynamic i, final dynamic j) =>
                (i["match_number"] as int).compareTo(j["match_number"] as int),
          ),
      );
    }

    return matches;
  }
}
