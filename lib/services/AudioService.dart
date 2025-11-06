import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  /// Helper: Check if sound is enabled (read directly from SharedPreferences)
  Future<bool> _isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true if no preference is stored
    return prefs.getBool('sound_enabled') ?? true;
  }

  /// Play button click sound
  Future<void> playClick() async {
    if (!await _isSoundEnabled()) return;
    await _player.play(AssetSource('sounds/click.mp3'), volume: 0.3);
  }

  /// Play success sound
  Future<void> playSuccess() async {
    if (!await _isSoundEnabled()) return;
    await _player.play(AssetSource('sounds/success.mp3'), volume: 0.5);
  }

  /// Play error sound
  Future<void> playError() async {
    if (!await _isSoundEnabled()) return;
    await _player.play(AssetSource('sounds/error.mp3'), volume: 0.5);
  }

  /// Play camera shutter sound
  Future<void> playShutter() async {
    if (!await _isSoundEnabled()) return;
    await _player.play(AssetSource('sounds/shutter.mp3'), volume: 0.4);
  }

  /// Play processing sound
  Future<void> playProcessing() async {
    if (!await _isSoundEnabled()) return;
    await _player.play(AssetSource('sounds/processing.mp3'), volume: 0.3);
  }

  /// Stop any playing sound
  Future<void> stop() async {
    await _player.stop();
  }

  /// Dispose resources
  void dispose() {
    _player.dispose();
  }
}
