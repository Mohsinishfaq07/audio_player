import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Provider/FavouritesProvider/FavProvider.dart';
import 'package:audioplayer/Utils/Widgets/MusicImage/MusicImage.dart';
import 'package:audioplayer/View/AudioPlayer/AudioPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteSongs = ref.watch(favoriteProvider);

    if (favoriteSongs.isEmpty) {
      return const Center(
        child: Text("No favorite songs yet", style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: favoriteSongs.length,
      itemBuilder: (context, index) {
        final song = favoriteSongs[index];

        return ListTile(
          leading: SizedBox(
            height: 50,
            width: 50,
            child: MusicImage(songs: favoriteSongs, index: index),
          ),
          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            song.artist ?? 'Unknown Artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              ref.read(favoriteProvider.notifier).toggleFavorite(song);
            },
          ),
          onTap: () {
            ref
                .read(audioPlayerProvider.notifier)
                .loadSong(favoriteSongs, index);
            Get.to(
              AudioPlayerScreen(songs: favoriteSongs, currentIndex: index),
            );
          },
        );
      },
    );
  }
}
