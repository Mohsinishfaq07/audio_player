import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Widgets/AudioControls/Seekbar.dart';
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
    final hasNext =
        audioPlayerState.currentIndex < audioPlayerState.songs.length - 1;
    final hasPrevious = audioPlayerState.currentIndex > 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              icon: Icon(
                Icons.skip_previous,
                color: hasPrevious ? Colors.white : Colors.grey,
                size: 40,
              ),
              onPressed: onPrevious,
            ),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;

                // if (processingState == ProcessingState.loading ||
                //     processingState == ProcessingState.buffering) {
                //   return Container(
                //     margin: const EdgeInsets.all(8.0),
                //     width: 64,
                //     height: 64,
                //     child: const CircularProgressIndicator(),
                //   );
                // } else
                if (processingState == ProcessingState.completed) {
                  return IconButton(
                    icon: const Icon(Icons.replay, color: Colors.white),
                    iconSize: 64,
                    onPressed: () async {
                      await player.seek(Duration.zero);
                      // Force the player to prepare again
                      await player.setAudioSource(player.audioSource!);
                      await player.play();
                    },
                  );
                } else if (playing != true) {
                  return IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    iconSize: 64,
                    onPressed: player.play,
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white),
                    iconSize: 64,
                    onPressed: player.pause,
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.skip_next,
                color: hasNext ? Colors.white : Colors.grey,
                size: 40,
              ),
              onPressed: onNext,
            ),
            IconButton(
              icon: Icon(
                audioPlayerState.loopMode == LoopMode.off
                    ? Icons.repeat
                    : audioPlayerState.loopMode == LoopMode.one
                    ? Icons.repeat_one
                    : Icons.repeat,
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
