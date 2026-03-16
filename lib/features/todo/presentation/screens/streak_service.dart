import 'package:todo_app/features/todo/data/models/todo_model.dart';

class StreakData {
  final int currentStreak;
  final int bestStreak;
  final int totalDone;
  final DateTime? lastActive;

  const StreakData({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalDone,
    this.lastActive,
  });
}

class StreakService {
  StreakService._();
  static final instance = StreakService._();

  /// Calculates streak from the list of all todos.
  /// A "streak day" = any day where at least one task was completed.
  StreakData calculate(List<TodoModel> todos) {
    final completed = todos.where((t) => t.isComplete).toList();
    final totalDone = completed.length;

    if (completed.isEmpty) {
      return const StreakData(
          currentStreak: 0, bestStreak: 0, totalDone: 0);
    }

    // Collect unique days that had completions (using addedDate as proxy
    // since we don't store completedDate — use dueDate if available and past)
    final completionDays = completed.map((t) {
      final d = t.dueDate ?? t.addedDate;
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList()
      ..sort();

    DateTime? lastActive = completionDays.last;

    // Build streak working backwards from today
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    int currentStreak = 0;
    int bestStreak = 0;
    int runningStreak = 1;

    // Check if streak is still alive (completed today or yesterday)
    final streakAlive = completionDays.contains(today) ||
        completionDays.contains(yesterday);

    if (streakAlive) {
      // Count backwards from today
      DateTime check = completionDays.contains(today) ? today : yesterday;
      currentStreak = 1;
      for (int i = 1; i < 365; i++) {
        final prev = check.subtract(Duration(days: i));
        if (completionDays.contains(prev)) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    // Calculate best streak across all history
    for (int i = 1; i < completionDays.length; i++) {
      final diff = completionDays[i].difference(completionDays[i - 1]).inDays;
      if (diff == 1) {
        runningStreak++;
      } else {
        bestStreak = runningStreak > bestStreak ? runningStreak : bestStreak;
        runningStreak = 1;
      }
    }
    bestStreak = runningStreak > bestStreak ? runningStreak : bestStreak;
    bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;

    return StreakData(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalDone: totalDone,
      lastActive: lastActive,
    );
  }

  String streakMessage(int streak) {
    if (streak == 0) return 'Start your streak today!';
    if (streak == 1) return 'Great start! Keep going!';
    if (streak < 5) return 'Building momentum! 🔥';
    if (streak < 10) return 'On fire! Keep it up!';
    if (streak < 30) return 'Incredible consistency!';
    return 'Legendary! You\'re unstoppable!';
  }
}