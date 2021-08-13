import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';

class StatsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      body: AppBar(
        title: Text('Stats'),
      ),
    );
  }
}
