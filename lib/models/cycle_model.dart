class Cycle {
  Cycle({
    required this.endTime,
    required this.startingTime,
  });
  final int startingTime;
  final int endTime;
  int getLength() => endTime - startingTime;
}
