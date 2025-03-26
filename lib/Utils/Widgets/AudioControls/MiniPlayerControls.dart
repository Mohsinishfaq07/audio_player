import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayerControls extends StatelessWidget {
  final AudioPlayer player;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MiniPlayerControls(
    this.player,
    this.onPrevious,
    this.onNext, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final audioPlayerState = ref.watch(audioPlayerProvider);
        final hasNext =
            audioPlayerState.currentIndex < audioPlayerState.songs.length - 1;
        final hasPrevious = audioPlayerState.currentIndex > 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.skip_previous,
                color: hasPrevious ? Colors.white : Colors.grey,
                size: 25,
              ),
              onPressed: onPrevious,
            ),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (processingState == ProcessingState.completed) {
                  return IconButton(
                    icon: const Icon(Icons.replay, color: Colors.white),
                    iconSize: 55,
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
                    iconSize: 55,
                    onPressed: player.play,
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white),
                    iconSize: 55,
                    onPressed: player.pause,
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.skip_next,
                color: hasNext ? Colors.white : Colors.grey,
                size: 25,
              ),
              onPressed: onNext,
            ),
          ],
        );
      },
    );
  }
}
