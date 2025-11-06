import 'package:vibration/vibration.dart';
import 'storage_service.dart';

class VibrationService {
  static final VibrationService _instance = VibrationService._internal();
  factory VibrationService() => _instance;
  VibrationService._internal();

  final StorageService _storageService = StorageService();

  /// Trigger light vibration (button press)
  Future<void> light() async {
    final isEnabled = await _storageService.getVibrationEnabled();
    if (!isEnabled) return;

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  /// Trigger medium vibration (selection)
  Future<void> medium() async {
    final isEnabled = await _storageService.getVibrationEnabled();
    if (!isEnabled) return;

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  /// Trigger strong vibration (success/completion)
  Future<void> strong() async {
    final isEnabled = await _storageService.getVibrationEnabled();
    if (!isEnabled) return;

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  /// Trigger error vibration pattern
  Future<void> error() async {
    final isEnabled = await _storageService.getVibrationEnabled();
    if (!isEnabled) return;

    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(
        pattern: [0, 100, 50, 100],
        intensities: [0, 128, 0, 255],
      );
    } else if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 150);
    }
  }

  /// Trigger success vibration pattern
  Future<void> success() async {
    final isEnabled = await _storageService.getVibrationEnabled();
    if (!isEnabled) return;

    if (await Vibration.hasCustomVibrationsSupport() ?? false) {
      Vibration.vibrate(
        pattern: [0, 50, 50, 100],
        intensities: [0, 128, 0, 255],
      );
    } else if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }
}