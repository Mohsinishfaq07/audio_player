import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

final artworkCacheProvider =
    StateNotifierProvider<ArtworkCacheNotifier, Map<int, Uint8List>>((ref) {
      return ArtworkCacheNotifier();
    });

class ArtworkCacheNotifier extends StateNotifier<Map<int, Uint8List>> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  ArtworkCacheNotifier() : super({});

  Future<void> preloadArtworks(List<SongModel> songs) async {
    for (var song in songs) {
      if (!state.containsKey(song.id)) {
        try {
          final artwork = await _audioQuery.queryArtwork(
            song.id,
            ArtworkType.AUDIO,
            size: 200,
            quality: 100,
            format: ArtworkFormat.PNG,
          );
          if (artwork != null) {
            state = {...state, song.id: artwork};
          }
        } catch (e) {
          print('Error loading artwork for song ${song.id}: $e');
        }
      }
    }
  }
}
