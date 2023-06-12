import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";

import "package:scouting_frontend/net/hasura_helper.dart";

class RobotImage extends StatelessWidget {
  const RobotImage(this.teamId);
  final int teamId;
  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Robot image"),
          centerTitle: true,
        ),
        body: StreamBuilder<QueryResult<Widget>>(
          stream: fetchRobotImageUrl(teamId),
          builder: (
            final BuildContext context,
            final AsyncSnapshot<QueryResult<Widget>> snapshot,
          ) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return snapshot.data.mapNullable(
                  (final QueryResult<Widget> event) => event.mapQueryResult(),
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

  final int? Function() teamId;

  @override
  Widget build(final BuildContext context) => IconButton(
        onPressed: () {
          final int? teamIdInt = teamId();
          if (teamIdInt != null) {
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.of(context).push(
              MaterialPageRoute<RobotImage>(
                builder: (final BuildContext context) => RobotImage(teamIdInt),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text("Cant show photo of team without team selected"),
              ),
            );
          }
        },
        icon: const Icon(Icons.camera_alt),
      );
}

Stream<QueryResult<Widget>> fetchRobotImageUrl(final int teamId) =>
    getClient().subscribe(
      SubscriptionOptions<Widget>(
        variables: <String, dynamic>{"id": teamId},
        parserFn: (final Map<String, dynamic> p0) {
          final Map<String, dynamic>? pit =
              p0["team_by_pk"]["_2023_pit"] as Map<String, dynamic>?;
          return pit.mapNullable(
                (final Map<String, dynamic> p0) => Center(
                  child: CachedNetworkImage(
                    progressIndicatorBuilder: (final _, final __, final ___) =>
                        const CircularProgressIndicator(),
                    imageUrl: p0["url"] as String,
                  ),
                ),
              ) ??
              const Center(
                child: Text(
                  "No pit entry for this team",
                ),
              );
        },
        document: gql(
          r"""
query RobotImage($id: Int!) {
  team_by_pk(id: $id) {
    _2023_pit {
      url
    }
  }
}


""",
        ),
      ),
    );
