import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";

class CarouselWithIndicator extends StatefulWidget {
  CarouselWithIndicator({
    required this.widgets,
    this.direction = Axis.horizontal,
    this.initialPage = 0,
    this.enableInfininteScroll = true,
  });
  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }

  final bool enableInfininteScroll;
  final int initialPage;
  final Axis direction;
  final List<Widget> widgets;
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  late int _current = widget.initialPage;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(final BuildContext context) {
    return Flex(
      direction:
          widget.direction == Axis.vertical ? Axis.horizontal : Axis.vertical,
      children: <Widget>[
        Expanded(
          child: CarouselSlider(
            items: widget.widgets,
            carouselController: _controller,
            options: CarouselOptions(
              enableInfiniteScroll: widget.enableInfininteScroll,
              initialPage: widget.initialPage,
              scrollDirection: widget.direction,
              height: 3500,
              aspectRatio: 2.0,
              viewportFraction: 1,
              onPageChanged:
                  (final int index, final CarouselPageChangedReason reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ),
        ),
        Flex(
          direction: widget.direction,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(
            widget.widgets.length,
            (final int index) => GestureDetector(
              onTap: () => _controller.animateToPage(index),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(_current == index ? 0.9 : 0.4),
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }
}
