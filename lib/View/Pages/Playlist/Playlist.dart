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

    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return Dismissible(
          key: ValueKey(playlist.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
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
                ) ??
                false;
          },
          onDismissed: (direction) async {
            final success = await ref
                .read(playlistProvider.notifier)
                .deletePlaylist(playlist.id);

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${playlist.playlist} deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              // If deletion failed, show error and refresh the list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to delete playlist'),
                  backgroundColor: Colors.red,
                ),
              );
              // Refresh playlists
              ref.read(playlistProvider.notifier).loadPlaylists();
            }
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
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenPlaylist(playlist: playlist),
                  ),
                ),
          ),
        );
      },
    );
  }
}
