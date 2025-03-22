import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Widgets/AudioControls/Seekbar.dart';
import 'package:audioplayer/Utils/Widgets/AudioControls/Slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class ControlButtons extends ConsumerWidget {
  final AudioPlayer player;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const ControlButtons(this.player, this.onPrevious, this.onNext, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color:
                    audioPlayerState.shuffleModeEnabled
                        ? Colors.orange
                        : Colors.grey,
              ),
              onPressed: () {
                ref.read(audioPlayerProvider.notifier).toggleShuffle();
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: onPrevious,
            ),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    width: 64.0,
                    height: 64.0,
                    child: const CircularProgressIndicator(),
                  );
                } else if (playing != true) {
                  return IconButton(
                    icon: const Icon(Icons.play_arrow),
                    iconSize: 64.0,
                    onPressed: player.play,
                  );
                } else if (processingState == ProcessingState.completed) {
                  onNext();
                  return IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 64.0,
                    onPressed: onNext,
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.pause),
                    iconSize: 64.0,
                    onPressed: player.pause,
                  );
                }
              },
            ),

            IconButton(icon: const Icon(Icons.skip_next), onPressed: onNext),
            IconButton(
              icon: Icon(
                Icons.repeat,
                color:
                    audioPlayerState.loopMode == LoopMode.off
                        ? Colors.grey
                        : Colors.orange,
              ),
              onPressed: () {
                ref.read(audioPlayerProvider.notifier).toggleLoop();
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  showSliderDialog(
                    context: context,
                    title: "Adjust Volume",
                    divisions: 100,
                    min: 0.0,
                    max: 1.0,
                    value: player.volume,
                    stream: player.volumeStream,
                    onChanged: player.setVolume,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.speed),
                onPressed: () {
                  showSliderDialog(
                    context: context,
                    title: "Adjust Speed",
                    divisions: 10,
                    min: 0.5,
                    max: 2.0,
                    value: player.speed,
                    stream: player.speedStream,
                    onChanged: player.setSpeed,
                  );
                },
              ),
            ],
          ),
        ),
        StreamBuilder<PositionData>(
          stream:
              Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
                player.positionStream,
                player.bufferedPositionStream,
                player.durationStream,
                (position, bufferedPosition, duration) => PositionData(
                  position,
                  bufferedPosition,
                  duration ?? Duration.zero,
                ),
              ),
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return SeekBar(
              duration: positionData?.duration ?? Duration.zero,
              position: positionData?.position ?? Duration.zero,
              bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
              onChangeEnd: player.seek,
            );
          },
        ),
      ],
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
