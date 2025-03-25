import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicImage extends StatelessWidget {
  const MusicImage({super.key, required this.songs, required this.index});

  final List<SongModel> songs;
  final int index;

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      keepOldArtwork: true,
      nullArtworkWidget: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.music_note, color: Colors.blue.shade700, size: 30),
      ),
      controller: OnAudioQuery(),
      id: songs[index].id,
      type: ArtworkType.AUDIO,
      artworkHeight: 50,
      artworkWidth: 50,
      artworkFit: BoxFit.cover,
      artworkBorder: BorderRadius.circular(25),
    );
  }
}
