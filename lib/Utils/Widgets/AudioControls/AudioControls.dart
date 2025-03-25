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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color:
                    audioPlayerState.shuffleModeEnabled
                        ? Colors.orange
                        : Colors.white70,
              ),
              onPressed: () {
                ref.read(audioPlayerProvider.notifier).toggleShuffle();
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: onPrevious,
            ),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;

                if (playing != true) {
                  return IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    iconSize: 64.0,
                    onPressed: player.play,
                  );
                } else if (processingState == ProcessingState.completed) {
                  onNext();
                  return IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    iconSize: 64.0,
                    onPressed: onNext,
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white),
                    iconSize: 64.0,
                    onPressed: player.pause,
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: onNext,
            ),
            IconButton(
              icon: Icon(
                Icons.repeat,
                color:
                    audioPlayerState.loopMode == LoopMode.off
                        ? Colors.white70
                        : Colors.orange,
              ),
              onPressed: () {
                ref.read(audioPlayerProvider.notifier).toggleLoop();
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17.0),
          child: Column(
            children: [
              StreamBuilder<PositionData>(
                stream: Rx.combineLatest3<
                  Duration,
                  Duration,
                  Duration?,
                  PositionData
                >(
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
                  return Column(
                    children: [
                      SeekBar(
                        duration: positionData?.duration ?? Duration.zero,
                        position: positionData?.position ?? Duration.zero,
                        bufferedPosition:
                            positionData?.bufferedPosition ?? Duration.zero,
                        onChangeEnd: player.seek,
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white),
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
              icon: const Icon(Icons.speed, color: Colors.white),
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

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
