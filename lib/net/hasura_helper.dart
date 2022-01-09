import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:graphql/client.dart";

GraphQLClient getClient() {
  final Map<String, String> headers = new Map<String, String>();
  headers["x-hasura-admin-secret"] =
      "j0eAGMVfVfeYlyUnlTfYVQc64typ3OTfNbJrpQWXrqKp0qQnon7TpNzvabMC1Pi0";
  final HttpLink link = HttpLink(
    "https://orbitdb.hasura.app/v1/graphql",
    defaultHeaders: headers,
  );
  return GraphQLClient(link: link, cache: GraphQLCache());
}

extension MapNullable<A> on A? {
  B? mapNullable<B>(final B Function(A) f) =>
      this == null ? null : f(this as A);
}

extension MapQueryResult on QueryResult {
  T mapQueryResult<T>(final T Function(Map<String, dynamic>?) f) =>
      hasException ? throw exception! : f(data);
}

void ignore<T>(final T _) {}

T identity<T>(final T x) => x;
