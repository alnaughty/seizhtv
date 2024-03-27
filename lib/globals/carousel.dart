// ignore_for_file: use_super_parameters

import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedCarousel extends StatefulWidget {
  const AnimatedCarousel({
    Key? key,
    required this.children,
    this.viewportFraction = 1.0,
    this.minValue = 0.0,
    required this.changeDuration,
  }) : super(key: key);
  final List<Widget> children;
  final double viewportFraction;
  final double minValue;
  final Duration changeDuration;
  @override
  State<AnimatedCarousel> createState() => _AnimatedCarouselState();
}

class _AnimatedCarouselState extends State<AnimatedCarousel>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeInFadeOut;
  int _currentPage = 0;
  Timer? timer;
  initTime() {
    timer = Timer.periodic(widget.changeDuration, (time) {
      if (_currentPage == widget.children.length - 1) {
        _currentPage = 0;
      } else {
        _currentPage += 1;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.decelerate,
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  void listener() async {
    _animationController.reset();
    await _animationController.forward();
  }

  @override
  void initState() {
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
    )..addListener(listener);
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeInFadeOut = Tween<double>(
      begin: widget.minValue,
      end: 1.0,
    ).animate(_animationController);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _animationController.forward();
    });
    initTime();
    super.initState();
  }

  @override
  void dispose() {
    stop();
    _pageController.removeListener(listener);
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  stop() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
      timer = null;
    }
  }

  Future<void> reset() async {
    if (timer != null) {
      stop();
      initTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      onPageChanged: (int index) async {
        setState(() {
          _currentPage = index;
        });
        await reset();
      },
      itemCount: widget.children.length,
      itemBuilder: (_, index) => FadeTransition(
        opacity: _fadeInFadeOut,
        child: widget.children[index],
      ),
      controller: _pageController,
      // children: widget.children,
    );
  }
}
