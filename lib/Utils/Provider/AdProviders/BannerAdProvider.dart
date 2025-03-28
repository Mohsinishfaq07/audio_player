import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final bannerAdProvider = Provider<BannerAd>((ref) {
  return BannerAd(
    adUnitId:
        "ca-app-pub-3940256099942544/6300978111", // Replace with real ad ID
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (Ad ad) => print("BannerAd loaded successfully."),
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print("BannerAd failed to load: ${error.message}");
        ad.dispose();
      },
    ),
  )..load();
});
final playlistBannerAdProvider = Provider<BannerAd>((ref) {
  final bannerAd = BannerAd(
    adUnitId: "ca-app-pub-3940256099942544/6300978111", // Test ID
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (Ad ad) => print("Playlist BannerAd loaded successfully."),
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print("Playlist BannerAd failed to load: ${error.message}");
        ad.dispose();
      },
    ),
  )..load();

  return bannerAd;
});
