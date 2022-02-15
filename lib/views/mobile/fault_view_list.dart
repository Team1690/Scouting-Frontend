import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view.dart";

class FaultViewList extends StatefulWidget {
  const FaultViewList(this.data, this.onChange);
  final List<FaultTeam> data;
  final void Function(int, bool) onChange;
  @override
  _FaultViewListState createState() => _FaultViewListState();
}

class _FaultViewListState extends State<FaultViewList> {
  late final Map<int, bool> idToVal = <int, bool>{
    for (FaultTeam team in widget.data) team.team.id: false
  };
  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: Column(
        children: widget.data
            .map(
              (final FaultTeam e) => Card(
                elevation: 2,
                color: bgColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding / 4),
                  child: ExpansionTile(
                    trailing: Checkbox(
                      activeColor: primaryColor,
                      checkColor: Colors.white,
                      value: idToVal[e.team.id],
                      onChanged: (final bool? newVal) {
                        widget.onChange(e.team.id, newVal!);
                        setState(() {
                          idToVal[e.team.id] = newVal;
                        });
                      },
                    ),
                    title: Text(
                      "${e.team.number} ${e.team.name}",
                    ),
                    children: <Widget>[
                      ListTile(
                        title: Text(e.faultMessage),
                      )
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
