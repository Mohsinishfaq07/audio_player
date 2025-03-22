import 'package:flutter/material.dart';

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: StreamBuilder<double>(
            stream: stream,
            builder: (context, snapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${snapshot.data?.toStringAsFixed(1)}'),
                  Slider(
                    divisions: divisions,
                    min: min,
                    max: max,
                    value: snapshot.data ?? value,
                    onChanged: onChanged,
                  ),
                ],
              );
            },
          ),
        ),
  );
}
