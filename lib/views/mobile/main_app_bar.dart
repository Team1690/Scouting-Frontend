import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(final BuildContext context) {
    return AppBar(
      elevation: 5,
      title: Row(
        children: [
          Expanded(
            child: const Text(
              'Orbit Scouting',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 30),
        ],
      ),
    );
  }
}
