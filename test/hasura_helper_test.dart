import "package:flutter_test/flutter_test.dart";

import "package:graphql/client.dart";

import "package:scouting_frontend/net/hasura_helper.dart";

void main() {
  group("Hasura client", () {
    test("getClient should provide a valid client", () {
      final GraphQLClient client = getClient();
      expect(client, isNotNull);
    });
  });
  group("More examples", () {
    test("demonstrate failure", () {
      expect(false, equals(true), skip: true, reason: "this should fail");
    });
  });
}
