import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

final playlistProvider =
    StateNotifierProvider<PlaylistNotifier, List<PlaylistModel>>((ref) {
      return PlaylistNotifier();
    });

class PlaylistNotifier extends StateNotifier<List<PlaylistModel>> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  static const List<String> _systemPlaylists = [
    'Recently added',
    'Most played',
  ];

  PlaylistNotifier() : super([]) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    try {
      final playlists = await _audioQuery.queryPlaylists(
        sortType: PlaylistSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
        ignoreCase: true,
      );

      // Filter out system playlists and corrupted ones
      final validPlaylists =
          playlists
              .where(
                (p) =>
                    p.id > 0 &&
                    p.playlist.isNotEmpty &&
                    !_systemPlaylists.contains(p.playlist),
              )
              .toList();

      state = validPlaylists;
    } catch (e) {
      print('Error loading playlists: $e');
      state = [];
    }
  }

  Future<void> createPlaylist(String name) async {
    try {
      final playlistId = await _audioQuery.createPlaylist(name);
      if (playlistId != -1) {
        await loadPlaylists();
      }
    } catch (e) {
      print('Error creating playlist: $e');
    }
  }

  Future<bool> deletePlaylist(int playlistId) async {
    try {
      // Check if playlist is system playlist
      final playlist = state.firstWhere((p) => p.id == playlistId);
      if (_systemPlaylists.contains(playlist.playlist)) {
        print('Cannot delete system playlist: ${playlist.playlist}');
        return false;
      }

      // First remove all songs from playlist
      final songs = await getPlaylistSongs(playlistId);
      for (var song in songs) {
        await _audioQuery.removeFromPlaylist(playlistId, song.id);
      }

      // Then remove the playlist itself
      final success = await _audioQuery.removePlaylist(playlistId);
      if (success) {
        // Update state immediately
        state = state.where((p) => p.id != playlistId).toList();
        return true;
      }

      return false;
    } catch (e) {
      print('Error deleting playlist: $e');
      return false;
    }
  }

  Future<void> addToPlaylist(int playlistId, SongModel song) async {
    try {
      final success = await _audioQuery.addToPlaylist(playlistId, song.id);
      if (success) {
        await loadPlaylists();
      }
    } catch (e) {
      print('Error adding to playlist: $e');
    }
  }

  Future<void> removeFromPlaylist(int playlistId, SongModel song) async {
    try {
      final success = await _audioQuery.removeFromPlaylist(playlistId, song.id);
      if (success) {
        await loadPlaylists();
      }
    } catch (e) {
      print('Error removing from playlist: $e');
    }
  }

  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    try {
      return await _audioQuery.queryAudiosFrom(
        AudiosFromType.PLAYLIST,
        playlistId,
      );
    } catch (e) {
      print('Error getting playlist songs: $e');
      return [];
    }
  }
}
