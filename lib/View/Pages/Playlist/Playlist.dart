import 'package:audioplayer/Utils/Provider/Playlistprovider/PlaylistProvider.dart';
import 'package:audioplayer/View/Pages/Playlist/openplaylist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({super.key});

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Reload playlists when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playlistProvider.notifier).loadPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final playlists = ref.watch(playlistProvider);

    if (playlists.isEmpty) {
      return const Center(
        child: Text(
          "No Playlists",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return Dismissible(
          key: Key(playlist.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(playlistProvider.notifier).deletePlaylist(playlist.id);
          },
          confirmDismiss: (_) async {
            return await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Delete Playlist'),
                    content: Text(
                      'Are you sure you want to delete "${playlist.playlist}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
            );
          },
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.playlist_play,
                size: 30,
                color: Colors.blue,
              ),
            ),
            title: Text(
              playlist.playlist,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: FutureBuilder<List<SongModel>>(
              future: ref
                  .read(playlistProvider.notifier)
                  .getPlaylistSongs(playlist.id),
              builder: (context, snapshot) {
                final songCount = snapshot.data?.length ?? 0;
                return Text(
                  '$songCount songs',
                  style: TextStyle(color: Colors.grey.shade600),
                );
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<List<SongModel>>(
                  future: ref
                      .read(playlistProvider.notifier)
                      .getPlaylistSongs(playlist.id),
                  builder: (context, snapshot) {
                    final songCount = snapshot.data?.length ?? 0;
                    return Text(
                      '$songCount',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    ref
                        .read(playlistProvider.notifier)
                        .deletePlaylist(playlist.id);
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OpenPlaylist(playlist: playlist),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
