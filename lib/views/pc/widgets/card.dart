import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard(
      {Key key,
      @required this.title,
      @required this.body,
      this.titleWidgets = const []})
      : super(key: key);

  final String title;
  final Widget body;
  final List<Widget> titleWidgets;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
