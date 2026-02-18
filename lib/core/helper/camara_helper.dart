// class CameraLockService {
//   static final CameraLockService _instance = CameraLockService._internal();
//   factory CameraLockService() => _instance;
//   CameraLockService._internal();

//   bool _isCameraActive = false;
//   DateTime? _lastCameraOpenTime;

//   bool tryLock() {
//     if (_lastCameraOpenTime != null) {
//       final timeSinceLastOpen = DateTime.now().difference(_lastCameraOpenTime!);
//       if (timeSinceLastOpen.inSeconds > 5) {
//         _isCameraActive = false;
//         _lastCameraOpenTime = null;
//       }
//     }
//     if (_isCameraActive) {
//       return false;
//     }

//     _isCameraActive = true;
//     _lastCameraOpenTime = DateTime.now();
//     return true;
//   }

//   void release() {
//     _isCameraActive = false;
//   }

//   void forceRelease() {
//     _isCameraActive = false;
//     _lastCameraOpenTime = null;
//   }

//   bool get isActive => _isCameraActive;
// }
