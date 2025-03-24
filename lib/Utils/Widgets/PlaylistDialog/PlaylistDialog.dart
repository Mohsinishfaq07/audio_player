import 'package:audioplayer/Utils/Provider/Playlistprovider/PlaylistProvider.dart';
import 'package:audioplayer/Utils/Widgets/Snackbar/Snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistDialog extends ConsumerStatefulWidget {
  final SongModel song;

  const PlaylistDialog({super.key, required this.song});

  @override
  ConsumerState<PlaylistDialog> createState() => _PlaylistDialogState();
}

class _PlaylistDialogState extends ConsumerState<PlaylistDialog> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('New Playlist'),
            content: SizedBox(
              width: 300,
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Playlist Name'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    await ref
                        .read(playlistProvider.notifier)
                        .createPlaylist(nameController.text);
                    nameController.clear(); // Clear the text field
                    showsnackbar("Playlists", "Playlist Created");
                    if (mounted) {
                      Navigator.pop(
                        dialogContext,
                      ); // Close only the create dialog
                    }
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Playlist'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Create New Playlist'),
              onTap: () => _showCreatePlaylistDialog(context),
            ),
            const Divider(),
            Flexible(
              child: Consumer(
                builder: (context, ref, child) {
                  final playlists = ref.watch(playlistProvider);
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.playlist_play),
                        title: Text(playlists[index].playlist),
                        onTap: () async {
                          await ref
                              .read(playlistProvider.notifier)
                              .addToPlaylist(playlists[index].id, widget.song);
                          showsnackbar("Playlists", "Song Added to Playlist");
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
