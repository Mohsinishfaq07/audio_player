import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Widgets/AudioControls/MiniPlayerControls.dart';
import 'package:audioplayer/View/AudioPlayer/AudioPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MiniPlayer extends ConsumerWidget {
  final AudioPlayer player;

  const MiniPlayer({super.key, required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final currentSong = audioPlayerState.mediaItem;

    if (currentSong == null) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AudioPlayerScreen(
                  songs: audioPlayerState.songs,
                  currentIndex: audioPlayerState.currentIndex,
                ),
          ),
        );
      },
      child: Container(
        width: Get.width * 1,
        height: Get.height * 0.1, // Set a fixed height for the MiniPlayer
        color: Colors.grey[850],
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ), // Add horizontal padding
        child: Row(
          children: [
            QueryArtworkWidget(
              nullArtworkWidget: Icon(Icons.music_note, color: Colors.white),
              controller: OnAudioQuery(),
              id: audioPlayerState.songs[audioPlayerState.currentIndex].id,
              type: ArtworkType.AUDIO,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentSong.title,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentSong.album ?? '',
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            MiniPlayerControls(
              player,
              ref.read(audioPlayerProvider.notifier).playPrevious,
              ref.read(audioPlayerProvider.notifier).playNext,
            ),
          ],
        ),
      ),
    );
  }
}
