import 'package:permission_handler/permission_handler.dart';

Future<bool> requestRequiredPermissions() async {
  final camera = await Permission.camera.request();
  if (!camera.isGranted) return false;

  final location = await Permission.location.request();
  if (!location.isGranted) return false;

  if (await Permission.locationAlways.isDenied) {
    final bg = await Permission.locationAlways.request();

    if (!bg.isGranted) {
      openAppSettings(); 
      return false;
    }
  }

  return true;
}
