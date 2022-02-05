import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    required this.title,
    required this.body,
    this.titleWidgets = const <Widget>[],
  });

  final String title;
  final Widget body;
  final List<Widget> titleWidgets;

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  // style: TextStyle(fontSize: 10),
                ),
                ...titleWidgets
              ],
            ),
            SizedBox(
              height: defaultPadding,
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
