import 'package:flutter/material.dart';

class SeekBar extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          min: 0.0,
          max: duration.inMilliseconds.toDouble(),
          value: position.inMilliseconds.toDouble().clamp(
            0.0,
            duration.inMilliseconds.toDouble(),
          ),
          onChanged: (value) {
            if (onChanged != null) {
              onChanged!(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (onChangeEnd != null) {
              onChangeEnd!(Duration(milliseconds: value.round()));
            }
          },
        ),
        Text(
          '${position.toString().split('.').first} / ${duration.toString().split('.').first}',
          style: TextStyle(fontSize: 12.0),
        ),
      ],
    );
  }
}
