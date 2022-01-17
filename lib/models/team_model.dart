enum climbOptions {
  climbed,
  faild,
  notAttempted,
}

enum dataPoint {
  x,
  y,
}

class LightTeam {
  LightTeam(this.id, this.number, this.name);
  final int id;
  final int number;
  final String name;
}
