import "package:flutter/material.dart";

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(final BuildContext context) => AppBar(
        elevation: 5,
        title: const Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Orbit Scouting",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 30),
          ],
        ),
      );
}
