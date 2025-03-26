import 'package:audioplayer/Utils/Provider/ArtworkProvider/ArtworkProvider.dart';
import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Provider/FavouritesProvider/FavProvider.dart';
import 'package:audioplayer/Utils/Widgets/AudioControls/AudioControls.dart';
import 'package:audioplayer/Utils/Widgets/PlaylistDialog/PlaylistDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioPlayerScreen extends ConsumerStatefulWidget {
  final List<SongModel> songs;
  final int currentIndex;

  const AudioPlayerScreen({
    super.key,
    required this.songs,
    required this.currentIndex,
  });

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.black),
    );
    // Remove artwork preloading since it's already done
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier).player;
    final favorites = ref.watch(favoriteProvider);
    final currentSong = widget.songs[audioPlayerState.currentIndex];
    final isFavorite = favorites.any((song) => song.id == currentSong.id);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true, // Add this line
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade800,
              Colors.blue.shade500,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Add this
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(60), // Reduced gap
                // Replace Container with QueryArtworkWidget
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade400,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20, // Increased blur
                        spreadRadius: 8, // Increased spread
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final artworkCache = ref.watch(artworkCacheProvider);
                        final cachedArtwork = artworkCache[currentSong.id];

                        if (cachedArtwork != null) {
                          return Image.memory(
                            cachedArtwork,
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                            filterQuality:
                                FilterQuality
                                    .high, // Added high quality filtering
                            isAntiAlias: true, // Added anti-aliasing
                          );
                        }

                        return const Icon(
                          Icons.music_note,
                          size: 120, // Increased size
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                const Gap(20), // Reduced gap
                if (audioPlayerState.mediaItem != null) ...[
                  // Song title and album
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      audioPlayerState.mediaItem!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      audioPlayerState.mediaItem!.album ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(30),
                  // Favorite and Playlist buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          ref
                              .read(favoriteProvider.notifier)
                              .toggleFavorite(currentSong);
                        },
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        icon: const Icon(
                          Icons.playlist_add,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => PlaylistDialog(song: currentSong),
                          );
                        },
                      ),
                    ],
                  ),
                  const Gap(20),
                  // Seekbar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ControlButtons(
                      player,
                      ref.read(audioPlayerProvider.notifier).playPrevious,
                      ref.read(audioPlayerProvider.notifier).playNext,
                    ),
                  ),
                ],
                // Add bottom padding to ensure content is visible when keyboard is shown
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
