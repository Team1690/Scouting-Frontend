import "package:collection/collection.dart";

extension AverageOrNull<T extends num> on List<T> {
  double? get averageOrNull => isEmpty ? null : average;
}
