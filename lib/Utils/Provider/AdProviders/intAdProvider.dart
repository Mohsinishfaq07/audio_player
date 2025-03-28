import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final interstitialAdProvider =
    StateNotifierProvider<InterstitialAdNotifier, InterstitialAd?>((ref) {
      return InterstitialAdNotifier();
    });

class InterstitialAdNotifier extends StateNotifier<InterstitialAd?> {
  InterstitialAdNotifier() : super(null) {
    loadAd();
  }

  void loadAd() {
    InterstitialAd.load(
      adUnitId:
          "ca-app-pub-3940256099942544/1033173712", // Test ID, replace with real one
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          state = ad;
          log("InterstitialAd loaded successfully.");
        },
        onAdFailedToLoad: (LoadAdError error) {
          state = null;
          log("InterstitialAd failed to load: ${error.message}");
          retryLoadAd();
        },
      ),
    );
  }

  void showAd() {
    if (state != null) {
      state!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          log("InterstitialAd dismissed.");
          ad.dispose();
          state = null;
          loadAd(); // Reload ad after it’s dismissed
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          log("InterstitialAd failed to show: ${error.message}");
          ad.dispose();
          state = null;
          loadAd();
        },
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          log("InterstitialAd is showing.");
        },
      );

      state!.show();
      state = null;
    } else {
      log("Ad not ready yet. Reloading...");
      loadAd();
    }
  }

  void retryLoadAd() {
    Future.delayed(const Duration(seconds: 5), () {
      log("Retrying to load InterstitialAd...");
      loadAd();
    });
  }
}
