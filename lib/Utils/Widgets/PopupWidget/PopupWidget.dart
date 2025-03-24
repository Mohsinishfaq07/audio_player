import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Provider/FavouritesProvider/FavProvider.dart';
import 'package:audioplayer/Utils/Widgets/MusicImage/Musicimage.dart';
import 'package:audioplayer/Utils/Widgets/PlaylistDialog/PlaylistDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PopupWidget extends ConsumerWidget {
  final VoidCallback onPlay;
  final SongModel song;
  final VoidCallback onAddToPlaylist;

  const PopupWidget({
    super.key,
    required this.onPlay,
    required this.song,
    required this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the entire favorites list for real-time updates
    final favorites = ref.watch(favoriteProvider);
    final isFavorite = favorites.any((s) => s.id == song.id);

    return PopupMenuButton(
      itemBuilder:
          (context) => [
            PopupMenuItem(
              onTap: onPlay,
              child: const ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text('Play'),
              ),
            ),
            PopupMenuItem(
              onTap:
                  () =>
                      ref.read(favoriteProvider.notifier).toggleFavorite(song),
              child: ListTile(
                leading: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                title: Text(
                  isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                ),
              ),
            ),
            PopupMenuItem(
              onTap: onAddToPlaylist,
              child: const ListTile(
                leading: Icon(Icons.playlist_add),
                title: Text('Add to Playlist'),
              ),
            ),
          ],
    );
  }
}

class SongOptions extends ConsumerWidget {
  final List<SongModel> songs;
  final SongModel song;
  final int index;

  const SongOptions({
    super.key,
    required this.songs,
    required this.song,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap:
          () => ref.read(audioPlayerProvider.notifier).loadSong(songs, index),
      leading: SizedBox(
        height: 50,
        width: 50,
        child: MusicImage(songs: songs, index: index),
      ),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        song.artist ?? 'Unknown Artist',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupWidget(
        onPlay:
            () => ref.read(audioPlayerProvider.notifier).loadSong(songs, index),
        song: song,
        onAddToPlaylist:
            () => showDialog(
              context: context,
              builder: (context) => PlaylistDialog(song: song),
            ),
      ),
    );
  }
}
