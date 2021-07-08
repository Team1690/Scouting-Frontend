import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CircularProgressBar extends StatefulWidget {
  final double precentage;
  final String fraction;
  final String footer;
  final Color color;

  CircularProgressBar({
    @required this.precentage,
    @required this.fraction,
    @required this.color,
    this.footer,
  });

  @override
  _CircularProgressBarState createState() => _CircularProgressBarState();
}

class _CircularProgressBarState extends State<CircularProgressBar> {
  bool switchText = true;
  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 80,
      lineWidth: 8.0,
      percent: widget.precentage,
      center: AnimatedCrossFade(
        crossFadeState:
            switchText ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 200),
        firstChild: GestureDetector(
          child: Text((widget.precentage * 100).toStringAsFixed(1) + '%'),
          onTap: () => setState(() => switchText = !switchText),
        ),
        secondChild: GestureDetector(
          child: Text(widget.fraction),
          onTap: () => setState(() => switchText = !switchText),
        ),
      ),
      progressColor: widget.color,
      animation: true,
      animationDuration: 1200,
      circularStrokeCap: CircularStrokeCap.round,
      footer: Text(widget.footer),
    );
  }
}
