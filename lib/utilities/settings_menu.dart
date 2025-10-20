import 'package:flutter/material.dart';

class SettingsMenu {
  static void show(BuildContext context, GlobalKey key) {
    final overlay = Overlay.of(context);
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 200),
    );

    final fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              // Transparent layer — closes on outside tap
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  controller.reverse().then((_) => overlayEntry.remove());
                },
                child: Container(color: Colors.transparent),
              ),

              // Popup menu positioned relative to the icon
              Positioned(
                top: position.dy + size.height + 5,
                right:
                    MediaQuery.of(context).size.width -
                    (position.dx + size.width),
                child: Material(
                  color: Colors.transparent,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.green,
                              ),
                              title: const Text("Profile"),
                              onTap: () {
                                controller.reverse().then(
                                  (_) => overlayEntry.remove(),
                                );
                                Navigator.pushNamed(context, '/mandiSettings');
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.info_outline,
                                color: Colors.green,
                              ),
                              title: const Text("About"),
                              onTap: () {
                                controller.reverse().then(
                                  (_) => overlayEntry.remove(),
                                );
                                Navigator.pushNamed(context, '/about');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    overlay.insert(overlayEntry);
    controller.forward();
  }
}

class AboutMenu {
  static void show(BuildContext context, GlobalKey key) {
    final overlay = Overlay.of(context);
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 200),
    );

    final fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              // Transparent overlay to close when tapped outside
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  controller.reverse().then((_) => overlayEntry.remove());
                },
                child: Container(color: Colors.transparent),
              ),

              // Popup positioned under the icon
              Positioned(
                top: position.dy + size.height + 5,
                right:
                    MediaQuery.of(context).size.width -
                    (position.dx + size.width),
                child: Material(
                  color: Colors.transparent,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.info_outline,
                                color: Colors.green,
                              ),
                              title: const Text("About"),
                              onTap: () {
                                controller.reverse().then(
                                  (_) => overlayEntry.remove(),
                                );
                                Navigator.pushNamed(context, '/about');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );

    overlay.insert(overlayEntry);
    controller.forward();
  }
}
