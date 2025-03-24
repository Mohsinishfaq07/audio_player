import 'package:audioplayer/Utils/Provider/AudioPlayerProvider/AudioplayerProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({
    super.key,
    required this.playerState,
    required this.ref,
  });

  final AudioPlayerState playerState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom:
          playerState.mediaItem != null ? Get.height * 0.12 : Get.height * 0.08,
      left: Get.width * 0.8,
      child: FloatingActionButton(
        onPressed: () {
          ref.read(audioPlayerProvider.notifier).toggleShuffle();
        },
        child: Consumer(
          builder: (context, ref, child) {
            final shuffleOn = ref.watch(audioPlayerProvider).shuffleModeEnabled;
            return Icon(shuffleOn ? Icons.shuffle_on_outlined : Icons.shuffle);
          },
        ),
      ),
    );
  }
}
