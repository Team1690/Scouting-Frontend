import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/pc/rating_picklist/fetch_rating_picklist.dart";
import "package:scouting_frontend/views/pc/rating_picklist/rating_pick_list_card.dart";
import "package:scouting_frontend/views/pc/rating_picklist/rating_pick_list_widget.dart";

class RatingPickListScreen extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => isPC(context)
      ? DashboardScaffold(
          body: pickList(context),
        )
      : Scaffold(
          appBar: AppBar(
            title: const Text("Rating Picklist"),
            centerTitle: true,
          ),
          drawer: SideNavBar(),
          body: pickList(context),
        );

  Padding pickList(final BuildContext context) => Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: StreamBuilder<List<RatingPickListTeam>>(
          stream: fetchRatingPicklist(),
          builder: (
            final BuildContext context,
            final AsyncSnapshot<List<RatingPickListTeam>> snapshot,
          ) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == null) {
              return const Center(
                child: Text("No Teams"),
              );
            }
            return RatingPicklistCard(initialData: snapshot.data!);
          },
        ),
      );
}

void save(
  final List<RatingPickListTeam> teams, [
  final BuildContext? context,
]) async {
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text("Saving", style: TextStyle(color: Colors.white))
          ],
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
  final GraphQLClient client = getClient();
  const String query = """
  mutation UpdatePicklist(\$objects: [team_insert_input!]!) {
  insert_team(objects: \$objects, on_conflict: {constraint: team_pkey, update_columns: [taken, defense_picklist_index, drive_picklist_index,feeder_picklist_index,ground_picklist_index]}) {
    affected_rows
    returning {
      id
    }
  }
}

  """;

  final Map<String, dynamic> vars = <String, dynamic>{
    "objects": teams
        .map(
          (final RatingPickListTeam e) => <String, dynamic>{
            "id": e.team.id,
            "name": e.team.name,
            "number": e.team.number,
            "colors_index": e.team.colorsIndex,
            "defense_picklist_index": e.defenseListIndex,
            "drive_picklist_index": e.driveListIndex,
            "feeder_picklist_index": e.feederListIndex,
            "ground_picklist_index": e.groundListIndex,
            "taken": e.taken
          },
        )
        .toList()
  };

  final QueryResult<void> result = await client
      .mutate(MutationOptions<void>(document: gql(query), variables: vars));
  if (context != null) {
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text("Error: ${result.exception}"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                "Saved",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

enum CurrentRatingPickList { defense, drive, feeder, ground }

extension CurrentRatingPickListExtension on CurrentRatingPickList {
  T map<T>(
    final T Function() onDefense,
    final T Function() onDrive,
    final T Function() onFeeder,
    final T Function() onGround,
  ) {
    switch (this) {
      case CurrentRatingPickList.defense:
        return onDefense();
      case CurrentRatingPickList.drive:
        return onDrive();
      case CurrentRatingPickList.feeder:
        return onFeeder();
      case CurrentRatingPickList.ground:
        return onGround();
    }
  }

  double getRating(final RatingPickListTeam team) => map(
        () => team.defenseRating,
        () => team.driveRating,
        () => team.feederRating,
        () => team.groundRating,
      );
  int getIndex(final RatingPickListTeam team) => map(
        () => team.defenseListIndex,
        () => team.driveListIndex,
        () => team.feederListIndex,
        () => team.groundListIndex,
      );

  int setIndex(final RatingPickListTeam team, final int index) => map(
        () => team.defenseListIndex = index,
        () => team.driveListIndex = index,
        () => team.feederListIndex = index,
        () => team.groundListIndex = index,
      );
}
