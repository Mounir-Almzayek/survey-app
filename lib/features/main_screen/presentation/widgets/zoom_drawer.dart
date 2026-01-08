import 'dart:math';
import 'package:flutter/material.dart';

class ZoomDrawerController extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void close() {
    _isOpen = false;
    notifyListeners();
  }
}

class ZoomDrawer extends StatefulWidget {
  final Widget menuScreen;
  final Widget mainScreen;
  final ZoomDrawerController controller;

  const ZoomDrawer({
    super.key,
    required this.menuScreen,
    required this.mainScreen,
    required this.controller,
  });

  @override
  State<ZoomDrawer> createState() => _ZoomDrawerState();

  static ZoomDrawerController? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ZoomDrawer>()?.controller;
  }
}

class _ZoomDrawerState extends State<ZoomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderRadiusAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo),
    );

    // Slide distance depends on screen width, calculated in build

    _borderRadiusAnimation = Tween<double>(begin: 0.0, end: 32.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: -pi / 24).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo),
    );

    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (widget.controller.isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxSlide = screenWidth * 0.7; // Slide 70% of screen width

    return Stack(
      children: [
        // Menu (Background)
        widget.menuScreen,

        // Main Screen (Foreground with Transform)
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            double slide = maxSlide * _animationController.value;
            double scale = _scaleAnimation.value;
            double rotate = _rotateAnimation.value;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..translate(slide)
                ..rotateY(rotate)
                ..scale(scale),
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  _borderRadiusAnimation.value,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(-20, 20),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      widget.mainScreen,
                      if (_animationController.value > 0)
                        GestureDetector(
                          onTap: widget.controller.close,
                          child: Container(color: Colors.transparent),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
