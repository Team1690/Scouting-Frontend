import "package:flutter/material.dart";

import "../../constants.dart";

class ScoutingSpecific extends StatelessWidget {
  const ScoutingSpecific({
    required this.msg,
  });

  final List<String> msg;

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: msg
            .map(
              (final String e) => Card(
                // shape: ,
                elevation: 10,
                color: bgColor,
                margin: EdgeInsets.fromLTRB(5, 0, 5, defaultPadding),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 110,
                        child: Text(
                          e,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: primaryWhite, fontSize: 12),
                        ),
                      ),
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
