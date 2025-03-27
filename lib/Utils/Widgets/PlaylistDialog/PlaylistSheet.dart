import 'package:audioplayer/Utils/Provider/Playlistprovider/PlaylistProvider.dart';
import 'package:audioplayer/Utils/Widgets/Snackbar/Snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistBottomSheet extends ConsumerStatefulWidget {
  final SongModel song;

  const PlaylistBottomSheet({super.key, required this.song});

  @override
  ConsumerState<PlaylistBottomSheet> createState() =>
      _PlaylistBottomSheetState();
}

class _PlaylistBottomSheetState extends ConsumerState<PlaylistBottomSheet> {
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
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Playlist Name'),
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
                    nameController.clear();
                    showsnackbar("Playlists", "Playlist Created");
                    if (mounted) {
                      Navigator.pop(dialogContext);
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
    final audioquery = OnAudioQuery();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade500,
            Colors.blue.shade300,
          ], // Bluish gradient
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              'Add to Playlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Divider(color: Colors.white38, thickness: 1),
          ListTile(
            leading: const Icon(Icons.playlist_add, color: Colors.white),
            title: const Text(
              'Create New Playlist',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _showCreatePlaylistDialog(context),
          ),
          const Divider(color: Colors.white38, thickness: 1),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final playlists = ref.watch(playlistProvider);
                return ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.playlist_play,
                            color: Colors.white,
                          ),
                          title: Text(
                            playlists[index].playlist,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () async {
                            final List<SongModel> songs = await audioquery
                                .queryAudiosFrom(
                                  AudiosFromType.PLAYLIST,
                                  playlists[index].id,
                                );

                            bool alreadyExists = songs.any(
                              (s) => s.title == widget.song.title,
                            );

                            if (alreadyExists) {
                              showsnackbar(
                                'Add to Playlist',
                                "Song already Exists",
                              );
                            } else {
                              await ref
                                  .read(playlistProvider.notifier)
                                  .addToPlaylist(
                                    playlists[index].id,
                                    widget.song,
                                  );
                              showsnackbar(
                                "Playlists",
                                "Song Added to Playlist",
                              );
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                        ),
                        const Divider(color: Colors.white38, thickness: 0.5),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
