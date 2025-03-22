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
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) {
        state = true;
      } else if (status.isDenied && retry) {
        // Retry requesting permission
        status = await Permission.storage.request();
        state = status.isGranted;
      } else {
        state = false;
      }
    } catch (e) {
      state = false;
      // Handle the error appropriately, e.g., log it or show a message to the user
      print('Error requesting permissions: $e');
    }
  }
}
