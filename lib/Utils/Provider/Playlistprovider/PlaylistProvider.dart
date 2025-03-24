import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

final playlistProvider =
    StateNotifierProvider<PlaylistNotifier, List<PlaylistModel>>((ref) {
      return PlaylistNotifier();
    });

class PlaylistNotifier extends StateNotifier<List<PlaylistModel>> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  PlaylistNotifier() : super([]) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    final playlists = await _audioQuery.queryPlaylists(
      sortType: PlaylistSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      ignoreCase: true,
    );
    state = playlists;
  }

  Future<void> createPlaylist(String name) async {
    final playlistId = await _audioQuery.createPlaylist(name);
    await loadPlaylists(); // Reload all playlists to get the new one
  }

  Future<void> deletePlaylist(int playlistId) async {
    final success = await _audioQuery.removePlaylist(playlistId);
    if (success) {
      await loadPlaylists(); // Reload all playlists to reflect deletion
    }
  }

  Future<void> addToPlaylist(int playlistId, SongModel song) async {
    final success = await _audioQuery.addToPlaylist(playlistId, song.id);
    if (success) {
      await loadPlaylists(); // Reload to update song counts
    }
  }

  Future<void> removeFromPlaylist(int playlistId, SongModel song) async {
    final success = await _audioQuery.removeFromPlaylist(playlistId, song.id);
    if (success) {
      await loadPlaylists(); // Reload to update song counts
    }
  }

  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    return await _audioQuery.queryAudiosFrom(
      AudiosFromType.PLAYLIST,
      playlistId,
    );
  }
}
