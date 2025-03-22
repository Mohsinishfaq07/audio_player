import 'package:flutter/material.dart';

Widget NoStoragePermission(VoidCallback checkAndRequestPermissions) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.redAccent.withOpacity(0.5),
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Allow Storage Permission to Continue"),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async => checkAndRequestPermissions(),
          child: const Text("Allow"),
        ),
      ],
    ),
  );
}
