import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";

class RobotImageCard extends StatelessWidget {
  const RobotImageCard(this.url);

  final String url;
  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "Robot Image",
        body: GestureDetector(
          onTap: () => Navigator.of(context).push<Scaffold>(
            PageRouteBuilder<Scaffold>(
              reverseTransitionDuration: Duration(milliseconds: 700),
              transitionDuration: Duration(milliseconds: 700),
              pageBuilder: (
                final BuildContext context,
                final Animation<double> a,
                final Animation<double> b,
              ) =>
                  GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Scaffold(
                  body: Center(
                    child: Hero(
                      tag: "Robot Image",
                      child: CachedNetworkImage(
                        imageUrl: url,
                        placeholder: (
                          final BuildContext context,
                          final String url,
                        ) =>
                            Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          child: Hero(
            tag: "Robot Image",
            child: CachedNetworkImage(
              width: 240,
              imageUrl: url,
              placeholder: (final BuildContext context, final String url) =>
                  Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );
}
