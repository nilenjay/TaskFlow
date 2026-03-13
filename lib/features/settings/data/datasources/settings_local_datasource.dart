import 'package:hive/hive.dart';
import '../models/settings_model.dart';

class SettingsLocalDataSource {
  static const String _boxName = 'settingsBox';
  static const String _key = 'app_settings';

  Future<Box<AppSettings>> _openBox() async {
    return await Hive.openBox<AppSettings>(_boxName);
  }

  Future<AppSettings> loadSettings() async {
    final box = await _openBox();
    return box.get(_key) ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final box = await _openBox();
    await box.put(_key, settings);
  }
}