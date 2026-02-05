import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hrm/core/helper/camara_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

final CameraLockService _cameraLock = CameraLockService();
final log = Logger();
final ImagePicker picker = ImagePicker();

Future<File?> captureImage() async {
  if (!_cameraLock.tryLock()) {
    log.w('Camera already in use');
    throw Exception('Camera is currently in use');
  }

  try {
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );

    if (file == null) {
      log.i('User cancelled image capture');
      return null;
    }

    return await _compressImage(file);
  } catch (e) {
    log.e('Failed to capture image', error: e);
    rethrow;
  } finally {
    await Future.delayed(const Duration(milliseconds: 500));
    _cameraLock.release();
  }
}

Future<File?> _compressImage(XFile file) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetPath = '${tempDir.path}/attendance_$timestamp.jpg';

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 65,
      format: CompressFormat.jpeg,
    );

    if (compressed == null) {
      log.w('Image compression failed');
      return File(file.path);
    }

    return File(compressed.path);
  } catch (e) {
    log.e('Failed to compress image', error: e);
    return File(file.path);
  }
}
