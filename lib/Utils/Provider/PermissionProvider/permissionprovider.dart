import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionState {
  final bool hasPermission;
  final bool isLoading;

  const PermissionState({required this.hasPermission, required this.isLoading});
}

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
      return PermissionNotifier();
    });

class PermissionNotifier extends StateNotifier<PermissionState> {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  PermissionNotifier()
    : super(const PermissionState(hasPermission: false, isLoading: true));

  Future<void> checkAndRequestPermissions() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion >= 33) {
        // Android 13+ only needs audio permission
        final audioStatus = await Permission.audio.status;
        if (audioStatus.isDenied) {
          final result = await Permission.audio.request();
          state = PermissionState(
            hasPermission: result.isGranted,
            isLoading: false,
          );
        } else {
          state = PermissionState(
            hasPermission: audioStatus.isGranted,
            isLoading: false,
          );
        }
      } else {
        // Below Android 13 needs storage permission
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isDenied) {
          final result = await Permission.storage.request();
          state = PermissionState(
            hasPermission: result.isGranted,
            isLoading: false,
          );
        } else {
          state = PermissionState(
            hasPermission: storageStatus.isGranted,
            isLoading: false,
          );
        }
      }
    } catch (e) {
      print('Permission error: $e');
      state = const PermissionState(hasPermission: false, isLoading: false);
    }
  }

  Future<void> requestSpecificPermission(Permission permission) async {
    try {
      final result = await permission.request();
      state = PermissionState(
        hasPermission: result.isGranted,
        isLoading: false,
      );
    } catch (e) {
      print('Specific permission request error: $e');
      state = const PermissionState(hasPermission: false, isLoading: false);
    }
  }
}
