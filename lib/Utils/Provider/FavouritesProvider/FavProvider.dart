import 'package:audioplayer/Utils/Widgets/Snackbar/Snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, List<SongModel>>((ref) {
      return FavoriteNotifier();
    });

class FavoriteNotifier extends StateNotifier<List<SongModel>> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  static const String _favoritesKey = 'favorite_songs';
  late SharedPreferences _prefs;

  FavoriteNotifier() : super([]) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final List<String> savedIds = _prefs.getStringList(_favoritesKey) ?? [];
    if (savedIds.isEmpty) {
      state = [];
      return;
    }

    final allSongs = await _audioQuery.querySongs();
    final favorites =
        allSongs
            .where((song) => savedIds.contains(song.id.toString()))
            .toList();

    state = [...favorites]; // Force state update
  }

  Future<void> toggleFavorite(SongModel song) async {
    final List<String> savedIds = _prefs.getStringList(_favoritesKey) ?? [];
    List<SongModel> newState;

    if (isFavorite(song)) {
      savedIds.remove(song.id.toString());
      newState = state.where((s) => s.id != song.id).toList();
      showsnackbar("Favorites", "Removed from Favorites");
    } else {
      savedIds.add(song.id.toString());
      newState = [...state, song];
      showsnackbar("Favorites", "Added to Favorites");
    }

    // Update SharedPreferences first
    await _prefs.setStringList(_favoritesKey, savedIds);

    // Then update state with a new list to trigger UI updates
    state = [...newState];
  }

  bool isFavorite(SongModel song) {
    // Create a new list to ensure reactivity
    return [...state].any((s) => s.id == song.id);
  }
}
