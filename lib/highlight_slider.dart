import 'dart:async';
import 'package:flutter/material.dart';

class HighlightSlider extends StatefulWidget {
  const HighlightSlider({super.key});

  @override
  State<HighlightSlider> createState() => _HighlightSliderState();
}

class _HighlightSliderState extends State<HighlightSlider> {

  final PageController controller = PageController();
  int currentPage = 0;

  final List<String> images = [
    "assets/highlight1.jpg",
    "assets/highlight2.jpg",
    "assets/highlight3.jpg",
  ];

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 3), (timer) {

      if (currentPage < images.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }

      controller.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );

    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                images[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}