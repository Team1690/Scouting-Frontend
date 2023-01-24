import "package:flutter/material.dart";

class CounterVars {
  CounterVars({
    required this.plus,
    required this.minus,
    required this.updateValues,
    required this.getValues,
  });
  final Color plus;
  final Color minus;
  final List<void Function(int)> updateValues;
  final List<int Function()> getValues;
}
