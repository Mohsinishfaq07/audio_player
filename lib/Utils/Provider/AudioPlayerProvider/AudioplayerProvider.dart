import 'package:audioplayer/Utils/Widgets/Snackbar/Snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
      return AudioPlayerNotifier();
    });

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerNotifier() : super(AudioPlayerState()) {
    // When using the full playlist (shuffle mode), update current index.
    _player.currentIndexStream.listen((index) {
      if (index != null &&
          state.shuffleModeEnabled &&
          index < state.songs.length) {
        final song = state.songs[index];
        final updatedMediaItem = MediaItem(
          id: song.uri!,
          album: song.album ?? '',
          title: song.title,
          artUri: Uri.parse(song.uri!),
        );
        state = state.copyWith(
          currentIndex: index,
          mediaItem: updatedMediaItem,
        );
      }
    });
    _player.playerStateStream.listen((playerState) {
      // When a song completes in single-song mode, pause playback.
      if (playerState.processingState == ProcessingState.completed &&
          !state.shuffleModeEnabled) {
        _player.pause();
      }
    });
  }

  AudioPlayer get player => _player;

  /// Loads a single song (non-shuffle mode).
  Future<void> loadSong(List<SongModel> songs, int currentIndex) async {
    try {
      final song = songs[currentIndex];
      final mediaItem = MediaItem(
        id: song.uri!,
        album: song.album ?? '',
        title: song.title,
        artUri: Uri.parse(song.uri!),
      );
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(song.uri!), tag: mediaItem),
      );
      // Disable built‐in shuffle.
      await _player.setShuffleModeEnabled(false);
      _player.play();
      state = state.copyWith(
        songs: songs,
        currentIndex: currentIndex,
        mediaItem: mediaItem,
        shuffleModeEnabled: false,
      );
    } on PlayerException catch (e) {
      print("Error loading single song: $e");
    }
  }

  /// Loads the full playlist and enables shuffle mode.
  Future<void> loadPlaylist(List<SongModel> songs, int initialIndex) async {
    // if (songs.isEmpty) {
    //   print("Cannot load playlist: songs list is empty");
    //   return;
    // }
    // Clamp the initialIndex just in case

    try {
      final playlist = ConcatenatingAudioSource(
        children:
            songs.map((song) {
              final mediaItem = MediaItem(
                id: song.uri!,
                album: song.album ?? '',
                title: song.title,
                artUri: Uri.parse(song.uri!),
              );
              return AudioSource.uri(Uri.parse(song.uri!), tag: mediaItem);
            }).toList(),
      );
      await _player.setAudioSource(playlist, initialIndex: initialIndex);
      await _player.setShuffleModeEnabled(true);
      _player.play();
      state = state.copyWith(
        songs: songs,
        currentIndex: initialIndex,
        // mediaItem: MediaItem(
        //   id: songs[initialIndex].uri!,
        //   album: songs[initialIndex].album ?? '',
        //   title: songs[initialIndex].title,
        //   artUri: Uri.parse(songs[initialIndex].uri!),
        // ),
        shuffleModeEnabled: true,
      );
    } on PlayerException catch (e) {
      print("Error loading playlist: $e");
    }
  }

  Future<void> toggleShuffle() async {
    if (!state.shuffleModeEnabled) {
      showsnackbar("Shuffle", "Shuffle On");
      if (_player.loopMode != LoopMode.off) {
        await _player.setLoopMode(LoopMode.off);
        state = state.copyWith(loopMode: LoopMode.off);
      }
      await _player.stop();
      await loadPlaylist(state.songs, state.currentIndex);
    } else {
      state = state.copyWith(shuffleModeEnabled: false);
      showsnackbar("Shuffle", "Shuffle Off");
    }
  }

  /// Next/Previous navigation in non-shuffle mode.
  Future<void> playNext() async {
    if (!state.shuffleModeEnabled) {
      // If current song is not the last one, play the next song,
      // otherwise jump back to the first song.
      int nextIndex =
          (state.currentIndex < state.songs.length - 1)
              ? state.currentIndex + 1
              : 0;
      await loadSong(state.songs, nextIndex);
    }
    // In shuffle mode, just use built-in navigation:
    else {
      await _player.seekToNext();
    }
  }

  /// Previous navigation in non-shuffle mode.
  Future<void> playPrevious() async {
    if (!state.shuffleModeEnabled) {
      // If current song is not the first one, play previous song,
      // otherwise jump to the last song.
      int prevIndex =
          (state.currentIndex > 0)
              ? state.currentIndex - 1
              : state.songs.length - 1;
      await loadSong(state.songs, prevIndex);
    } else {
      await _player.seekToPrevious();
    }
  }

  Future<void> toggleLoop() async {
    final newLoopMode =
        _player.loopMode == LoopMode.off
            ? LoopMode.all
            : _player.loopMode == LoopMode.all
            ? LoopMode.one
            : LoopMode.off;
    if (newLoopMode != LoopMode.off && state.shuffleModeEnabled) {
      await _player.setShuffleModeEnabled(false);
      state = state.copyWith(shuffleModeEnabled: false);
    }
    await _player.setLoopMode(newLoopMode);
    state = state.copyWith(loopMode: newLoopMode);
    if (newLoopMode == LoopMode.off) {
      showsnackbar("Loop Mode", "Loop off");
    } else if (newLoopMode == LoopMode.one) {
      showsnackbar("Loop Mode", "Loop once");
    } else {
      showsnackbar("Loop Mode", "Loop on");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

class AudioPlayerState {
  final List<SongModel> songs;
  final int currentIndex;
  final MediaItem? mediaItem;
  final bool shuffleModeEnabled;
  final LoopMode loopMode;

  AudioPlayerState({
    this.songs = const [],
    this.currentIndex = 0,
    this.mediaItem,
    this.shuffleModeEnabled = false,
    this.loopMode = LoopMode.off,
  });

  AudioPlayerState copyWith({
    List<SongModel>? songs,
    int? currentIndex,
    MediaItem? mediaItem,
    bool? shuffleModeEnabled,
    LoopMode? loopMode,
  }) {
    return AudioPlayerState(
      songs: songs ?? this.songs,
      currentIndex: currentIndex ?? this.currentIndex,
      mediaItem: mediaItem ?? this.mediaItem,
      shuffleModeEnabled: shuffleModeEnabled ?? this.shuffleModeEnabled,
      loopMode: loopMode ?? this.loopMode,
    );
  }
}
