import 'package:audioplayer/Utils/Provider/AdProviders/bannerAdProvider.dart';
import 'package:audioplayer/Utils/Provider/ArtworkProvider/ArtworkProvider.dart';
import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:audioplayer/Utils/Provider/PermissionProvider/permissionprovider.dart';
import 'package:audioplayer/Utils/Provider/SongProvider/SongProvider.dart';
import 'package:audioplayer/Utils/Widgets/NoStorageWidget/Nostorage.dart';
import 'package:audioplayer/Utils/Widgets/Player Widgets/MiniPlayerWidget.dart';
import 'package:audioplayer/Utils/Widgets/PopupWidget/Songoptions.dart';
import 'package:audioplayer/View/Pages/Playlist/Playlist.dart';
import 'package:audioplayer/View/Pages/favourite/favourite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  Future<void> _loadSongs() async {
    await ref.read(songProvider.notifier).fetchSongs();
    final songs = ref.read(songProvider);
    if (songs.isNotEmpty) {
      ref.read(artworkCacheProvider.notifier).preloadArtworks(songs);
    }
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
      _loadSongs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionProvider);
    final songs = ref.watch(songProvider);
    final player = ref.read(audioPlayerProvider.notifier).player;
    final playerState = ref.watch(audioPlayerProvider);
    final double height = Get.height;
    final bannerAd = ref.watch(bannerAdProvider);

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
                Icon(
                  Icons.headphones,
                  size: height * 0.15,
                  color: Colors.orange,
                ),
                SizedBox(height: height * 0.02),
                const Text(
                  "Audio Player",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.06),
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
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
                            ],
                          ),
                    ),
                    FavouriteScreen(),
                    PlaylistScreen(),
                  ],
                ),
              ],
            ),
          ),
          if (bannerAd != null)
            Consumer(
              builder: (context, ref, child) {
                final bannerAd = ref.watch(
                  bannerAdProvider,
                ); // ✅ Creates a new instance
                return Container(
                  alignment: Alignment.center,
                  width: bannerAd?.size.width.toDouble(),
                  height: bannerAd?.size.height.toDouble(),
                  child: AdWidget(
                    ad: bannerAd!,
                  ), // ✅ Fresh instance for AdWidget
                );
              },
            ),
          if (playerState.mediaItem != null) MiniPlayer(player: player),
        ],
      ),
    );
  }
}
