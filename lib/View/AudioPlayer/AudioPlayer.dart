import 'package:audio_session/audio_session.dart';
import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Widgets/AudioControls/AudioControls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
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
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    final audioPlayerState = ref.read(audioPlayerProvider);
    if (audioPlayerState.currentIndex != widget.currentIndex) {
      ref
          .read(audioPlayerProvider.notifier)
          .loadSong(widget.songs, widget.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerState = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier).player;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Now Playing"),
        elevation: 0, // Remove elevation to blend with background
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      extendBodyBehindAppBar: true, // Let the background extend behind AppBar
      body: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(20),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade400,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.music_note, size: 100, color: Colors.white),
                ),
              ),
              const Gap(30),
              if (audioPlayerState.mediaItem != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    audioPlayerState.mediaItem!.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Make text white
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
                      color:
                          Colors
                              .white70, // Make album text slightly transparent
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(30),
              ],
              ControlButtons(
                player,
                ref.read(audioPlayerProvider.notifier).playPrevious,
                ref.read(audioPlayerProvider.notifier).playNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
