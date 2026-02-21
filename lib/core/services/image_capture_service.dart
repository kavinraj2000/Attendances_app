import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final Logger log = Logger();
  final ImagePicker picker = ImagePicker();
  final PreferencesRepository pref = PreferencesRepository();

  Future<File?> captureImage() async {
    try {
      final status = await Permission.camera.request();

      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        return null;
      }

      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (file == null) return null;

      return await _compressImage(file);
    } catch (e) {
      log.e("Capture error: $e");
      return null;
    }
  }

  Future<File?> _compressImage(XFile file) async {
    try {
      final user = await pref.getUserData();
      final checkInString = await pref.getCheckInTime();

      if (user == null || user.employeeId == null) {
        throw Exception('User session expired. Please login again');
      }

      String checkStatus = 'Checkin';

      if (checkInString != null) {
        final checkInTime = DateTime.parse(checkInString.toString());
        final now = DateTime.now();

        final isSameDay =
            checkInTime.year == now.year &&
            checkInTime.month == now.month &&
            checkInTime.day == now.day;

        if (isSameDay) {
          checkStatus = 'CheckOut';
        }
      }

      final fileName =
          '${user.username}_${user.employeeId}_${checkStatus}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/$fileName';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 65,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        log.w("Compression failed, returning original file");
        return File(file.path);
      }

      log.i("Image compressed successfully: ${compressed.path}");
      return File(compressed.path);
    } catch (e) {
      log.e("Compression error: $e");
      return File(file.path);
    }
  }
}
