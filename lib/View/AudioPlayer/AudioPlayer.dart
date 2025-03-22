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
        title: const Text("Audio Player"),
        elevation: 2,
        centerTitle: true,
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(20),
            QueryArtworkWidget(
              artworkHeight: 200,
              artworkWidth: 300,
              nullArtworkWidget: Icon(Icons.music_note, size: 100),
              controller: OnAudioQuery(),
              id: audioPlayerState.songs[audioPlayerState.currentIndex].id,
              type: ArtworkType.AUDIO,
            ),
            Gap(30),
            if (audioPlayerState.mediaItem != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  audioPlayerState.mediaItem!.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                audioPlayerState.mediaItem!.album ?? '',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(30),
            ],
            ControlButtons(
              player,
              ref.read(audioPlayerProvider.notifier).playPrevious,
              ref.read(audioPlayerProvider.notifier).playNext,
            ),
          ],
        ),
      ),
    );
  }
}
