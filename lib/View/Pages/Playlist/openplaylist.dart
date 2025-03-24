import 'dart:developer';

import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Provider/Playlistprovider/PlaylistProvider.dart';
import 'package:audioplayer/Utils/Widgets/FloatingButton/FloatingButon.dart';
import 'package:audioplayer/Utils/Widgets/Player%20Widgets/MiniPlayerWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class OpenPlaylist extends ConsumerStatefulWidget {
  final PlaylistModel playlist;

  const OpenPlaylist({super.key, required this.playlist});

  @override
  ConsumerState<OpenPlaylist> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<OpenPlaylist> {
  Future<void> _playSong(List<SongModel> songs, int index) async {
    try {
      await ref
          .read(audioPlayerProvider.notifier)
          .playPlaylistSongs(songs, index);
    } catch (e, stackTrace) {
      log('Error playing song: $e', stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error playing song. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.read(audioPlayerProvider.notifier).player;
    final playerState = ref.watch(audioPlayerProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Get.height * 0.22),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                  Colors.blue.shade300,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gap(30),
                ImageIcon(
                  AssetImage('assets/images/icon.png'),
                  size: 100,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.playlist.playlist,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FutureBuilder<List<SongModel>>(
                  future: ref
                      .read(playlistProvider.notifier)
                      .getPlaylistSongs(widget.playlist.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final songs = snapshot.data ?? [];

                    if (songs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No songs in this playlist',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return Dismissible(
                          key: Key(song.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) async {
                            await ref
                                .read(playlistProvider.notifier)
                                .removeFromPlaylist(widget.playlist.id, song);
                          },
                          confirmDismiss: (_) async {
                            return await showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Remove Song'),
                                    content: Text(
                                      'Remove "${song.title}" from playlist?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: ListTile(
                            leading: QueryArtworkWidget(
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              keepOldArtwork: true,
                              nullArtworkWidget: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.music_note),
                              ),
                            ),
                            title: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist ?? 'Unknown Artist',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (song.uri !=
                                    null) // Only show play button if URI exists
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () {
                                      _playSong(songs, index);
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await ref
                                        .read(playlistProvider.notifier)
                                        .removeFromPlaylist(
                                          widget.playlist.id,
                                          song,
                                        );
                                    setState(() {}); // Refresh the list
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Add space for MiniPlayer
              if (playerState.mediaItem != null)
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            ],
          ),
          FloatingButton(playerState: playerState, ref: ref),
          // Add MiniPlayer at bottom of screen
          if (playerState.mediaItem != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(player: player),
            ),
        ],
      ),
    );
  }
}
