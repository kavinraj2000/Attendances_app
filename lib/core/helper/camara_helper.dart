/// Global singleton to prevent multiple camera instances across the entire app
class CameraLockService {
  static final CameraLockService _instance = CameraLockService._internal();
  factory CameraLockService() => _instance;
  CameraLockService._internal();

  bool _isCameraActive = false;
  DateTime? _lastCameraOpenTime;

  /// Try to acquire camera lock
  /// Returns true if lock acquired, false if camera is already active
  bool tryLock() {
    // Extra safety: if last camera open was more than 5 seconds ago, force release
    if (_lastCameraOpenTime != null) {
      final timeSinceLastOpen = DateTime.now().difference(_lastCameraOpenTime!);
      if (timeSinceLastOpen.inSeconds > 5) {
        _isCameraActive = false;
        _lastCameraOpenTime = null;
      }
    }

    if (_isCameraActive) {
      return false;
    }

    _isCameraActive = true;
    _lastCameraOpenTime = DateTime.now();
    return true;
  }

  /// Release camera lock
  void release() {
    _isCameraActive = false;
  }

  /// Force release (emergency use)
  void forceRelease() {
    _isCameraActive = false;
    _lastCameraOpenTime = null;
  }

  /// Check if camera is currently active
  bool get isActive => _isCameraActive;
}