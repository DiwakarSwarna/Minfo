import 'package:flutter/material.dart';
import 'dart:async';

// Amazon-style Carousel Widget (same as created earlier)
class CarouselItem {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  CarouselItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class AmazonCarousel extends StatefulWidget {
  final List<CarouselItem> items;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration transitionDuration;
  final bool showIndicators;
  final EdgeInsets margin;

  const AmazonCarousel({
    super.key,
    required this.items,
    this.height = 200.0,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.transitionDuration = const Duration(milliseconds: 600),
    this.showIndicators = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  _AmazonCarouselState createState() => _AmazonCarouselState();
}

class _AmazonCarouselState extends State<AmazonCarousel>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );

    _animationController.forward();

    if (widget.autoPlay && widget.items.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      _nextItem();
    });
  }

  void _nextItem() {
    if (widget.items.isEmpty) return;

    _animationController.reverse().then((_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.items.length;
      });
      _animationController.forward();
    });
  }

  void _goToItem(int index) {
    if (index == _currentIndex || widget.items.isEmpty) return;

    _timer?.cancel();

    _animationController.reverse().then((_) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.forward();
    });

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Container(
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('No items to display')),
      );
    }

    final currentItem = widget.items[_currentIndex];

    return Container(
      margin: widget.margin,
      child: Column(
        children: [
          GestureDetector(
            onTap: currentItem.onTap,
            onPanEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx > 200) {
                int prevIndex =
                    _currentIndex == 0
                        ? widget.items.length - 1
                        : _currentIndex - 1;
                _goToItem(prevIndex);
              } else if (details.velocity.pixelsPerSecond.dx < -200) {
                _nextItem();
              }
            },
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Background Image
                    AnimatedSwitcher(
                      duration: widget.transitionDuration,
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: Container(
                        key: ValueKey<String>(currentItem.imageUrl),
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(currentItem.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),

                    // // Title + Subtitle
                    // AnimatedSwitcher(
                    //   duration: widget.transitionDuration,
                    //   switchInCurve: Curves.easeInOut,
                    //   switchOutCurve: Curves.easeInOut,
                    //   child: Container(
                    //     key: ValueKey<String>(
                    //       currentItem.title + currentItem.subtitle,
                    //     ),
                    //     padding: EdgeInsets.all(20),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.end,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           currentItem.title,
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 22,
                    //             fontWeight: FontWeight.bold,
                    //             shadows: [
                    //               Shadow(
                    //                 offset: Offset(0, 2),
                    //                 blurRadius: 4,
                    //                 color: Colors.black.withOpacity(0.7),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //         SizedBox(height: 6),
                    //         Text(
                    //           currentItem.subtitle,
                    //           style: TextStyle(
                    //             color: Colors.white.withOpacity(0.95),
                    //             fontSize: 16,
                    //             shadows: [
                    //               Shadow(
                    //                 offset: Offset(0, 1),
                    //                 blurRadius: 3,
                    //                 color: Colors.black.withOpacity(0.7),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Title + Subtitle (fixed alignment)
                    AnimatedSwitcher(
                      duration: widget.transitionDuration,
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Align(
                        alignment:
                            Alignment
                                .bottomLeft, // 👈 keeps text locked to left bottom
                        key: ValueKey<String>(
                          currentItem.title + currentItem.subtitle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentItem.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                currentItem.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // child: Stack(
                //   children: [
                //     AnimatedBuilder(
                //       animation: _fadeAnimation,
                //       builder: (context, child) {
                //         return Opacity(
                //           opacity: _fadeAnimation.value,
                //           child: Container(
                //             width: double.infinity,
                //             height: double.infinity,
                //             decoration: BoxDecoration(
                //               image: DecorationImage(
                //                 image: NetworkImage(currentItem.imageUrl),
                //                 fit: BoxFit.cover,
                //               ),
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //     Container(
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           begin: Alignment.topCenter,
                //           end: Alignment.bottomCenter,
                //           colors: [
                //             Colors.transparent,
                //             Colors.black.withOpacity(0.4),
                //           ],
                //         ),
                //       ),
                //     ),
                //     AnimatedBuilder(
                //       animation: _fadeAnimation,
                //       builder: (context, child) {
                //         return Opacity(
                //           opacity: _fadeAnimation.value,
                //           child: Container(
                //             padding: EdgeInsets.all(20),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.end,
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text(
                //                   currentItem.title,
                //                   style: TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 22,
                //                     fontWeight: FontWeight.bold,
                //                     shadows: [
                //                       Shadow(
                //                         offset: Offset(0, 2),
                //                         blurRadius: 4,
                //                         color: Colors.black.withOpacity(0.7),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //                 SizedBox(height: 6),
                //                 Text(
                //                   currentItem.subtitle,
                //                   style: TextStyle(
                //                     color: Colors.white.withOpacity(0.95),
                //                     fontSize: 16,
                //                     shadows: [
                //                       Shadow(
                //                         offset: Offset(0, 1),
                //                         blurRadius: 3,
                //                         color: Colors.black.withOpacity(0.7),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //   ],
                // ),
              ),
            ),
          ),
          if (widget.showIndicators && widget.items.length > 1) ...[
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  widget.items.asMap().entries.map((entry) {
                    int index = entry.key;
                    bool isActive = _currentIndex == index;

                    return GestureDetector(
                      onTap: () => _goToItem(index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: isActive ? 28 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              isActive ? Colors.green[700] : Colors.grey[400],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
