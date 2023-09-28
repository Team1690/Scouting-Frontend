import "package:flutter/material.dart";

import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/screens/input_view.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class EditTechnicalMatch extends StatelessWidget {
  const EditTechnicalMatch({
    required this.matchIdentifier,
    required this.teamForQuery,
  });
  final MatchIdentifier matchIdentifier;
  final LightTeam teamForQuery;

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "${matchIdentifier.type} ${matchIdentifier.number}, team ${teamForQuery.number}",
          ),
        ),
        body: FutureBuilder<Match>(
          future: fetchTechnicalMatch(matchIdentifier, teamForQuery, context),
          builder: (
            final BuildContext context,
            final AsyncSnapshot<Match> snapshot,
          ) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return UserInput(snapshot.data);
            }
          },
        ),
      );
}

const String query = """
query TechnicalMatch(\$team_id: Int!, \$match_type_id: Int!, \$is_rematch: Boolean!, \$match_number: Int!) {
  _2023_technical_match(where: {team_id: {_eq: \$team_id}, match: {match_type_id: {_eq: \$match_type_id},match_number: {_eq: \$match_number}}, is_rematch: {_eq: \$is_rematch}}){
    auto_balance_id
    auto_cones_delivered
    auto_cones_failed
    auto_cones_low
    auto_cones_mid
    auto_cones_top
    auto_cubes_delivered
    auto_cubes_failed
    auto_cubes_low
    auto_cubes_mid
    auto_cubes_top
    auto_mobility
    balanced_with
    endgame_balance_id
    id
    ignored
    is_rematch
    robot_match_status_id
    schedule_match_id
    scouter_name
    starting_position_id
    team_id
    tele_cones_delivered
    tele_cones_failed
    tele_cones_low
    tele_cones_mid
    tele_cones_top
    tele_cubes_delivered
    tele_cubes_failed
    tele_cubes_low
    tele_cubes_mid
    tele_cubes_top
  }
}


""";

Future<Match> fetchTechnicalMatch(
  final MatchIdentifier matchIdentifier,
  final LightTeam teamForQuery,
  final BuildContext context,
) async {
  final GraphQLClient client = getClient();

  final QueryResult<Match> result = await client.query(
    QueryOptions<Match>(
      parserFn: (final Map<String, dynamic> technicalMatch) {
        final Map<String, dynamic> match =
            technicalMatch["_2023_technical_match"] != null
                ? technicalMatch["_2023_technical_match"][0]
                    as Map<String, dynamic>
                : throw Exception("that match doesnt exist");
        final int robotMatchStatusId = match["robot_match_status_id"] as int;

        final int autoConesDelivered = match["auto_cones_delivered"] as int;
        final int autoConesFailed = match["auto_cones_failed"] as int;
        final int autoConesLow = match["auto_cones_low"] as int;
        final int autoConesMid = match["auto_cones_mid"] as int;
        final int autoConesTop = match["auto_cones_top"] as int;

        final int autoCubesDelivered = match["auto_cubes_delivered"] as int;
        final int autoCubesFailed = match["auto_cubes_failed"] as int;
        final int autoCubesLow = match["auto_cubes_low"] as int;
        final int autoCubesMid = match["auto_cubes_mid"] as int;
        final int autoCubesTop = match["auto_cubes_top"] as int;

        final int teleConesDelivered = match["tele_cones_delivered"] as int;
        final int teleConesFailed = match["tele_cones_failed"] as int;
        final int teleConesLow = match["tele_cones_low"] as int;
        final int teleConesMid = match["tele_cones_mid"] as int;
        final int teleConesTop = match["tele_cones_top"] as int;

        final int teleCubesDelivered = match["tele_cubes_delivered"] as int;
        final int teleCubesFailed = match["tele_cubes_failed"] as int;
        final int teleCubesLow = match["tele_cubes_low"] as int;
        final int teleCubesMid = match["tele_cubes_mid"] as int;
        final int teleCubesTop = match["tele_cubes_top"] as int;

        final int? balancedWith = match["balanced_with"] as int?;

        final bool isRematch = match["is_rematch"] as bool;

        final bool mobility = match["auto_mobility"] as bool;

        final int startingPositionId = match["starting_position_id"] as int;
        final Match matchData = Match(
          robotMatchStatusId: robotMatchStatusId,
          autoConesDelivered: autoConesDelivered,
          autoConesFailed: autoConesFailed,
          autoConesLow: autoConesLow,
          autoConesMid: autoConesMid,
          autoConesTop: autoConesTop,
          autoCubesDelivered: autoCubesDelivered,
          autoCubesFailed: autoCubesFailed,
          autoCubesLow: autoCubesLow,
          autoCubesMid: autoCubesMid,
          autoCubesTop: autoCubesTop,
          teleConesDelivered: teleConesDelivered,
          teleConesFailed: teleConesFailed,
          teleConesLow: teleConesLow,
          teleConesMid: teleConesMid,
          teleConesTop: teleConesTop,
          teleCubesDelivered: teleCubesDelivered,
          teleCubesFailed: teleCubesFailed,
          teleCubesLow: teleCubesLow,
          teleCubesMid: teleCubesMid,
          teleCubesTop: teleCubesTop,
          balancedWith: balancedWith,
          isRematch: isRematch,
          mobility: mobility,
          scoutedTeam: teamForQuery,
          startingPositionId: startingPositionId,
        );
        matchData.autoBalanceStatus = match["auto_balance_id"] as int;
        matchData.endgameBalanceStatus = match["endgame_balance_id"] as int;
        matchData.name = match["scouter_name"] as String;
        matchData.scheduleMatch =
            MatchesProvider.of(context).matches.firstWhere(
                  (final ScheduleMatch element) =>
                      element.matchNumber == matchIdentifier.number &&
                      element.matchTypeId ==
                          IdProvider.of(context)
                              .matchType
                              .nameToId[matchIdentifier.type],
                );
        return matchData;
      },
      document: gql(query),
      variables: <String, dynamic>{
        "team_id": teamForQuery.id,
        "match_type_id":
            IdProvider.of(context).matchType.nameToId[matchIdentifier.type],
        "match_number": matchIdentifier.number,
        "is_rematch": matchIdentifier.isRematch,
      },
    ),
  );
  return result.mapQueryResult();
}
