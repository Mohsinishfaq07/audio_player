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

    _player.playerStateStream.listen((playerState) async {
      if (playerState.processingState == ProcessingState.completed) {
        if (_player.loopMode != LoopMode.off) {
          // If loop mode is enabled, automatically restart
          await _player.seek(Duration.zero);
          await _player.play();
        } else {
          // If no loop mode, just pause at the end
          await _player.pause();
          await _player.seek(Duration.zero);
        }
      }
    });
  }

  AudioPlayer get player => _player;

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

  void clearMediaItem() {
    state = AudioPlayerState(
      songs: [],
      currentIndex: 0,
      mediaItem: null,
      shuffleModeEnabled: false,
      loopMode: LoopMode.off,
    );
    player.stop();
  }

  Future<void> loadPlaylist(List<SongModel> songs, int initialIndex) async {
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
        shuffleModeEnabled: true,
      );
    } on PlayerException catch (e) {
      print("Error loading playlist: $e");
    }
  }

  Future<void> playPlaylistSongs(
    List<SongModel> songs,
    int initialIndex,
  ) async {
    try {
      print(
        'Setting up playlist with ${songs.length} songs at index $initialIndex',
      );

      // Create playlist with proper data path handling
      final playlist = ConcatenatingAudioSource(
        children:
            songs.map((song) {
              print('Processing song: ${song.title}');
              print('File path: ${song.data}');

              final mediaItem = MediaItem(
                id: song.id.toString(),
                album: song.album ?? 'Unknown Album',
                title: song.title,
                artist: song.artist ?? 'Unknown Artist',
              );

              // Use file path directly instead of URI
              return AudioSource.uri(Uri.file(song.data), tag: mediaItem);
            }).toList(),
      );

      // Stop current playback if any
      await _player.stop();

      // Set up index change listener before setting audio source
      _player.currentIndexStream.listen((index) {
        if (index != null && index < songs.length) {
          final currentSong = songs[index];
          print(
            'Index changed to: $index, updating to song: ${currentSong.title}',
          );

          state = state.copyWith(
            currentIndex: index,
            mediaItem: MediaItem(
              id: currentSong.id.toString(),
              album: currentSong.album ?? 'Unknown Album',
              title: currentSong.title,
              artist: currentSong.artist ?? 'Unknown Artist',
            ),
          );
        }
      });

      // Set up the audio source
      await _player.setAudioSource(playlist, initialIndex: initialIndex);

      // Update initial state
      state = state.copyWith(
        songs: songs,
        currentIndex: initialIndex,
        mediaItem: MediaItem(
          id: songs[initialIndex].id.toString(),
          album: songs[initialIndex].album ?? 'Unknown Album',
          title: songs[initialIndex].title,
          artist: songs[initialIndex].artist ?? 'Unknown Artist',
        ),
      );

      // Start playback
      await _player.play();
    } catch (e, stackTrace) {
      print('Error in playPlaylistSongs:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> toggleShuffle() async {
    try {
      final isPlaylist = _player.audioSource is ConcatenatingAudioSource;
      final newShuffleMode = !state.shuffleModeEnabled;

      if (isPlaylist) {
        // We're in playlist mode
        print('Toggling shuffle for playlist');

        await _player.setShuffleModeEnabled(newShuffleMode);

        if (newShuffleMode) {
          showsnackbar("Shuffle", "Playlist Shuffle On");
        } else {
          showsnackbar("Shuffle", "Playlist Shuffle Off");
        }

        state = state.copyWith(shuffleModeEnabled: newShuffleMode);
      } else {
        // Regular shuffle mode for all songs
        if (newShuffleMode) {
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
    } catch (e) {
      print('Error toggling shuffle: $e');
    }
  }

  Future<void> playNext() async {
    try {
      if (_player.audioSource is ConcatenatingAudioSource) {
        // Playing from a playlist
        if (_player.hasNext) {
          print('Playing next in playlist');
          await _player.seekToNext();
        } else {
          print('No next song, stopping playback');
          await _player.stop();
          _player.seek(Duration.zero);
        }
      } else {
        // Regular playback
        if (!state.shuffleModeEnabled) {
          int nextIndex =
              (state.currentIndex < state.songs.length - 1)
                  ? state.currentIndex + 1
                  : -1;

          if (nextIndex != -1) {
            await loadSong(state.songs, nextIndex);
          } else {
            print('No next song, stopping playback');
            // await _player.stop();
            // _player.seek(Duration.zero);
          }
        } else {
          if (_player.hasNext) {
            await _player.seekToNext();
          } else {
            print('No next song, stopping playback');
            await _player.stop();
            _player.seek(Duration.zero);
          }
        }
      }
    } catch (e) {
      print('Error playing next song: $e');
    }
  }

  Future<void> playPrevious() async {
    try {
      if (_player.audioSource is ConcatenatingAudioSource) {
        // Playing from a playlist
        if (_player.hasPrevious) {
          print('Playing previous in playlist');
          await _player.seekToPrevious();
        } else {
          // print('No previous song, stopping playback');
          // await _player.stop();
          // _player.seek(Duration.zero);
        }
      } else {
        // Regular playback
        if (!state.shuffleModeEnabled) {
          int prevIndex =
              (state.currentIndex > 0) ? state.currentIndex - 1 : -1;

          if (prevIndex != -1) {
            await loadSong(state.songs, prevIndex);
          } else {
            print('No previous song, stopping playback');
            await _player.stop();
            _player.seek(Duration.zero);
          }
        }
      }
    } catch (e) {
      print('Error playing previous song: $e');
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
