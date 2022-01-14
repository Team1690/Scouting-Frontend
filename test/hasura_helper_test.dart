import "package:flutter_test/flutter_test.dart";

import "package:graphql/client.dart";

import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";

void main() {
  group("Hasura client", () {
    test("getClient should provide a valid client", () {
      final GraphQLClient client = getClient();
      expect(client, isNotNull);
    });
  });
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
