import 'dart:math';

import 'package:ScoutingFrontend/TeamData.dart';
import 'package:flutter/material.dart';

class Rank extends StatefulWidget {
  @override
  _RankState createState() => _RankState();
}

class _RankState extends State<Rank> {
  static const int numItems = 10;
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        // vertical: 20,
      ),
      child: DataTable(
        sortColumnIndex: 1,
        sortAscending: true,
        columnSpacing: 10,
        showCheckboxColumn: false,
        columns: [
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('Team Number'), numeric: false),
          DataColumn(label: Text('Shots in target')),
          DataColumn(label: Text('climbs')),
        ],
        rows: List<DataRow>.generate(
          10,
          (index) => DataRow(
              color: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected))
                  return Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.05);
              }),
              cells: [
                DataCell(Text('$index')),
                DataCell(Text('2459')),
                DataCell(Text('23597')),
                DataCell(Text('23597')),
              ],
              selected: index == selectedIndex,
              onSelectChanged: (value) {
                setState(() {
                  selectedIndex = index;
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return TeamData();
                  },
                );
              }),
        ),
        // rows: [
        //   DataRow(cells: [
        //     DataCell(Text('1')),
        //     DataCell(Text('1690')),
        //     DataCell(Text('47')),
        //     DataCell(Text('5')),
        //   ]),
        //   DataRow(cells: [
        //     DataCell(Text('2')),
        //     DataCell(Text('3339')),
        //     DataCell(Text('0')),
        //     DataCell(Text('3')),
        //   ]),
        //   DataRow(cells: [
        //     DataCell(Text('3')),
        //     DataCell(Text('1574')),
        //     DataCell(Text('15')),
        //     DataCell(Text('10')),
        //   ]),
        // ],
      ),
    );
  }
}
