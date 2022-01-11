import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:graphql/client.dart";

GraphQLClient getClient() {
  final Map<String, String> headers = new Map<String, String>();
  headers["x-hasura-admin-secret"] = dotenv.env['HASURA_ADMIN_SECRET']!;
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

extension MapSnapshot<T> on AsyncSnapshot<T> {
  V mapSnapshot<V>(final V Function(T) f, final V Function() onWaiting,
          final V Function() onNoData) =>
      hasError
          ? throw error!
          : (ConnectionState.waiting == connectionState
              ? onWaiting()
              : (hasData ? f(data!) : onNoData()));
}
