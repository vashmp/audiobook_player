import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class AudioWave extends StatefulWidget {
  final int barCount;
  final double barWidth;
  final Color color;
  final double minHeight;
  final double maxHeight;
  final Duration duration;
  final double spacing;

  const AudioWave({
    Key? key,
    this.barCount = 5,
    this.barWidth = 10.0,
    this.color = Colors.deepPurple,
    this.minHeight = 20.0,
    this.maxHeight = 100.0,
    this.duration = const Duration(milliseconds: 300),
    this.spacing = 6.0,
  }) : super(key: key);

  @override
  State<AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWave> {
  late List<double> barHeights;
  late Timer timer;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    barHeights = List.generate(widget.barCount, (_) => _randomHeight());
    timer = Timer.periodic(widget.duration, (_) {
      setState(() {
        barHeights = List.generate(widget.barCount, (_) => _randomHeight());
      });
    });
  }

  double _randomHeight() =>
      random.nextDouble() * (widget.maxHeight - widget.minHeight) +
      widget.minHeight;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget _buildBar(double height) {
    return AnimatedContainer(
      duration: widget.duration,
      width: widget.barWidth,
      height: height,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: barHeights
          .map((height) => Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                child: _buildBar(height),
              ))
          .toList(),
    );
  }
}
