import 'package:hive/hive.dart';
import 'package:todo_app/features/focus/data/models/focus_model.dart';

class FocusLocalDataSource {
  static const String _boxName = 'focusSessionsBox';

  Future<Box<SessionLog>> _openBox() async {
    return await Hive.openBox<SessionLog>(_boxName);
  }

  Future<List<SessionLog>> loadSessions() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> saveSessions(List<SessionLog> sessions) async {
    final box = await _openBox();
    await box.clear();
    await box.addAll(sessions);
  }
}