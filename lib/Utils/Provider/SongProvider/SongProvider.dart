import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

final songProvider = StateNotifierProvider<SongNotifier, List<SongModel>>((
  ref,
) {
  return SongNotifier();
});

class SongNotifier extends StateNotifier<List<SongModel>> {
  SongNotifier() : super([]);

  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<void> fetchSongs() async {
    try {
      List<SongModel> songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      state = songs;
    } catch (e) {
      print('Error fetching songs: $e');
    }
  }
}
