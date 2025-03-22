import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionProvider = StateNotifierProvider<PermissionNotifier, bool>((
  ref,
) {
  return PermissionNotifier();
});

class PermissionNotifier extends StateNotifier<bool> {
  PermissionNotifier() : super(false);

  Future<void> checkAndRequestPermissions({bool retry = false}) async {
    try {
      if (Platform.isAndroid) {
        if (await isAndroid13OrHigher()) {
          final audio = await Permission.audio.request();
          if (audio.isGranted) {
            state = true;
          } else if (audio.isDenied && retry) {
            final retryStatus = await Permission.audio.request();
            state = retryStatus.isGranted;
          } else {
            state = false;
          }
        } else {
          final storage = await Permission.storage.request();
          if (storage.isGranted) {
            state = true;
          } else if (storage.isDenied && retry) {
            final retryStatus = await Permission.storage.request();
            state = retryStatus.isGranted;
          } else {
            state = false;
          }
        }
      } else {
        state = true;
      }
    } catch (e) {
      state = false;
      print('Error requesting permissions: $e');
    }
  }

  Future<bool> isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }
}
