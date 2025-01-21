import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';

class ResizableScreen extends StatelessWidget {
  final Widget bottom;
  final Widget top;
  final SplitViewController controller;

  const ResizableScreen({
    super.key,
    required this.bottom,
    required this.top,
    required this.controller});

  @override
  Widget build(BuildContext context) {
    return SplitView(
        viewMode: SplitViewMode.Vertical,
        gripSize: 5,
        indicator: const SplitIndicator(
          color: Colors.grey,
          viewMode: SplitViewMode.Vertical,
        ),
        activeIndicator: const SplitIndicator(
          color: Colors.blue,
          viewMode: SplitViewMode.Vertical
        ),
        onWeightChanged: (weight) {
          print('New weight: $weight'); // Optional: Debug weight changes
        },
        children: [
          top,
          bottom,
        ],
    );
  }
}

class ScrollableContainer extends StatelessWidget {
  final Widget content;

  const ScrollableContainer({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }
}
