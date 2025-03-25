import 'package:flutter/material.dart';

class SeekBar extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left time text
        Text(
          _formatDuration(position),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        // Expanded slider
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Slider(
              activeColor: Colors.orange,
              inactiveColor: Colors.white24,
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
          ),
        ),
        // Right time text
        Text(
          _formatDuration(duration),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
