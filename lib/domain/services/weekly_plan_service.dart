import '../../data/models/workout_plan_model.dart';

class WeeklyPlanService {
  WeeklyPlanService._();

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool canEditDate({
    required DateTime targetDate,
    required DateTime now,
  }) {
    return dateOnly(targetDate).isAfter(dateOnly(now));
  }

  static int missedRequiredDays({
    required WorkoutPlanModel plan,
    required DateTime? after,
    required DateTime before,
  }) {
    if (after == null) return 0;
    var cursor = dateOnly(after).add(const Duration(days: 1));
    final end = dateOnly(before);
    var missed = 0;
    while (cursor.isBefore(end)) {
      if (plan.dayFor(cursor).countsForStreak) missed++;
      cursor = cursor.add(const Duration(days: 1));
    }
    return missed;
  }

  static List<DateTime> requiredDates({
    required WorkoutPlanModel plan,
    required DateTime from,
    required DateTime through,
  }) {
    var cursor = dateOnly(from);
    final end = dateOnly(through);
    final result = <DateTime>[];
    while (!cursor.isAfter(end)) {
      if (plan.dayFor(cursor).countsForStreak) result.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return result;
  }

  static double adherence({
    required WorkoutPlanModel plan,
    required DateTime from,
    required DateTime through,
    required Iterable<DateTime> completedDates,
  }) {
    final expected = requiredDates(plan: plan, from: from, through: through);
    if (expected.isEmpty) return 1;
    final completed = completedDates.map(dateOnly).toSet();
    final count = expected.where(completed.contains).length;
    return count / expected.length;
  }
}
