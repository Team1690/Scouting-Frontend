import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/mobile/team_card.dart';

class RankingTable extends StatefulWidget {
  RankingTable({
    Key key,
    @required this.teams,
  }) : super(key: key);

  final List<Team> teams;

  @override
  _RankingTableState createState() => _RankingTableState();
}

class _RankingTableState extends State<RankingTable> {
  int selectedIndex = -1;
  int sortColumnIndex;
  bool isAscending = true;

  void onSort(int columnIndex, bool ascending) {
    switch (columnIndex) {
      case 1:
        widget.teams.sort((team1, team2) => ascending
            ? team1.teamNumber.compareTo(team2.teamNumber)
            : team2.teamNumber.compareTo(team1.teamNumber));
        break;
      case 2:
        widget.teams.sort((team1, team2) => ascending
            ? team1.averageShots.compareTo(team2.averageShots)
            : team2.averageShots.compareTo(team1.averageShots));
        break;
      case 3:
        widget.teams.sort((team1, team2) => ascending
            ? team1.climbsPerMatches.compareTo(team2.climbsPerMatches)
            : team2.climbsPerMatches.compareTo(team1.climbsPerMatches));
        break;
      case 4:
        widget.teams.sort((team1, team2) => ascending
            ? team1.matchesPlayed.compareTo(team2.matchesPlayed)
            : team2.matchesPlayed.compareTo(team1.matchesPlayed));
        break;
    }
    setState(() {
      this.sortColumnIndex = columnIndex;
      this.isAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        sortColumnIndex: sortColumnIndex,
        sortAscending: isAscending,
        columnSpacing: 15,
        showCheckboxColumn: false,
        columns: [
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('Team'), numeric: false, onSort: onSort),
          DataColumn(label: Text('Shots'), onSort: onSort),
          DataColumn(label: Text('climbs'), onSort: onSort),
          DataColumn(label: Text('Played'), onSort: onSort),
        ],
        rows: List<DataRow>.generate(
          widget.teams.length,
          (index) => DataRow(
            cells: [
              DataCell(Text((index + 1).toString())),
              DataCell(Text(widget.teams[index].teamNumber.toString())),
              DataCell(
                  Text(widget.teams[index].averageShots.toStringAsFixed(2))),
              DataCell(Text(
                  widget.teams[index].climbsPerMatches.toStringAsFixed(2))),
              DataCell(Text('${widget.teams[index].matchesPlayed}')),
            ],
            selected: index == selectedIndex,
            onSelectChanged: (value) {
              setState(() {
                selectedIndex = index;
              });
              showDialog(
                context: context,
                builder: (context) => TeamCard(
                  selectedTeam: widget.teams[index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
