import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";

import "package:scouting_frontend/net/hasura_helper.dart";

class RobotImage extends StatelessWidget {
  const RobotImage(this.teamId);
  final int teamId;
  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Robot image"),
          centerTitle: true,
        ),
        body: StreamBuilder<QueryResult>(
          stream: fetchRobotImageUrl(teamId),
          builder: (
            final BuildContext context,
            final AsyncSnapshot<QueryResult> snapshot,
          ) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return snapshot.data.mapNullable(
                  (final QueryResult event) {
                    return event.mapQueryResult(
                      (final Map<String, dynamic>? p0) =>
                          p0.mapNullable<Widget>(
                              (final Map<String, dynamic> p0) {
                            final dynamic pit = p0["team_by_pk"]["pit"];
                            if (pit == null) {
                              return Center(
                                child: Text(
                                  "No pit entry for this team",
                                ),
                              );
                            } else {
                              return Center(
                                child: CachedNetworkImage(
                                  imageUrl: pit["url"] as String,
                                ),
                              );
                            }
                          }) ??
                          (throw Exception("No data")),
                    );
                  },
                ) ??
                (throw Exception("No data"));
          },
        ),
      );
}

class RobotImageButton extends StatelessWidget {
  const RobotImageButton({
    required this.teamId,
  });

  final int? teamId;

  @override
  Widget build(final BuildContext context) => IconButton(
        onPressed: () {
          teamId.mapNullable((final int teamId) {
                ScaffoldMessenger.of(context).clearSnackBars();
                Navigator.of(context).push(
                  MaterialPageRoute<RobotImage>(
                    builder: (final BuildContext context) => RobotImage(teamId),
                  ),
                );
              }) ??
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content:
                      Text("Cant show photo of team without team selected"),
                ),
              );
        },
        icon: Icon(Icons.camera_alt),
      );
}

Stream<QueryResult> fetchRobotImageUrl(final int teamId) {
  return getClient().subscribe(
    SubscriptionOptions(
      variables: <String, dynamic>{"id": teamId},
      document: gql(
        r"""
query MyQuery($id: Int!) {
  team_by_pk(id: $id) {
    pit {
      url
    }
  }
}


""",
      ),
    ),
  );
}
