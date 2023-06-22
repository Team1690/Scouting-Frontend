import "package:flutter_test/flutter_test.dart";

import "package:orbit_standard_library/orbit_standard_library.dart";

void main() {
  group("Map Extenstions", () {
    group("Map Nullable", () {
      test("Actually Null", () {
        expect(
          null.mapNullable((final Object? p0) => throw Exception()),
          isNull,
        );
      });

      test("Actually not null", () {
        expect(1.mapNullable(identity), equals(1));
      });

      test("Actually not null", () {
        expect(1.mapNullable((final int one) => one + 1), equals(2));
      });
    });
  });
  group("More examples", () {
    test("demonstrate failure", () {
      expect(false, equals(true), skip: true, reason: "this should fail");
    });
  });
}
