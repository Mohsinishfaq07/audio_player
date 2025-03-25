import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Provider/PermissionProvider/permissionprovider.dart';
import 'package:audioplayer/Utils/Provider/SongProvider/SongProvider.dart';
import 'package:audioplayer/Utils/Widgets/FloatingButton/FloatingButon.dart';
import 'package:audioplayer/Utils/Widgets/NoStorageWidget/Nostorage.dart';
import 'package:audioplayer/Utils/Widgets/Player Widgets/MiniPlayerWidget.dart';
import 'package:audioplayer/Utils/Widgets/PopupWidget/PopupWidget.dart';
import 'package:audioplayer/View/Pages/Playlist/Playlist.dart';
import 'package:audioplayer/View/Pages/favourite/favourite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Songs extends ConsumerStatefulWidget {
  const Songs({super.key});

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends ConsumerState<Songs>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    checkAndRequestPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    final permissionState = ref.read(permissionProvider);
    if (permissionState.hasPermission) {
      await ref.read(songProvider.notifier).fetchSongs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionProvider);
    final songs = ref.watch(songProvider);
    final player = ref.read(audioPlayerProvider.notifier).player;
    final playerState = ref.watch(audioPlayerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[250],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.3,
        ),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                  Colors.blue.shade300,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageIcon(
                  AssetImage('assets/images/icon.png'),
                  size: 100,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Audio Player",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All Songs', icon: Icon(Icons.music_note)),
              Tab(text: 'Favorites', icon: Icon(Icons.favorite)),
              Tab(text: 'Playlists', icon: Icon(Icons.playlist_play)),
            ],
            dividerColor: Colors.white,
            indicatorColor: Colors.white,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              Builder(
                builder:
                    (context) => Stack(
                      children: [
                        Center(
                          child:
                              permissionState.isLoading
                                  ? const CircularProgressIndicator()
                                  : !permissionState.hasPermission
                                  ? NoStoragePermission(
                                    checkAndRequestPermissions,
                                  )
                                  : ListView.builder(
                                    itemCount: songs.length,
                                    itemBuilder: (context, index) {
                                      final song = songs[index];
                                      return SongOptions(
                                        index: index,
                                        songs: songs,
                                        song: song,
                                      );
                                    },
                                  ),
                        ),
                        FloatingButton(playerState: playerState, ref: ref),
                      ],
                    ),
              ),
              FavouriteScreen(),
              PlaylistScreen(),
            ],
          ),
          if (playerState.mediaItem != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(player: player),
            ),
        ],
      ),
    );
  }
}
