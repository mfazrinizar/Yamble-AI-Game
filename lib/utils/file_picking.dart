import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePicking {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(ImageSource source) async {
    if (!kIsWeb) {
      // Request permission only on non-web platforms
      final status = await requestPermission();
      if (!status.isGranted) {
        return null;
      }
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  Future<String?> pickImagePath(ImageSource source) async {
    if (!kIsWeb) {
      // Request permission only on non-web platforms
      final status = await requestPermission();
      if (!status.isGranted) {
        return null;
      }
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return null;
    }
  }

  Future<PermissionStatus> requestPermission() async {
    // Automatically return granted for web
    if (kIsWeb) {
      return PermissionStatus.granted;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isAndroid && androidInfo.version.sdkInt >= 33) {
      return await Permission.photos.request();
    } else {
      return await Permission.storage.request();
    }
  }
}
