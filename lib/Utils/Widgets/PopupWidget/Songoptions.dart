import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Provider/FavouritesProvider/FavProvider.dart';
import 'package:audioplayer/Utils/Provider/Playlistprovider/PlaylistProvider.dart';
import 'package:audioplayer/Utils/Widgets/MusicImage/Musicimage.dart';
import 'package:audioplayer/Utils/Widgets/PlaylistDialog/PlaylistSheet.dart';
import 'package:audioplayer/Utils/Widgets/Snackbar/Snackbar.dart';
import 'package:audioplayer/View/AudioPlayer/AudioPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PopupWidget extends ConsumerWidget {
  final VoidCallback onPlay;
  final SongModel song;
  final VoidCallback onAddToPlaylist;
  final VoidCallback?
  onAddToSinglePlaylist; // New callback for single playlist case

  const PopupWidget({
    super.key,
    required this.onPlay,
    required this.song,
    required this.onAddToPlaylist,
    this.onAddToSinglePlaylist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProvider);
    final isFavorite = favorites.any((s) => s.id == song.id);
    final playlists = ref.watch(playlistProvider);

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
              onTap: () {
                if (playlists.isEmpty) {
                  onAddToPlaylist();
                } else if (playlists.length == 1) {
                  // Only one playlist exists - add directly
                  onAddToSinglePlaylist?.call();
                } else {
                  // Multiple playlists exist - show dialog
                  onAddToPlaylist();
                }
              },
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
    final playlistNotifier = ref.read(playlistProvider.notifier);
    final playlists = ref.watch(playlistProvider);
    final audioquery = OnAudioQuery();
    return ListTile(
      onTap: () async {
        await ref.read(audioPlayerProvider.notifier).loadSong(songs, index);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    AudioPlayerScreen(songs: songs, currentIndex: index),
          ),
        );
      },
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
        onPlay: () async {
          await ref.read(audioPlayerProvider.notifier).loadSong(songs, index);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      AudioPlayerScreen(songs: songs, currentIndex: index),
            ),
          );
        },
        song: song,
        onAddToPlaylist: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => PlaylistBottomSheet(song: song),
          );
        },
        onAddToSinglePlaylist:
            playlists.isEmpty
                ? null
                : () async {
                  final playlist = playlists.first;
                  final List<SongModel> songs = await audioquery
                      .queryAudiosFrom(AudiosFromType.PLAYLIST, playlist.id);

                  bool alreadyExists = songs.any((s) => s.title == song.title);

                  if (alreadyExists) {
                    showsnackbar('Add to Playlist', "Song already Exists");
                  } else {
                    await playlistNotifier.addToPlaylist(playlist.id, song);
                    showsnackbar(
                      'Add to Playlist',
                      "Song Added to ${playlist.data}",
                    );
                  }
                },
      ),
    );
  }
}
