import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Provider/PermissionProvider/permissionprovider.dart';
import 'package:audioplayer/Utils/Provider/SongProvider/SongProvider.dart';
import 'package:audioplayer/Utils/Widgets/NoStorageWidget/Nostorage.dart';
import 'package:audioplayer/Utils/Widgets/Player Widgets/MiniPlayerWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Songs extends ConsumerStatefulWidget {
  const Songs({super.key});

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends ConsumerState<Songs> with WidgetsBindingObserver {
  PersistentBottomSheetController? _bottomSheetController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkAndRequestPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(songProvider.notifier).fetchSongs();
    }
  }

  Future<void> checkAndRequestPermissions() async {
    await ref.read(permissionProvider.notifier).checkAndRequestPermissions();
    if (ref.read(permissionProvider)) {
      await ref.read(songProvider.notifier).fetchSongs();
    }
  }

  void _showMiniPlayer(BuildContext context, AudioPlayer player) {
    if (_bottomSheetController != null) {
      _bottomSheetController!.close();
    }
    _bottomSheetController = Scaffold.of(context).showBottomSheet(
      (context) => MiniPlayer(player: player),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPermission = ref.watch(permissionProvider);
    final songs = ref.watch(songProvider);
    final player = ref.read(audioPlayerProvider.notifier).player;

    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: Get.height * 0.1),
        child: FloatingActionButton(
          onPressed: () {
            ref.read(audioPlayerProvider.notifier).toggleShuffle();
          },
          child: Consumer(
            builder: (context, ref, child) {
              final shuffleOn =
                  ref.watch(audioPlayerProvider).shuffleModeEnabled;
              return Icon(
                shuffleOn ? Icons.shuffle_on_outlined : Icons.shuffle,
              );
            },
          ),
        ),
      ),
      backgroundColor: Colors.grey[250],
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: Builder(
        builder:
            (context) => Stack(
              children: [
                Center(
                  child:
                      !hasPermission
                          ? NoStoragePermission(checkAndRequestPermissions)
                          : songs.isEmpty
                          ? const CircularProgressIndicator()
                          : ListView.builder(
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  ref
                                      .read(audioPlayerProvider.notifier)
                                      .loadSong(songs, index);
                                  _showMiniPlayer(context, player);
                                },
                                title: Text(songs[index].title),
                                subtitle: Text(
                                  songs[index].artist ?? "No Artist",
                                ),
                                trailing: const Icon(Icons.play_arrow),
                                leading: QueryArtworkWidget(
                                  nullArtworkWidget: Icon(Icons.music_note),
                                  controller: OnAudioQuery(),
                                  id: songs[index].id,
                                  type: ArtworkType.AUDIO,
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
      ),
    );
  }
}
